//
//  OWFilterTabsSelectedTab.swift
//  OpenWebSDK
//
//  Created by Refael Sommer on 24/06/2024.
//  Copyright © 2024 OpenWeb. All rights reserved.
//

import Foundation

enum OWFilterTabsSelectedTab: Equatable {
    case none
    case tab(OWFilterTabsCollectionCellViewModel)

    static func == (lhs: OWFilterTabsSelectedTab, rhs: OWFilterTabsSelectedTab) -> Bool {
        switch (lhs, rhs) {
        case (.none, .none):
            return true
        case (.tab(let selectedTabVMlhs), .tab(let selectedTabVMrhs)):
            return selectedTabVMlhs.outputs.tabId == selectedTabVMrhs.outputs.tabId
        default:
            return false
        }
    }
}
