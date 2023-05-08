// The Swift Programming Language
// https://docs.swift.org/swift-book
import ArgumentParser
import GitHubStatsCore


@main
struct GitHubStats: AsyncParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "A utility for query the GitHub REST API.",
        subcommands: [GitHubPRStats.self],
        defaultSubcommand: GitHubPRStats.self)
    
    @OptionGroup var options: GitHubStatsOptions
    
    func validate() throws {
        if !(options.url != nil || (options.organization != nil && options.repo != nil)) {
            throw ValidationError("Please provide either a GitHub URL or a GitHub organization and repo.")
        }
    }
}

struct GitHubStatsOptions: ParsableArguments {
    @Option(name: .shortAndLong, help: "The GitHub URL to target.")
    var url: String?
    
    @Option(name: .shortAndLong, help: "The GitHub organization to target.")
    var organization: String?
    
    @Option(name: .shortAndLong, help: "The repo to target.")
    var repo: String?
}

extension GitHubStats {
    struct GitHubPRStats: AsyncParsableCommand {
        static var configuration = CommandConfiguration(abstract: "Get the PRs from a repo.")
        
        @OptionGroup var options: GitHubStatsOptions
        
        mutating func run() async throws {
            print("Start…")
            
            if let url = options.url {
                if let gitHubStats = GitHubRepo(repoUrl: url) {
                    let pullRequests = try await gitHubStats.getPullRequests()
                    print("Pull Requests:")
                    pullRequests.forEach({ print("\t\($0.id): \($0.title)") })
                }
            } else if let organization = options.organization, let repo = options.repo {
                let gitHubStats = GitHubRepo(organization: organization, repo: repo)
                let openPullRequests = try await gitHubStats.getPullRequests(limit: 100)
                print("Open Pull Requests:")
                openPullRequests.forEach({ print("\t\($0.id): \($0.title)") })
            }
            else {
                throw ExitCode.validationFailure
            }
            
            print("Finish…")
        }
    }
}
