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
        let gitHubStats = GitHubRepo(organization: organization, repo: repo)

        // Act
        let pullRequsts = try await gitHubStats.getPullRequests()

        // Assert
        XCTAssertNotNil(pullRequsts)
    }

    func testGetLimitedPullRequests() async throws {
        // Arrange
        let gitHubStats = GitHubRepo(organization: organization, repo: repo)

        // Act
        let pullRequsts = try await gitHubStats.getPullRequests(limit: 100, state: .all)

        // Assert
        XCTAssertNotNil(pullRequsts)
        XCTAssertLessThanOrEqual(pullRequsts.count, 100)
    }
}
