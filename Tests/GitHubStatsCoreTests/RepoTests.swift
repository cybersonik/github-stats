import XCTest
@testable import GitHubStatsCore

final class RepoTests: XCTestCase {
    func testRepoInitWithSshUrl() throws {
        // Arrange
        let gitHubSshUrl = "git@github.com:apple/swift.git"
        
        // Act
        let repo = Repo(repoUrl: gitHubSshUrl)
        
        // Assert
        XCTAssertNotNil(repo)
    }
    
    func testRepoInitWithHttpUrl() throws {
        // Arrange
        let gitHubHttpUrl = "https://github.com/apple/swift.git"
        
        // Act
        let repo = Repo(repoUrl: gitHubHttpUrl)
        
        // Assert
        XCTAssertNotNil(repo)
    }
    
    func testRepoInitWithUrl() throws {
        // Arrange
        let gitHubUrl = URL(string: "https://github.com/apple/swift.git")!
        
        // Act
        let repo = Repo(url: gitHubUrl)
        
        // Assert
        XCTAssertNotNil(repo)
    }
}
