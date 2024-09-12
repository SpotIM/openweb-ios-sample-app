//
//  Bundle+Extensions.swift
//  OpenWeb-SampleApp-Internal-Configs
//
//  Created by Alon Haiut on 21/08/2024.
//  Copyright © 2024 OpenWeb. All rights reserved.
//

import Foundation

public extension Bundle {
    static let openWebInternalConfigs = Bundle(for: InternalConfigsBundleToken.self)
}

private class InternalConfigsBundleToken {}
