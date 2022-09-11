//
//  OWArticleSettings.swift
//  SpotImCore
//
//  Created by Alon Haiut on 07/09/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation

#if NEW_API
public struct OWArticleSettings: OWArticleSettingsProtocol {
    public let section: String
    public let showHeader: Bool
    public let readOnlyMode: OWReadOnlyMode
    
    public init(section: String,
                showHeader: Bool = true,
                readOnlyMode: OWReadOnlyMode = .default) {
        self.section = section
        self.showHeader = showHeader
        self.readOnlyMode = readOnlyMode
    }
}
#else
struct OWArticleSettings: OWArticleSettingsProtocol {
    let section: String
    let showHeader: Bool
    let readOnlyMode: OWReadOnlyMode
    
    init(section: String,
                showHeader: Bool = true,
                readOnlyMode: OWReadOnlyMode = .default) {
        self.section = section
        self.showHeader = showHeader
        self.readOnlyMode = readOnlyMode
    }
}
#endif
