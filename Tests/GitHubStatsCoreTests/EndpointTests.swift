//
//  EndpointTests.swift
//
//
//  Created by Jesse Wesson on 5/22/23.
//

import XCTest
import Testing
import Foundation
@testable import GitHubStatsCore

@Suite("EndpointTests tests", .disabled(if: ProcessInfo.processInfo.environment[GitHubConstants.gitHubTokenEnvironmentVariable] == nil, "GitHub API token not found in environment variables"))
internal struct EndpointTests {
    private let organization = "apple"
    private let repo = "swift.git"
    private let author = "DougGregor"

    @Test("Test getPullRequests with an invalid repo")
    func testInvalidRepoPullRequests() async throws {
        // Arrange
        let repo = Repo(organization: "foo", name: "bar")

        // Act
        var pullRequests: [PullRequest]?
        var thrownError: Error?
        var returnedStatusCode: Int?
        var returnedBody: String?
        do {
            let filter = PullRequestFilterFactory.makeDefaultRequestFilter()
            pullRequests = try await repo.getPullRequests(filter: filter)
            Issue.record("Control flow should never reach here")
        } catch let error as EndpointError {
            thrownError = error

            switch error {
            case .unsuccessfulResponseError(let responseCode, let httpResponseBody):
                returnedStatusCode = responseCode
                returnedBody = httpResponseBody

            default:
                Issue.record("Control flow should never reach here")
            }
        } catch {
            Issue.record("Control flow should never reach here")
        }

        // Assert
        #expect(pullRequests == nil)
        #expect(thrownError != nil)
        #expect(thrownError is EndpointError)
        #expect(returnedStatusCode != nil)
        #expect(returnedStatusCode! == 404)
        #expect(returnedBody != nil)
    }

    @Test("Test getPullRequests with default filter")
    func testGetPullRequests() async throws {
        // Arrange
        let repo = Repo(organization: organization, name: repo)

        // Act
        let filter = PullRequestFilterFactory.makeDefaultRequestFilter()
        let pullRequests = try await repo.getPullRequests(filter: filter)

        // Assert
        #expect(pullRequests != nil)
        XCTAssertGreaterThan(pullRequests.count, 0)
    }

    @Test("Test getPullRequests with maxResults filter")
    func testGetPullRequestsLimitedToMaxResults() async throws {
        // Arrange
        let repo = Repo(organization: organization, name: repo)

        // Act
        let pullRequestFilterFactory = PullRequestFilterFactory(maxResults: 5, state: .all)
        let filter = pullRequestFilterFactory.makeRequestFilter()
        let pullRequests = try await repo.getPullRequests(filter: filter)

        // Assert
        #expect(pullRequests != nil)
        XCTAssertGreaterThan(pullRequests.count, 0)
        XCTAssertLessThanOrEqual(pullRequests.count, 5)
    }

    @Test("Test getPullRequests with maxResults and state filter")
    func testGetPullRequestsFilteredByClosed() async throws {
        // Arrange
        let repo = Repo(organization: organization, name: repo)

        // Act
        let pullRequestFilterFactory = PullRequestFilterFactory(maxResults: 10, state: .closed)
        let filter = pullRequestFilterFactory.makeRequestFilter()
        let pullRequests = try await repo.getPullRequests(filter: filter)

        // Assert
        #expect(pullRequests != nil)
        #expect(pullRequests.count == 10)
        for pullRequest in pullRequests {
            #expect(pullRequest.state == .closed)
        }
    }

    @Test("Test getPullRequests with maxResults, state and author filter")
    func testGetPullRequestsFilteredByAuthor() async throws {
        // Arrange
        let repo = Repo(organization: organization, name: repo)

        // Act
        let pullRequestFilterFactory = PullRequestFilterFactory(maxResults: 10, state: .closed, author: author)
        let filter = pullRequestFilterFactory.makeRequestFilter()
        let pullRequests = try await repo.getPullRequests(filter: filter)

        // Assert
        #expect(pullRequests != nil)
        #expect(pullRequests.count == 10)
        for pullRequest in pullRequests {
            #expect(pullRequest.state == .closed)
            #expect(pullRequest.user.login == author)
        }
    }

    @Test("Test getPullRequests with complex filter resulting in multiple pages")
    func testGetPullRequestsWithMultiplePagesAndComplexFilter() async throws {
        // Arrange
        let repo = Repo(organization: organization, name: repo)

        // Act
        let pullRequestFilterFactory = PullRequestFilterFactory(maxResults: 25, state: .closed, author: author)
        let filter = pullRequestFilterFactory.makeRequestFilter()
        let pullRequests = try await repo.getPullRequests(filter: filter)

        // Assert
        #expect(pullRequests != nil)
        #expect(pullRequests.count == 25)
        for pullRequest in pullRequests {
            #expect(pullRequest.state == .closed)
            #expect(pullRequest.user.login == author)
        }
    }
}

internal final class EndpointPerformanceTests: XCTestCase {
    private let organization = "apple"
    private let repo = "swift.git"
    private let author = "DougGregor"

    func testGetPullRequestsPerformance() {
        EndpointEnvironment.urlSessionConfiguration = .ephemeral
        defer {
            EndpointEnvironment.urlSessionConfiguration = .default
        }

        let testBlock = {
            print("Run testGetPullRequestsPerformance()")

            // Arrange
            let expectation = self.expectation(description: "Get pull requests")
            let repo = Repo(organization: self.organization, name: self.repo)

            // Act
            let pullRequestFilterFactory = PullRequestFilterFactory(maxResults: 25, state: .closed, author: self.author)
            let filter = pullRequestFilterFactory.makeRequestFilter()

            Task {
                let pullRequests = try await repo.getPullRequests(filter: filter)

                XCTAssertNotNil(pullRequests)
                XCTAssertEqual(pullRequests.count, 25)

                expectation.fulfill()
            }

            self.wait(for: [expectation], timeout: 3 * 60)
        }

#if os(Linux)
        self.measure(block: testBlock)
#else
        let options = XCTMeasureOptions()
//        options.iterationCount = 10
        self.measure(metrics: [XCTCPUMetric(), XCTClockMetric(), XCTMemoryMetric()], options: options, block: testBlock)
#endif
    }
}
