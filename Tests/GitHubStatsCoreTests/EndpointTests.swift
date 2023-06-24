//
//  GitHubEndpointTests.swift
//  
//
//  Created by Jesse Wesson on 5/22/23.
//

import XCTest
@testable import GitHubStatsCore

final class EndpointTests: XCTestCase {
    private let organization = "apple"
    private let repo = "swift.git"

    func testGetPullRequests() async throws {
        // Arrange
        let repo = Repo(organization: organization, name: repo)

        // Act
        let pullRequestFilterFactory = PullRequestFilterFactory()
        let filter = pullRequestFilterFactory.makeRequestFilter()
        let pullRequests = try await repo.getPullRequests(filter: filter)

        // Assert
        XCTAssertNotNil(pullRequests)
    }

    func testGetLimitedPullRequests() async throws {
        // Arrange
        let repo = Repo(organization: organization, name: repo)

        // Act
        let pullRequestFilterFactory = PullRequestFilterFactory(maxResults: 10, state: .all)
        let filter = pullRequestFilterFactory.makeRequestFilter()
        let pullRequests = try await repo.getPullRequests(filter: filter)

        // Assert
        XCTAssertNotNil(pullRequests)
        XCTAssertLessThanOrEqual(pullRequests.count, 10)
    }
}
