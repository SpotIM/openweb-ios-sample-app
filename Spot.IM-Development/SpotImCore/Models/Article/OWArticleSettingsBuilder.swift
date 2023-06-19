//
//  OWArticleSettingsBuilder.swift
//  SpotImCore
//
//  Created by Alon Haiut on 16/05/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

#if NEW_API
public struct OWArticleSettingsBuilder {
    public var section: String
    public var headerStyle: OWArticleHeaderStyle
    public var readOnlyMode: OWReadOnlyMode

    public init(section: String,
                headerStyle: OWArticleHeaderStyle = .regular,
                readOnlyMode: OWReadOnlyMode = .server) {
        self.section = section
        self.headerStyle = headerStyle
        self.readOnlyMode = readOnlyMode
    }

    @discardableResult public mutating func section(_ section: String) -> OWArticleSettingsBuilder {
        self.section = section
        return self
    }

    @discardableResult public mutating func showHeader(_ headerStyle: OWArticleHeaderStyle) -> OWArticleSettingsBuilder {
        self.headerStyle = headerStyle
        return self
    }

    @discardableResult public mutating func readOnlyMode(_ readOnlyMode: OWReadOnlyMode) -> OWArticleSettingsBuilder {
        self.readOnlyMode = readOnlyMode
        return self
    }

    public func build() -> OWArticleSettingsProtocol {
        return OWArticleSettings(section: section,
                                 headerStyle: headerStyle,
                                 readOnlyMode: readOnlyMode)
    }
}
#else
struct OWArticleSettingsBuilder {
    var section: String
    var headerStyle: OWArticleHeaderStyle
    var readOnlyMode: OWReadOnlyMode

    init(section: String,
         headerStyle: OWArticleHeaderStyle = .regular,
         readOnlyMode: OWReadOnlyMode = .server) {
        self.section = section
        self.showHeader = showHeader
        self.readOnlyMode = readOnlyMode
    }

    @discardableResult mutating func section(_ section: String) -> OWArticleSettingsBuilder {
        self.section = section
        return self
    }

    @discardableResult mutating func showHeader(_ headerStyle: OWArticleHeaderStyle) -> OWArticleSettingsBuilder {
        self.headerStyle = headerStyle
        return self
    }

    @discardableResult mutating func readOnlyMode(_ readOnlyMode: OWReadOnlyMode) -> OWArticleSettingsBuilder {
        self.readOnlyMode = readOnlyMode
        return self
    }

    func build() -> OWArticleSettingsProtocol {
        return OWArticleSettings(section: section,
                                 headerStyle: headerStyle,
                                 readOnlyMode: readOnlyMode)
    }
}
#endif
