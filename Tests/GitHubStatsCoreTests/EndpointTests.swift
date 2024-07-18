//
//  EndpointTests.swift
//
//
//  Created by Jesse Wesson on 5/22/23.
//

import XCTest
@testable import GitHubStatsCore

internal final class EndpointTests: XCTestCase {
    private let organization = "apple"
    private let repo = "swift.git"
    private let author = "DougGregor"

    override func setUpWithError() throws {
        let token = ProcessInfo.processInfo.environment[GitHubConstants.gitHubTokenEnvironmentVariable]
        guard token != nil else {
            throw XCTSkip("GitHub API token not found in environment variables")
        }
    }

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
            XCTFail("Control flow should never reach here")
        } catch let error as EndpointError {
            thrownError = error

            switch error {
            case .unsuccessfulResponseError(let responseCode, let httpResponseBody):
                returnedStatusCode = responseCode
                returnedBody = httpResponseBody

            default:
                XCTFail("Control flow should never reach here")
            }
        } catch {
            XCTFail("Control flow should never reach here")
        }

        // Assert
        XCTAssertNil(pullRequests)
        XCTAssertNotNil(thrownError)
        XCTAssertTrue(thrownError is EndpointError)
        XCTAssertNotNil(returnedStatusCode)
        XCTAssertEqual(returnedStatusCode!, 404)
        XCTAssertNotNil(returnedBody)
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
        XCTAssertEqual(pullRequests.count, 10)
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
        for pullRequest in pullRequests {
            XCTAssertEqual(pullRequest.state, .closed)
            XCTAssertEqual(pullRequest.user.login, author)
        }
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

            self.wait(for: [expectation], timeout: 120)
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
