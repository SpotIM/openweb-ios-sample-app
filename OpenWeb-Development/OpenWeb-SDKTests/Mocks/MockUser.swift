//
//  MockUser.swift
//  OpenWebCoreTests
//
//  Created by Philip Kluz on 2023-08-04.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

@testable import OpenWebSDK

struct MockUser: Codable, Equatable {
    var name: String
    var age: Int
}

extension MockUser {
    static func stub() -> MockUser {
        return MockUser(name: "John Doe", age: 30)
    }
}
