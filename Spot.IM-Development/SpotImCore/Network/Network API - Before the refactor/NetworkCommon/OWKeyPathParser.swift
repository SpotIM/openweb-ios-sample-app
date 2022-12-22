//
//  KeyPathParser.swift
//  APIClient
//

import Foundation

public typealias JSON = [String: Any]

public enum OWParserError: Error {
    
    case keyNotFound
    
}

internal class OWKeyPathParser {
    
    private let keyPath: String?
    
    public init(keyPath: String? = nil) {
        self.keyPath = keyPath
    }
    
    internal func valueForKeyPath(in object: Any) throws -> Any {
        if let keyPath = keyPath, let dictionary = object as? JSON {
            if let value = dictionary[keyPath] {
                return value
            }
            throw OWParserError.keyNotFound
        } else {
            return object
        }
    }
    
}
