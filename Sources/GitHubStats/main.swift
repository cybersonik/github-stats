// The Swift Programming Language
// https://docs.swift.org/swift-book
import GitHubStatsCore

print("Start…")

let gitHubStats = GitHubRepo(organization: "cybersonik", repo: "PhotoPicker")
try await gitHubStats.getPullRequests()

print("Finish…")
