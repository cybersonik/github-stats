// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation

public class GitHubRepo {
    
    let token = ProcessInfo.processInfo.environment["GITHUB_TOKEN"] ?? ""

    var organization: String
    var repo: String
    var urlBuilder: URLComponents = URLComponents()

    public init(organization: String, repo: String) {
        self.organization = organization
        self.repo = repo

        urlBuilder.scheme = "https"
        urlBuilder.host = "api.github.com"
    }

    public func getPullRequests() async throws {
       urlBuilder.path = "/repos/\(organization)/\(repo)/pulls"

        guard let pullRequestsURL = urlBuilder.url else {
            return
        }

        var request = URLRequest(url: pullRequestsURL)
        request.httpMethod = "GET"
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("2022-11-28", forHTTPHeaderField: "X-GitHub-Api-Version")
    
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            print("response = \(response)")
            let json = String(data: data, encoding: .utf8)
            let result: [String: String] = try JSONDecoder().decode([String: String].self, from: data)
        } catch {
            print("error")
        }
    }
}