//
//  GitHubEndpointTests.swift
//  
//
//  Created by Jesse Wesson on 5/22/23.
//

import XCTest
@testable import GitHubStatsCore

final class EndpointTests: XCTestCase {
    private let organization = "cybersonik"
    private let repo = "PhotoPicker.git"

    func testGetPullRequests() async throws {
        // Arrange
        let repo = Repo(organization: organization, name: repo)

        // Act
        let filter = PullRequestFilterFactory.makeDefaultRequestFilter()
        let pullRequests = try await repo.getPullRequests(filter: filter)

        // Assert
        XCTAssertNotNil(pullRequests)
        XCTAssertGreaterThan(pullRequests.count, 0)
    }

    func testGetPullRequestsLimitedToMaxResults() async throws {
        // Arrange
        let repo = Repo(organization: organization, name: repo)

        // Act
        let pullRequestFilterFactory = PullRequestFilterFactory(maxResults: 5, state: .all)
        let filter = pullRequestFilterFactory.makeRequestFilter()
        let pullRequests = try await repo.getPullRequests(filter: filter)

        // Assert
        XCTAssertNotNil(pullRequests)
        XCTAssertGreaterThan(pullRequests.count, 0)
        XCTAssertLessThanOrEqual(pullRequests.count, 5)
    }

    func testGetPullRequestsFilteredByClosed() async throws {
        // Arrange
        let repo = Repo(organization: organization, name: repo)

        // Act
        let pullRequestFilterFactory = PullRequestFilterFactory(maxResults: 10, state: .closed)
        let filter = pullRequestFilterFactory.makeRequestFilter()
        let pullRequests = try await repo.getPullRequests(filter: filter)

        // Assert
        XCTAssertNotNil(pullRequests)
        XCTAssertGreaterThan(pullRequests.count, 0)
        for pullRequest in pullRequests {
            XCTAssertEqual(pullRequest.state, .closed)
        }
    }

    func testGetPullRequestsFilteredByAuthor() async throws {
        // Arrange
        let repo = Repo(organization: organization, name: repo)

        // Act
        let pullRequestFilterFactory = PullRequestFilterFactory(maxResults: 10, state: .closed, author: "cybersonik")
        let filter = pullRequestFilterFactory.makeRequestFilter()
        let pullRequests = try await repo.getPullRequests(filter: filter)

        // Assert
        XCTAssertNotNil(pullRequests)
        XCTAssertGreaterThan(pullRequests.count, 0)
        for pullRequest in pullRequests {
            XCTAssertEqual(pullRequest.state, .closed)
        }
    }
}
