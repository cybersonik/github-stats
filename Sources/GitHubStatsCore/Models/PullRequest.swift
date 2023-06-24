//
//  PullRequest.swift
//  
//
//  Created by Jesse Wesson on 5/22/23.
//

import Foundation
import ArgumentParser

public struct PullRequest: GitHubObject {
    public var id: Int
    public var number: Int
    public var title: String
    public var state: State
    public var body: String?
    public var user: User
    public var assignees: [User]

    public enum State: String, Codable, ExpressibleByArgument {
        case open
        case closed
        case all
    }
}

// TODO: Move type to seperate file
public struct PullRequestFilterFactory {
    public var additionalQueryParameters: [String : String] {
        ["state": state.rawValue]
    }

    public var maxResults: Int = GitHubConstants.defaultMaxResults
    public var state: PullRequest.State = .open
    public var author: String? = nil

    public init(maxResults: Int = 100, state: PullRequest.State = .open, author: String? = nil) {
        self.maxResults = maxResults
        self.state = state
        self.author = author
    }

    public func makeRequestFilter() -> RequestFilter<PullRequest> {
        var filterFunction: ((PullRequest) -> Bool)? = nil

        if let author {
            filterFunction = { (pullRequest: PullRequest) -> Bool in
                return pullRequest.user.login == author
            }
        }

        return RequestFilter<PullRequest>(maxResults: maxResults, additionalFilters: ["state": state.rawValue], filterFunction: filterFunction)
    }
}
