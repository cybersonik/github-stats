import Testing
import Foundation
@testable import GitHubStatsCore

@Suite("Repo tests")
internal struct RepoTests {
    @Test("Test Repo initialization with SSH URL", .disabled("Skip until initialization issue resolved"))
    func repoInitWithSshUrl() {
        // Arrange
        let gitHubSshUrl = "git@github.com:apple/swift.git"

        // Act
        let repo = Repo(repoUrl: gitHubSshUrl)

        // Assert
        #expect(repo != nil)
    }

    @Test("Test Repo initialization with HTTP URL", .disabled("Skip until initialization issue resolved"))
    func repoInitWithHttpUrl() {
        // Arrange
        let gitHubHttpUrl = "https://github.com/apple/swift.git"

        // Act
        let repo = Repo(repoUrl: gitHubHttpUrl)

        // Assert
        #expect(repo != nil)
    }

    @Test("Test Repo initialization with URL")
    func repoInitWithUrl() throws {
        // Arrange
        let gitHubUrl = URL(string: "https://github.com/apple/swift.git")!

        // Act
        let repo = Repo(url: gitHubUrl)

        // Assert
        #expect(repo != nil)
    }
}
