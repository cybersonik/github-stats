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

    static let gitHubUrlRegex = #/^git@github\.com:(?<org>[\w\-\.]+)/(?<repo>[\w\-\.]+)$/#

    static let defaultMaxResults = 100
    
    static let nextPageLinkHeader = "link"

    // <https://api.github.com/repositories/44838949/pulls?state=closed&page=2>; rel="next", <https://api.github.com/repositories/44838949/pulls?state=closed&page=1599>; rel="last"
    static let nextPageLinkRegex = #/<([^>]+)>; rel="next"/# //i;
}
