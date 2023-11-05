//
//  PullRequestFilterFactory.swift
//  
//
//  Created by Jesse Wesson on 6/24/23.
//

import Foundation

public struct PullRequestFilterFactory {
    public var additionalQueryParameters: [String: String] {
        ["state": state.rawValue]
    }

    public var maxResults: Int = GitHubConstants.defaultMaxResults
    public var state: PullRequest.State = .open
    public var author: String?

    private enum QueryParameter: String {
        case state
    }

    public static func makeDefaultRequestFilter() -> RequestFilter<PullRequest> {
        let maxResults: Int = GitHubConstants.defaultMaxResults
        let state: PullRequest.State = .open

        return RequestFilter<PullRequest>(maxResults: maxResults, additionalFilters: [QueryParameter.state.rawValue: state.rawValue])
    }

    public init(maxResults: Int = 100, state: PullRequest.State = .open, author: String? = nil) {
        self.maxResults = maxResults
        self.state = state
        self.author = author
    }

    public func makeRequestFilter() -> RequestFilter<PullRequest> {
        var filterFunction: ((PullRequest) -> Bool)?

        if let author {
            filterFunction = { (pullRequest: PullRequest) -> Bool in
                return pullRequest.user.login == author
            }
        }

        return RequestFilter<PullRequest>(maxResults: maxResults, additionalFilters: [QueryParameter.state.rawValue: state.rawValue], filterFunction: filterFunction)
    }
}
