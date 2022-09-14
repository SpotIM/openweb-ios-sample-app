//
//  OWArticleSettingsProtocol.swift
//  SpotImCore
//
//  Created by Alon Haiut on 05/09/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation

#if NEW_API
public protocol OWArticleSettingsProtocol {
    var section: String { get }
    var showHeader: Bool { get }
    var readOnlyMode: OWReadOnlyMode { get }
}
#else
protocol OWArticleSettingsProtocol {
    var section: String { get }
    var showHeader: Bool { get }
    var readOnlyMode: OWReadOnlyMode { get }
}
#endif
