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
    private let queryParams: [String: String]

    internal init(repo: Repo, path: String, queryParams: [String: String]) {
        self.repo = repo
        self.path = path
        self.queryParams = queryParams
    }

    public func makeRequest(maxResultCount: Int? = nil) -> URLRequest {
        let url = constructURL(maxResultCount: maxResultCount)
        return makeURLRequest(with: url)
    }

    public func makeNextRequest(with nextPageUrl: URL, maxResultCount: Int? = nil) -> URLRequest {
        return makeURLRequest(with: nextPageUrl)
    }

    private func constructURL(maxResultCount: Int? = nil) -> URL {
        var urlBuilder = URLComponents()

        urlBuilder.scheme = "https"
        urlBuilder.host = "api.github.com"
        urlBuilder.path = "/repos/\(repo.organization)/\(repo.name)/\(path)"
        urlBuilder.queryItems = queryParams.map({ (key: String, value: String) in
            URLQueryItem(name: key, value: value)
        })

        if let maxResultCount {
            urlBuilder.queryItems?.append(URLQueryItem(name: "limit", value: String(maxResultCount)))
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

        if let token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        return request
    }
}
