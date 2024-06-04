//
//  OWFilterTabsEndpoints.swift
//  OpenWebSDK
//
//  Created by Refael Sommer on 29/05/2024.
//  Copyright © 2024 OpenWeb. All rights reserved.
//

import Foundation

enum OWFilterTabsEndpoints: OWEndpoints {
    case getTabs

    // MARK: - HTTPMethod
    var method: OWNetworkHTTPMethod {
        switch self {
        case .getTabs:
            return .get
        }
    }

    // MARK: - Path
    var path: String {
        switch self {
        case .getTabs:
            return "/conversation/tab/metadata"
        }
    }

    // MARK: - Parameters
    var parameters: OWNetworkParameters? {
        switch self {
        case .getTabs:
            return nil
        }
    }
}

protocol OWFilterTabsAPI {
    func getTabs() -> OWNetworkResponse<OWFilterTabsResponse>
}

extension OWNetworkAPI: OWFilterTabsAPI {
    // Access by .filterTabs for readability
    var filterTabs: OWFilterTabsAPI { return self }

    func getTabs() -> OWNetworkResponse<OWFilterTabsResponse> {
        let endpoint = OWFilterTabsEndpoints.getTabs
        let requestConfigure = request(for: endpoint)
        return performRequest(route: requestConfigure)
    }
}
