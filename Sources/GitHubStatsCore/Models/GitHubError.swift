//
//  GitHubError.swift
//  
//
//  Created by Jesse Wesson on 6/29/24.
//

import Foundation

public struct GitHubError: GitHubObject {
    public var message: String
    // swiftlint:disable:next identifier_name
    public var documentation_url: URL
    public var status: String
}
