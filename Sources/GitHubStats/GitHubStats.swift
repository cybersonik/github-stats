// The Swift Programming Language
// https://docs.swift.org/swift-book
import ArgumentParser
import GitHubStatsCore

@main
internal struct GitHubStats: AsyncParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "githubstats",
        abstract: "A utility for query the GitHub REST API.",
        subcommands: [GitHubPRStats.self],
        defaultSubcommand: GitHubPRStats.self)

    @OptionGroup var options: GitHubStatsOptions

    func validate() throws {
        if options.makeRepo() == nil {
            throw ValidationError("Please provide either a GitHub URL or a GitHub organization and repo.")
        }
    }
}

internal struct GitHubStatsOptions: ParsableArguments {
    @Option(name: .shortAndLong, help: "The GitHub URL to target.")
    var url: String?

    @Option(name: .shortAndLong, help: "The GitHub organization to target.")
    var organization: String?

    @Option(name: .shortAndLong, help: "The repo to target.")
    var repo: String?

    @Option(name: .shortAndLong, help: "The maximum number of results to retrieve.")
    var max: Int?

    // create a Repo object from the options
    func makeRepo() -> Repo? {
        if let url = url {
            return Repo(repoUrl: url)
        } else if let organization = organization, let repoName = repo {
            return Repo(organization: organization, name: repoName)
        } else {
            return nil
        }
    }
}

extension GitHubStats {
    struct GitHubPRStats: AsyncParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "get-prs",
            abstract: "Get the PRs from a repo.")

        @OptionGroup var options: GitHubStatsOptions

        @Option(name: .shortAndLong, help: "The state of the PR.")
        var state: PullRequest.State?

        @Option(name: .shortAndLong, help: "The author of the PR.")
        var author: String?

        mutating func run() async throws {
            print("Start…")

            if let repo = options.makeRepo() {
                var pullRequestFilterFactory = PullRequestFilterFactory()
                if let state {
                    pullRequestFilterFactory.state = state
                }
                if let author {
                    pullRequestFilterFactory.author = author
                }
                if let max = options.max {
                    pullRequestFilterFactory.maxResults = max
                }

                let filter = pullRequestFilterFactory.makeRequestFilter()

                let openPullRequests = try await repo.getPullRequests(filter: filter)
                print("Pull Requests:")
                openPullRequests.forEach({ print("\t\($0.id): \($0.title)") })
            }

            print("Finish…")
        }
    }
}
