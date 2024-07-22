//
//  FilterPredicate.swift
//  
//
//  Created by Jesse Wesson on 6/9/23.
//

import Foundation

public struct RequestFilter<Element> {
    public var maxResults: Int = 100

    public private(set) var filterFunction: ((Element) -> Bool)?

    private var additionalFilters: [String: String] = [:]

    public var queryParameters: [String: String] {
        var queryParameters = [String: String]()

        queryParameters.merge(additionalFilters) { _, new in new }

        return queryParameters
    }

    public init(maxResults: Int, additionalFilters: [String: String], filterFunction: ((Element) -> Bool)? = nil) {
        self.maxResults = maxResults
        self.additionalFilters = additionalFilters
        self.filterFunction = filterFunction
    }

    public init(additionalFilters: [String: String]) {
        self.additionalFilters = additionalFilters
    }
}
