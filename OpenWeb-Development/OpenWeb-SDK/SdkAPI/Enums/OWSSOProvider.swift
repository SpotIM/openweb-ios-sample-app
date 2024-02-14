//
//  OWSSOProvider.swift
//  SpotImCore
//
//  Created by Alon Haiut on 19/03/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import Foundation

public enum OWSSOProvider: String {
    case janrain
    case gigya
    case piano
    case auth0
    case foxid
    case hearst
}

internal extension OWSSOProvider {
    func parameters(token: String) -> OWNetworkParameters {
        return ["provider": self.rawValue, "token": token]
    }
}
