//
//  GitHubEndpointSession.swift
//  
//
//  Created by Jesse Wesson on 5/22/23.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public struct EndpointSession {
    private let endpointRequest: EndpointRequest

    private var session: URLSession

    internal init(endpointRequest: EndpointRequest) {
        self.endpointRequest = endpointRequest

        let configuration = EndpointEnvironment.urlSessionConfiguration
        // configuration.httpMaximumConnectionsPerHost = 3
        session = URLSession.init(configuration: configuration)
        session.sessionDescription = "GitHub Endpoint Session"
    }
    
    // TODO: replace RequestFilter<PullRequestFilter> with generic type
    public func callEndpoint<T: GitHubObject>(filter: RequestFilter<T>) async throws -> [T] {
        var results = Array<T>()
        
        let url = endpointRequest.makeRequest(queryParameters: filter.queryParameters)
        var urlsToFetch = [URLRequest]()
        var urlsToFetchNext = [url]
        
        var shouldContinue = false
        
        repeat {
            let urlsToFetchCount = urlsToFetchNext.count > GitHubConstants.numberOfConcurrentFetches
                                    ? GitHubConstants.numberOfConcurrentFetches
                                    : urlsToFetchNext.count
            let urlsToFetchRange = 0..<urlsToFetchCount
            urlsToFetch = Array(urlsToFetchNext[urlsToFetchRange])
            urlsToFetchNext.removeSubrange(urlsToFetchRange)
            var httpResults = [(data: Data, httpResponse: HTTPURLResponse)]()
            
            let _ = try await withThrowingTaskGroup(of: (data: Data, httpResponse: HTTPURLResponse).self) { taskGroup in
                for url in urlsToFetch {
                    taskGroup.addTask {
                        return try await callEndpointWithRetry(url: url)
                    }
                }
                
                while let result = try await taskGroup.next() {
                    httpResults.append(result)
                }
                
                return httpResults
            }
            
            guard httpResults.count > 0 else {
                throw EndpointError.unknownError
            }

            for result in httpResults {
                let resultsPage: [T] = try JSONDecoder().decode([T].self, from: result.data)
                if let filterFunction = filter.filterFunction {
                    let filteredResults = resultsPage.filter(filterFunction)
                    results.append(contentsOf: filteredResults)
                } else {
                    results.append(contentsOf: resultsPage)
                }
            }

            let maxResults = filter.maxResults
            if results.count >= maxResults {
                results.removeSubrange(maxResults...)
                shouldContinue = false
            } else if urlsToFetchNext.count > 0 {
                shouldContinue = true
            } else if httpResults.count == 1, let nextPageUrls = getNextPagesUrls(from: httpResults.first!.httpResponse) {
                urlsToFetchNext = nextPageUrls.map { endpointRequest.makeNextRequest(with: $0) }
                shouldContinue = true
            } else {
                shouldContinue = false
            }
        } while shouldContinue
        
        return results
    }

    private func callEndpointWithRetry(url: URLRequest) async throws -> (data: Data, httpResponse: HTTPURLResponse) {
        var retry = false
        repeat {
            do {
                return try await fetchResult(url: url)
            } catch EndpointError.rateLimitError(let retryAfterSeconds) {
                retry = true
                try await Task.sleep(nanoseconds: UInt64(retryAfterSeconds * 1_000_000_000))
            } catch let error {
                throw error
            }
        } while retry
    }

    private func fetchResult(url: URLRequest) async throws -> (data: Data, httpResponse: HTTPURLResponse) {
        var result: (data: Data, response: URLResponse)?

        do {
#if os(Linux)
            result = try await withCheckedThrowingContinuation { continuation in
                session.dataTask(with: url) { data, response, error in
                    if let data, let response {
                        continuation.resume(returning: (data, response))
                    } else if let error = error {
                        continuation.resume(throwing: error)
                    } else {
                        continuation.resume(throwing: EndpointError.unknownError)
                    }
                }.resume()
            }
#else
            result = try await session.data(for: url)
#endif
        } catch {
            print(error)
        }
        
        guard let result else {
            throw EndpointError.urlSessionError
        }
        
        guard let httpResponse = result.response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            let httpResponse = result.response as? HTTPURLResponse
            let statusCode = httpResponse?.statusCode ?? 418

            if statusCode == 403, let retryAfter = httpResponse?.value(forHTTPHeaderField: GitHubConstants.retryAfterHeader) {
                throw EndpointError.rateLimitError(retryAfterSeconds: Int(retryAfter) ?? 60)
            } else {
                if let contentType = httpResponse?.value(forHTTPHeaderField: GitHubConstants.contentTypeHeader), contentType.hasPrefix( "application/json") {
                    let gitHubError: GitHubError = try JSONDecoder().decode(GitHubError.self, from: result.data)
                    debugPrint(gitHubError)
                }

                let jsonString = String(decoding: result.data, as: UTF8.self)
                let httpResponseBody: String? = jsonString.isEmpty ? nil : jsonString
                throw EndpointError.unsuccessfulResponseError(httpResponseStatusCode: statusCode, httpResponseBody: httpResponseBody)
            }
        }
        
        return (result.data, httpResponse)
    }
    
    @available(*, deprecated, message: "Use EndpointSession.getNextPagesUrls(from:) instead")
    func getNextPageUrl(from response: HTTPURLResponse) -> URL? {
        guard let linkHeader = response.value(forHTTPHeaderField: GitHubConstants.nextPageLinkHeader) else {
            return nil
        }
        
        return EndpointSession.getNextPageUrl(from: linkHeader)
    }
    
    @available(*, deprecated, message: "Use EndpointSession.getNextPagesUrls(from:) instead")
    static func getNextPageUrl(from linkHeader: String) -> URL? {
        guard let match = linkHeader.firstMatch(of: GitHubConstants.nextPageLinkRegex) else {
            return nil
        }
        
        let (_, nextPage) = match.output
        return URL(string: String(nextPage))
    }
    
    func getNextPagesUrls(from response: HTTPURLResponse) -> [URL]? {
        guard let linkHeader = response.value(forHTTPHeaderField: GitHubConstants.nextPageLinkHeader) else {
            return nil
        }
        
        return EndpointSession.getNextPagesUrls(from: linkHeader)
    }
    
    static func getNextPagesUrls(from linkHeader: String) -> [URL]? {
        guard let match = linkHeader.firstMatch(of: GitHubConstants.nextPageLinkAndLastPageRegex) else {
            return nil
        }
        
        let (_, nextPageBaseURL, nextPageNumber, lastPageNumber) = match.output
        
        let start = Int(String(nextPageNumber)) ?? 0
        let end = Int(String(lastPageNumber)) ?? 0
        
        let nextPageURL = URL(string: String(nextPageBaseURL))
        guard let nextPageURL else {
            return nil
        }
        
        var nextPageURLs = Array<URL>()
        for pageNumber in start...end {
            // convert int to string
            let page = String(pageNumber)
#if os(Linux)
            var urlBuilder = URLComponents(url: nextPageURL, resolvingAgainstBaseURL: false)
            
            if let queryItems = urlBuilder?.queryItems, queryItems.isEmpty {
                urlBuilder?.queryItems = [URLQueryItem(name: "page", value: page)]
            } else {
                urlBuilder?.queryItems?.append(contentsOf: [URLQueryItem(name: "page", value: page)])
            }
            
            let pageURL = urlBuilder!.url!
#else
            let pageURL = nextPageURL.appending(queryItems: [URLQueryItem(name: "page", value: page)])
#endif
            nextPageURLs.append(pageURL)
        }
        
        return nextPageURLs
    }
}
