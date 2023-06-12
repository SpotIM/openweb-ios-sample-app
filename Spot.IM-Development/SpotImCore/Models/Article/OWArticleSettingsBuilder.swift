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
    public var showHeader: Bool
    public var readOnlyMode: OWReadOnlyMode

    public init(section: String,
                showHeader: Bool = true,
                readOnlyMode: OWReadOnlyMode = .default) {
        self.section = section
        self.showHeader = showHeader
        self.readOnlyMode = readOnlyMode
    }

    @discardableResult public mutating func section(_ section: String) -> OWArticleSettingsBuilder {
        self.section = section
        return self
    }

    @discardableResult public mutating func showHeader(_ showHeader: Bool) -> OWArticleSettingsBuilder {
        self.showHeader = showHeader
        return self
    }

    @discardableResult public mutating func readOnlyMode(_ readOnlyMode: OWReadOnlyMode) -> OWArticleSettingsBuilder {
        self.readOnlyMode = readOnlyMode
        return self
    }

    public func build() -> OWArticleSettingsProtocol {
        return OWArticleSettings(section: section,
                                 showHeader: showHeader,
                                 readOnlyMode: readOnlyMode)
    }
}
#else
struct OWArticleSettingsBuilder {
    var section: String
    var showHeader: Bool
    var readOnlyMode: OWReadOnlyMode

    init(section: String,
         showHeader: Bool = true,
         readOnlyMode: OWReadOnlyMode = .default) {
        self.section = section
        self.showHeader = showHeader
        self.readOnlyMode = readOnlyMode
    }

    @discardableResult mutating func section(_ section: String) -> OWArticleSettingsBuilder {
        self.section = section
        return self
    }

    @discardableResult mutating func showHeader(_ showHeader: Bool) -> OWArticleSettingsBuilder {
        self.showHeader = showHeader
        return self
    }

    @discardableResult mutating func readOnlyMode(_ readOnlyMode: OWReadOnlyMode) -> OWArticleSettingsBuilder {
        self.readOnlyMode = readOnlyMode
        return self
    }

    func build() -> OWArticleSettingsProtocol {
        return OWArticleSettings(section: section,
                                 showHeader: showHeader,
                                 readOnlyMode: readOnlyMode)
    }
}
#endif
