//
//  GitHubEndpointRequest.swift
//  
//
//  Created by Jesse Wesson on 5/22/23.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public struct EndpointRequest {
    private let token = ProcessInfo.processInfo.environment[GitHubConstants.gitHubTokenEnvironmentVariable]

    private let repo: Repo
    private let path: String

    internal init(repo: Repo, path: String) {
        self.repo = repo
        self.path = path
    }

    public func makeRequest(queryParameters: [String: String]? = nil) -> URLRequest {
        let url = constructURL(queryParameters: queryParameters)
        return makeURLRequest(with: url)
    }

    public func makeNextRequest(with nextPageUrl: URL) -> URLRequest {
        return makeURLRequest(with: nextPageUrl)
    }

    private func constructURL(queryParameters: [String: String]? = nil) -> URL {
        var urlBuilder = URLComponents()

        urlBuilder.scheme = "https"
        urlBuilder.host = "api.github.com"
        urlBuilder.path = "/repos/\(repo.organization)/\(repo.name)/\(path)"
        if let queryParameters {
            urlBuilder.queryItems = queryParameters.map({ (key: String, value: String) in
                URLQueryItem(name: key, value: value)
            })
        }

        guard let url = urlBuilder.url else {
            preconditionFailure(
                "Invalid URL components: \(urlBuilder)"
            )
        }

        return url
    }

    private func makeURLRequest(with url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        request.setValue("2022-11-28", forHTTPHeaderField: "X-GitHub-Api-Version")
        request.setValue(GitHubConstants.gitHubUserAgentString, forHTTPHeaderField: "User-Agent")

        if let token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        return request
    }
}
