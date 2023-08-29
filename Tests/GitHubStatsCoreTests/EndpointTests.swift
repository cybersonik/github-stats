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
    private let author = "DougGregor"
    
    override func setUpWithError() throws {
        let token = ProcessInfo.processInfo.environment[GitHubConstants.gitHubTokenEnvironmentVariable]
        guard token != nil else {
            throw XCTSkip("GitHub API token not found in environment variables")
        }
    }

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
        let pullRequestFilterFactory = PullRequestFilterFactory(maxResults: 10, state: .closed, author: author)
        let filter = pullRequestFilterFactory.makeRequestFilter()
        let pullRequests = try await repo.getPullRequests(filter: filter)

        // Assert
        XCTAssertNotNil(pullRequests)
        XCTAssertEqual(pullRequests.count, 10)
    }

    func testGetPullRequestsWithMultiplePagesAndComplexFilter() async throws {
        // Arrange
        let repo = Repo(organization: organization, name: repo)

        // Act
        let pullRequestFilterFactory = PullRequestFilterFactory(maxResults: 25, state: .closed, author: author)
        let filter = pullRequestFilterFactory.makeRequestFilter()
        let pullRequests = try await repo.getPullRequests(filter: filter)

        // Assert
        XCTAssertNotNil(pullRequests)
        XCTAssertEqual(pullRequests.count, 25)
        for pullRequest in pullRequests {
            XCTAssertEqual(pullRequest.state, .closed)
            XCTAssertEqual(pullRequest.user.login, author)
        }
    }
}
