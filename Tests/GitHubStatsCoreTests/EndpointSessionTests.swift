//
//  EndpointSessionTests.swift
//  GitHubStats
//
//  Created by Jesse Wesson on 2023-08-30.
//

import XCTest
@testable import GitHubStatsCore

final class EndpointSessionTests: XCTestCase {
    private let linkHeader = """
        <https://api.github.com/repositories/44838949/pulls?state=closed&page=2>; rel="next", \
        <https://api.github.com/repositories/44838949/pulls?state=closed&page=10>; rel="last"
        """

    func testGetNextPagesUrl() async throws {
        // Arrange
        let nextPageUrl = URL(string: "https://api.github.com/repositories/44838949/pulls?state=closed&page=2")
        
        // Act
        let urls = EndpointSession.getNextPageUrl(from:linkHeader)

        // Assert
        XCTAssertNotNil(urls)
        XCTAssertEqual(urls, nextPageUrl)
        
    }
    
    func testGetNextPagesUrls() async throws {
        // Arrange
        let nextPageUrls = [
                URL(string: "https://api.github.com/repositories/44838949/pulls?state=closed&page=2"),
                URL(string: "https://api.github.com/repositories/44838949/pulls?state=closed&page=3"),
                URL(string: "https://api.github.com/repositories/44838949/pulls?state=closed&page=4"),
                URL(string: "https://api.github.com/repositories/44838949/pulls?state=closed&page=5"),
                URL(string: "https://api.github.com/repositories/44838949/pulls?state=closed&page=6"),
                URL(string: "https://api.github.com/repositories/44838949/pulls?state=closed&page=7"),
                URL(string: "https://api.github.com/repositories/44838949/pulls?state=closed&page=8"),
                URL(string: "https://api.github.com/repositories/44838949/pulls?state=closed&page=9"),
                URL(string: "https://api.github.com/repositories/44838949/pulls?state=closed&page=10")
                ]
        
        // Act
        let urls = EndpointSession.getNextPagesUrls(from:linkHeader)

        // Assert
        XCTAssertNotNil(urls)
        if let urls {
            XCTAssertEqual(urls.count, 9)
            XCTAssertEqual(urls, nextPageUrls)
        }
    }
}

