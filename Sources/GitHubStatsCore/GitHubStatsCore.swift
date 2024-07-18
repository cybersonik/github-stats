// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
import RegexBuilder

public enum GitHubStats: Error {
    case basic
}

public class GitHubRepo {
    static let gitHubUrlRegex = #/^git@github\.com:(?<org>[\w\-\.]+)/(?<repo>[\w\-\.]+)$/#

    var organization: String
    var repo: String
    var urlBuilder = URLComponents()

    public convenience init?(repoUrl: String) {
        if let match = repoUrl.wholeMatch(of: Self.gitHubUrlRegex) {
            let (_, org, repo) = match.output

		    self.init(organization: String(org), repo: String(repo))
        } else if let url = URL(string: repoUrl) {
            self.init(url: url)
        }

        return nil
    }

    public convenience init?(url: URL) {
        guard url.pathComponents.count >= 2 else {
            return nil
        }

        let pathComponents = url.pathComponents
        let lastTwoComponents = pathComponents[1...2]
        let organization = lastTwoComponents.first!
        let repo = lastTwoComponents.last!

        self.init(organization: organization, repo: repo)
    }

    public init(organization: String, repo: String) {
        self.organization = organization

		let gitExtension = ".git"
		let repoName = repo.hasSuffix(gitExtension) ? String(repo.dropLast(gitExtension.count)) : repo
        self.repo = repoName

        self.urlBuilder.scheme = "https"
        self.urlBuilder.host = "api.github.com"
        self.urlBuilder.path = "/repos/\(self.organization)/\(self.repo)"
    }

    @available(*, deprecated, message: "Use Repo.getPullRequests(filter:) instead")
    public func getPullRequests(filter: RequestFilter<PullRequest>) async throws -> [PullRequest] {
        let factory = EndpointFactory(organization: organization, name: repo)
        let session = factory.makeGitHubSession(for: .pulls)
        let pullRequests: [PullRequest] = try await session.callEndpoint(filter: filter)

        return pullRequests
    }
}
