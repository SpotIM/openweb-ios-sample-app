//
//  Bundle+SPExtensions.swift
//  Spot.IM-Core
//
//  Created by Itay Dressler on 16/08/2019.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import UIKit

extension Bundle {
    static let spot = Bundle(for: OWBundleToken.self)

    var shortVersion: String? {
        return self.infoDictionary?["CFBundleShortVersionString"] as? String
    }

    var bundleIdentifier: String? {
        return self.infoDictionary?[kCFBundleIdentifierKey as String] as? String
    }

    var cameraUsageDescription: String? {
        return self.infoDictionary?["NSCameraUsageDescription"] as? String
    }

    var hasCameraUsageDescription: Bool {
        return self.cameraUsageDescription != nil
    }

    var photoLibraryUsageDescription: String? {
        return self.infoDictionary?["NSPhotoLibraryUsageDescription"] as? String
    }

    var hasPhotoLibraryUsageDescription: Bool {
        return self.photoLibraryUsageDescription != nil
    }

    var displayName: String? {
        return self.infoDictionary?["CFBundleDisplayName"] as? String
    }

    var bundleName: String? {
        return self.infoDictionary?[kCFBundleNameKey as String] as? String
    }
}

private final class OWBundleToken {}
