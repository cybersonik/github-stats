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

    internal init(endpointRequest: EndpointRequest) {
        self.endpointRequest = endpointRequest
    }

    // TODO: replace RequestFilter<PullRequestFilter> with generic type
    public func callEndpoint<T: GitHubObject>(filter: RequestFilter<T>) async throws -> [T] {
        var results = Array<T>()

        var url = endpointRequest.makeRequest(queryParameters: filter.queryParameters)
        var shouldContinue = false

        repeat {
            var result: (data: Data, response: URLResponse)? = nil
            
            do {
#if os(Linux)
                result = try await withCheckedThrowingContinuation { continuation in
                    URLSession.shared.dataTask(with: url) { data, response, error in
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
                result = try await URLSession.shared.data(for: url)
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
                throw EndpointError.unsuccessfulResponseError(httpResponseStatusCode: statusCode)
            }

            let resultsPage: [T] = try JSONDecoder().decode([T].self, from: result.data)
            if let filterFunction = filter.filterFunction {
                let filteredResults = resultsPage.filter(filterFunction)
                results.append(contentsOf: filteredResults)
            } else {
                results.append(contentsOf: resultsPage)
            }

            let maxResults = filter.maxResults
            if results.count >= maxResults {
                results.removeSubrange(maxResults...)
                shouldContinue = false
            } else if let nextPageUrl = getNextPageUrl(from: httpResponse) {
                url = endpointRequest.makeNextRequest(with: nextPageUrl)
                shouldContinue = true
            } else {
                shouldContinue = false
            }
        } while shouldContinue

        return results
    }

    func getNextPageUrl(from response: HTTPURLResponse) -> URL? {
        guard let linkHeader = response.value(forHTTPHeaderField: GitHubConstants.nextPageLinkHeader) else {
            return nil
        }

        guard let match = linkHeader.firstMatch(of: GitHubConstants.nextPageLinkRegex) else {
            return nil
        }

        let (_, nextPage) = match.output
        return URL(string: String(nextPage))
    }
}
