//
//  EndpointError.swift
//  
//
//  Created by Jesse Wesson on 5/22/23.
//

import Foundation

public enum EndpointError: Error {
    case urlSessionError
    case unsuccessfulResponseError(httpResponseStatusCode: Int)
    case unknownError
}
