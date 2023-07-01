//
//  EndpointFactory.swift
//  
//
//  Created by Jesse Wesson on 5/22/23.
//

import Foundation

public struct EndpointFactory {
    private let repo: Repo

    init(organization: String, name: String) {
        self.repo = Repo(organization: organization, name: name)
    }

    init(repo: Repo) {
        self.repo = repo
    }

    public func makeGitHubSession(for endpoint: Endpoints) -> EndpointSession {
        switch endpoint {
            case .pulls:
                let request = EndpointRequest(repo: repo, path: "pulls")
                let session = EndpointSession(endpointRequest: request)
                return session
        }
    }
}
