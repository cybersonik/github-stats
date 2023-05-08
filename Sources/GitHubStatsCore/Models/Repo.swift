//
//  Repo.swift
//  
//
//  Created by Jesse Wesson on 5/22/23.
//

import Foundation

public struct Repo {
    public let organization: String
    public let name: String

    init?(repoUrl: String) {
        if let match = repoUrl.wholeMatch(of: GitHubConstants.gitHubUrlRegex){
            let (_, org, repo) = match.output

            self.init(organization: String(org), name: String(repo))
        } else if let url = URL(string: repoUrl) {
            self.init(url: url)
        }

        return nil
    }

    init?(url: URL) {
        guard url.pathComponents.count >= 2 else {
            return nil
        }

        let pathComponents = url.pathComponents
        let lastTwoComponents = pathComponents[1...2]
        let organization = lastTwoComponents.first!
        let repo = lastTwoComponents.last!

        self.init(organization: organization, name: repo)
    }

    public init(organization: String, name: String) {
        self.organization = organization

        let nameWithoutExtension = name.hasSuffix(GitHubConstants.gitRepoExtension)
                                    ? String(name.dropLast(GitHubConstants.gitRepoExtension.count))
                                    : name
        self.name = nameWithoutExtension
    }
}
