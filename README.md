# github-stats

A simple CLI for querying GitHub's REST API written in Swift using the _new_ concurrency model.

## Accessing GitHub API

In order to access the GitHub REST API, you will need a personal access token. You can learn how to create these access tokens
[here](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token). Once
created, set an environment variable named `TEST_GITHUB_TOKEN` to this value and `github-stats` will read it from there. 
