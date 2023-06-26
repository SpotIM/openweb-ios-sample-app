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
    public let headerStyle: OWArticleHeaderStyle
    public let readOnlyMode: OWReadOnlyMode

    public init(section: String,
                headerStyle: OWArticleHeaderStyle = .regular,
                readOnlyMode: OWReadOnlyMode = .server) {
        self.section = section
        self.headerStyle = headerStyle
        self.readOnlyMode = readOnlyMode
    }
}
#else
struct OWArticleSettings: OWArticleSettingsProtocol {
    let section: String
    let headerStyle: OWArticleHeaderStyle
    let readOnlyMode: OWReadOnlyMode

    init(section: String,
         headerStyle: OWArticleHeaderStyle = .regular,
         readOnlyMode: OWReadOnlyMode = .server) {
        self.section = section
        self.headerStyle = headerStyle
        self.readOnlyMode = readOnlyMode
    }
}
#endif
