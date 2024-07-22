//
//  EndpointConstants.swift
//  
//
//  Created by Jesse Wesson on 5/22/23.
//

import Foundation

internal enum GitHubConstants {
    static let gitRepoExtension = ".git"

    static let gitHubTokenEnvironmentVariable = "TEST_GITHUB_TOKEN"

    static let gitHubUserAgentString = "github-stats-cli"

    static let retryAfterHeader = "Retry-After"
    static let contentTypeHeader = "Content-Type"

    static let gitHubUrlRegex = #/^git@github\.com:(?<org>[\w\-\.]+)/(?<repo>[\w\-\.]+)$/#

    static let defaultMaxResults = 100

    static let numberOfConcurrentFetches = 3

    static let nextPageLinkHeader = "link"

    // swiftlint:disable comment_spacing
    static let nextPageLinkRegex = #/<([^>]+)>; rel="next"/# //i;
    static let nextPageLinkAndLastPageRegex = #/<([^>]+)&page=(\d+)>; rel="next", <[^>]+&page=(\d+)>; rel="last"/# //i;
    // swiftlint:enable comment_spacing
}
