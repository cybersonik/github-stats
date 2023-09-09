//
//  EndpointEnvironment.swift
//
//
//  Created by Jesse Wesson on 10/18/23.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

internal enum EndpointEnvironment {
    static var urlSessionConfiguration = URLSessionConfiguration.default
}
