//
//  UIDevice+Extensions.swift
//  Spot.IM-Core
//
//  Created by Andriy Fedin on 02/10/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import UIKit

internal extension UIDevice {

    static func modelIdentifier() -> String {
        if let simulatorModelIdentifier = ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] {
            return simulatorModelIdentifier
        }
        var sysinfo = utsname()
        uname(&sysinfo) // ignore return value
        let data = Data(bytes: &sysinfo.machine, count: Int(_SYS_NAMELEN))
        if let deviceModel = String(bytes: data, encoding: .ascii) {
            return deviceModel.trimmingCharacters(in: .controlCharacters)
        } else {
            return "Unknown model"
        }
    }

    func deviceTypeXPlatformHeader() -> String {
        switch self.userInterfaceIdiom {
        case .unspecified:
            return "ios_unspecified"
        case .phone:
            return "ios_phone"
        case .pad:
            return "ios_tablet"
        case .tv:
            return "ios_tv"
        case .carPlay:
            return "ios_car"
        case .mac:
            return "mac"
        @unknown default:
            return "unsuppoted new value " + String(self.userInterfaceIdiom.rawValue)
        }
    }

    // MARK: Screen sizes
    var iPhoneX: Bool { UIScreen.main.nativeBounds.height == 2436 }
    var iPhone: Bool { UIDevice.current.userInterfaceIdiom == .phone }
    var iPad: Bool { UIDevice().userInterfaceIdiom == .pad }
    enum ScreenType: String {
        case iPhones_4_4S = "iPhone 4 or iPhone 4S"
        case iPhones_5_5s_5c_SE = "iPhone 5, iPhone 5s, iPhone 5c or iPhone SE"
        case iPhones_6_6s_7_8 = "iPhone 6, iPhone 6S, iPhone 7 or iPhone 8"
        case iPhones_6Plus_6sPlus_7Plus_8Plus = "iPhone 6 Plus, iPhone 6S Plus, iPhone 7 Plus or iPhone 8 Plus"
        case iPhones_X_XS = "iPhone X or iPhone XS"
        case iPhone_XR_11 = "iPhone XR or iPhone 11"
        case iPhone_XSMax_ProMax = "iPhone XS Max or iPhone Pro Max"
        case iPhone_11Pro = "iPhone 11 Pro"
        case unknown
    }
    var screenType: ScreenType {
        switch UIScreen.main.nativeBounds.height {
        case 1136:
            return .iPhones_5_5s_5c_SE
        case 1334:
            return .iPhones_6_6s_7_8
        case 1792:
            return .iPhone_XR_11
        case 1920, 2208:
            return .iPhones_6Plus_6sPlus_7Plus_8Plus
        case 2426:
            return .iPhone_11Pro
        case 2436:
            return .iPhones_X_XS
        case 2688:
            return .iPhone_XSMax_ProMax
        default:
            return .unknown
        }
    }

     var hasNotch: Bool {
           if #available(iOS 11.0, *) {
               // Case 1: Portrait && top safe area inset >= 44
               let case1 = !UIDevice.current.orientation.isLandscape && (UIApplication.shared.keyWindow?.safeAreaInsets.top ?? 0) >= 44
               // Case 2: Lanscape && left/right safe area inset > 0
               let case2 = UIDevice.current.orientation.isLandscape && ((UIApplication.shared.keyWindow?.safeAreaInsets.left ?? 0) > 0 || (UIApplication.shared.keyWindow?.safeAreaInsets.right ?? 0) > 0)

               return case1 || case2
           } else {
               // Fallback on earlier versions
               return false
           }
       }

    func isPortrait() -> Bool {
        return UIScreen.main.bounds.width < UIScreen.main.bounds.height
    }
}
