//
//  SPSSOData.swift
//  SpotImCore
//
//  Created by Alon Shprung on 24/02/2021.
//  Copyright © 2021 Spot.IM. All rights reserved.
//

import Foundation

internal class SPSSOData: Codable {

    enum CodingKeys: String, CodingKey {
        case isSubscriber
    }
    var isSubscriber: Bool

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        isSubscriber = (try? container.decode(Bool.self, forKey: .isSubscriber)) ?? false
    }
}
