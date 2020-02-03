//
//  SPABData.swift
//  SpotImCore
//
//  Created by Eugene on 07.11.2019.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import Foundation

internal enum ABGroup: String, CaseIterable {
    case first = "A"
    case second = "B"
    case third = "C"
    case fourth = "D"
}

struct AbTests: Decodable {
    private let activeTests: [String] = ["33"]
    enum CodingKeys: String, CodingKey {
        case abData
    }
    
    let tests: [SPABData]
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.tests = try container.decode([SPABData].self, forKey: .abData)
    }
    
    init() {
        tests = []
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
    let abTestGroup: ABGroup?
    let group: String
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        testName = try container.decode(String.self, forKey: .testName)
        group = try container.decode(String.self, forKey: .group)
        abTestGroup = ABGroup(rawValue: group)
    }
}
