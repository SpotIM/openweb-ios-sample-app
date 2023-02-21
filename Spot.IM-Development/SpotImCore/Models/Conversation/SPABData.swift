//
//  SPABData.swift
//  SpotImCore
//
//  Created by Eugene on 07.11.2019.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import Foundation

internal enum OWABGroup: String, CaseIterable {
    case first = "A"
    case second = "B"
    case third = "C"
    case fourth = "D"
}

struct OWAbTests: Decodable {
    private let activeTests: [String] = ["33"]
    enum CodingKeys: String, CodingKey {
        case abData
    }

    let tests: [SPABData]

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.tests = try container.decode([SPABData].self, forKey: .abData)
    }

    init(tests: [SPABData]) {
        self.tests = tests
    }

    func getActiveTests() -> [SPABData] {
        return tests.filter { (testData) -> Bool in
            activeTests.contains(testData.testName)
        }
    }
}

struct SPABData: Decodable {
    enum CodingKeys: String, CodingKey {
        case testName, group
    }

    let testName: String
    let abTestGroup: OWABGroup?
    let group: String

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        testName = try container.decode(String.self, forKey: .testName)
        group = try container.decode(String.self, forKey: .group)
        abTestGroup = OWABGroup(rawValue: group)
    }

    init(testName: String, group: String) {
        self.testName = testName
        self.group = group
        self.abTestGroup = OWABGroup(rawValue: group)
    }
}
