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

    public func callEndpoint<T: GitHubObject>(maxResultCount: Int? = nil) async throws -> [T]? {
        var results = Array<T>()

        var url = endpointRequest.makeRequest(maxResultCount: maxResultCount)
        var shouldContinue = false

        repeat {
            do {
#if os(Linux)
                let result = try await withCheckedThrowingContinuation { continuation in
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
                let (data, response) = (result.0, result.1)
#else
                let (data, response) = try await URLSession.shared.data(for: url)
#endif

                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    throw EndpointError.statusCodeNotOK
                }

                let pullRequestsPage: [T] = try JSONDecoder().decode([T].self, from: data)

                results.append(contentsOf: pullRequestsPage)

                if let maxResultCount, results.count >= maxResultCount {
                    results.removeSubrange(maxResultCount...)
                    shouldContinue = false
                } else if let nextPageUrl = getNextPageUrl(from: httpResponse) {
                    url = endpointRequest.makeNextRequest(with: nextPageUrl, maxResultCount: maxResultCount)
                    shouldContinue = true
                } else {
                    shouldContinue = false
                }
            } catch {
                print(error)
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
