//
//  SPAdsConfiguration.swift
//  SpotImCore
//
//  Created by Eugene on 30.10.2019.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import Foundation

struct SPAdsConfiguration: Decodable {

    let success: Bool?
    let tags: [SPAdsConfigurationTag]?
    let geo: String?
    let monetizationId: String?
}

enum AdType: String, Encodable {
    case banner = "sdk_banner"
    case interstitial = "sdk_interstitial"
    case fullConversationBanner = "full_conv_sdk"
}

struct SPAdsConfigurationTag: Decodable {
    enum CodingKeys: String, CodingKey {

        case id, name, type, server, size, code, component

    }

    let id: String?
    let name: String?
    let type: String?
    let server: String?
    let size: String?
    let code: String?
    let adType: AdType?

    private let component: String?

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try? container.decode(String.self, forKey: .id)
        name = try? container.decode(String.self, forKey: .name)
        type = try? container.decode(String.self, forKey: .type)
        server = try? container.decode(String.self, forKey: .server)
        size = try? container.decode(String.self, forKey: .size)
        code = try? container.decode(String.self, forKey: .code)
        component = try? container.decode(String.self, forKey: .component)
        adType = AdType(rawValue: component ?? "missed_component")
    }
}
