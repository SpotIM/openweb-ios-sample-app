//
//  MockUser.swift
//  OpenWebCoreTests
//
//  Created by Philip Kluz on 2023-08-04.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

@testable import SpotImCore

struct MockUser: Codable, Equatable {
    var name: String
    var age: Int
}
