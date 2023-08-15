//
//  OWLayoutStyle.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 12/07/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

enum OWLayoutStyle: String {
    case push = "push"
    case presentFull = "present_full"
    case pageSheet = "present_page_sheet"
    case view = "view"
    case none = "none"

    init(from presentationalStyle: OWPresentationalModeCompact) {
        switch presentationalStyle {
        case .present(style: let style):
            switch style {
            case .fullScreen:
                self = .presentFull
            case .pageSheet:
                self = .pageSheet
            }
        case .push:
            self = .push
        case .none:
            self = .view
        }
    }
}
