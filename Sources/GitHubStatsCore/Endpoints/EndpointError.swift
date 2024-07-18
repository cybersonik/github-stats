//
//  EndpointError.swift
//  
//
//  Created by Jesse Wesson on 5/22/23.
//

import Foundation

public enum EndpointError: Error {
    case urlSessionError
    case rateLimitError(retryAfterSeconds: Int)
    case unsuccessfulResponseError(httpResponseStatusCode: Int, httpResponseBody: String?)
    case unknownError
}
