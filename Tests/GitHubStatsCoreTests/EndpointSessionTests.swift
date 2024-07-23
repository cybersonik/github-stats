//
//  EndpointSessionTests.swift
//  GitHubStats
//
//  Created by Jesse Wesson on 2023-08-30.
//

import Testing
import Foundation
@testable import GitHubStatsCore

@Suite("EndpointSession tests")
internal struct EndpointSessionTests {
    private let linkHeader = """
        <https://api.github.com/repositories/44838949/pulls?state=closed&page=2>; rel="next", \
        <https://api.github.com/repositories/44838949/pulls?state=closed&page=10>; rel="last"
        """

    @Test("Test getNextPagesUrl")
    func getNextPagesUrl() {
        // Arrange
        let nextPageUrl = URL(string: "https://api.github.com/repositories/44838949/pulls?state=closed&page=2")

        // Act
        let urls = EndpointSession.getNextPageUrl(from: linkHeader)

        // Assert
        #expect(urls != nil)
        #expect(urls == nextPageUrl)
    }

    @Test("Test getNextPagesUrls")
    func testGetNextPagesUrls() {
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
        let urls = EndpointSession.getNextPagesUrls(from: linkHeader)

        // Assert
        #expect(urls != nil)
        if let urls {
            #expect(urls.count == 9)
            #expect(urls == nextPageUrls)
        }
    }
}
