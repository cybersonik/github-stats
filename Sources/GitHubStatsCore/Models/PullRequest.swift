//
//  PullRequest.swift
//  
//
//  Created by Jesse Wesson on 5/22/23.
//

import Foundation
import ArgumentParser

public struct PullRequest: GitHubObject {
    public var id: Int
    public var number: Int
    public var title: String
    public var state: State
    public var body: String?
    public var user: User
    public var assignees: [User]

    public enum State: String, Codable, ExpressibleByArgument {
        case open
        case closed
        case all
    }
}
