import XCTest
@testable import GitHubStatsCore

final class GitHubStatsCore: XCTestCase {
    override func setUpWithError() throws {
        throw XCTSkip("Replaced by RepoTests")
    }

    func testRepoInitWithSshUrl() throws {
        // Arrange
        let gitHubSshUrl = "git@github.com:apple/swift.git"
        
        // Act
        let repo = GitHubRepo(repoUrl: gitHubSshUrl)
        
        // Assert
        XCTAssertNotNil(repo)
    }
    
    func testRepoInitWithHttpUrl() throws {
        // Arrange
        let gitHubHttpUrl = "https://github.com/apple/swift.git"
        
        // Act
        let repo = GitHubRepo(repoUrl: gitHubHttpUrl)
        
        // Assert
        XCTAssertNotNil(repo)
    }
    
    func testRepoInitWithUrl() throws {
        // Arrange
        let gitHubUrl = URL(string: "https://github.com/apple/swift.git")!
        
        // Act
        let repo = GitHubRepo(url: gitHubUrl)
        
        // Assert
        XCTAssertNotNil(repo)
    }
}
