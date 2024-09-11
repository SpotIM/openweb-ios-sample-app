//
//  OWPresentationalMode.swift
//  OpenWebSDK
//
//  Created by Alon Haiut on 06/07/2022.
//  Copyright © 2022 OpenWeb. All rights reserved.
//

import UIKit

public enum OWPresentationalMode: Codable {
    case present(viewController: UIViewController, style: OWModalPresentationStyle = .pageSheet)
    case push(navigationController: UINavigationController)

    var style: OWPresentationalModeCompact {
        switch self {
        case .present(_, let style):
            return .present(style: style)
        case .push(_):
            return .push
        }
    }

    // Types to identify enum cases
    private enum CaseType: String, Codable {
        case present
        case push
    }

    // Coding keys to distinguish cases and store associated values
    private enum CodingKeys: String, CodingKey {
        case type
        case style
    }

    // Decoding initializer
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(CaseType.self, forKey: .type)

        switch type {
        case .present:
            let style = try container.decode(OWModalPresentationStyle.self, forKey: .style)
            // ViewController can't be decoded, so you'll need to pass a placeholder or handle this differently
            self = .present(viewController: UIViewController(), style: style)

        case .push:
            // NavigationController can't be decoded, so pass a placeholder or handle this differently
            self = .push(navigationController: UINavigationController())
        }
    }

    // Encoding method
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case .present(_, let style):
            try container.encode(CaseType.present, forKey: .type)
            try container.encode(style, forKey: .style)

        case .push:
            try container.encode(CaseType.push, forKey: .type)
            // No additional data to encode for push case
        }
    }
}

extension OWPresentationalMode: Equatable {
    public static func == (lhs: OWPresentationalMode, rhs: OWPresentationalMode) -> Bool {
        switch (lhs, rhs) {
        case (.present(_, let lhsStyle), .present(_, let rhsStyle)):
            return lhsStyle == rhsStyle
        case (.push, .push):
            return true
        default:
            return false
        }
    }
}
