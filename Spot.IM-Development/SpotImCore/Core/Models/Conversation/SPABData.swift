//
//  SPABData.swift
//  SpotImCore
//
//  Created by Eugene on 07.11.2019.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import Foundation

struct SPABData: Decodable {
    
    enum CodingKeys: String, CodingKey {
        case testName, group
    }
    
    let testName: String?
    let abTestGroup: ABGroup?
    private let group: String?
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        testName = try? container.decode(String.self, forKey: .testName)
        group = try? container.decode(String.self, forKey: .group)
        abTestGroup = ABGroup(rawValue: group ?? "")
    }
}
