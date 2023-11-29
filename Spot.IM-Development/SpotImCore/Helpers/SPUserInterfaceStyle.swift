//
//  SPUserInterfaceStyle.swift
//  Spot.IM-Core
//
//  Created by Andriy Fedin on 18/06/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import UIKit
import RxSwift

public enum SPUserInterfaceStyle: Int {

    case light
    case dark

    @available(iOS 12.0, *)
    var nativeValue: UIUserInterfaceStyle {
        switch self {
        case .dark:
            return .dark
        default:
            return .light
        }
    }

    static var isDarkMode: Bool {
        return OWSharedServicesProvider.shared.themeStyleService().currentStyle == .dark
    }
}
