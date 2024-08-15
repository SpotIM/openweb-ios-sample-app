//
//  GeneralErrors.swift
//  OpenWeb-Development
//
//  Created by Alon Haiut on 26/03/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import Foundation

enum GeneralErrors: Error {
    case missingImplementation

    var description: String {
        switch self {
        case .missingImplementation:
            return "Error - Not implemented yet."
        }
    }
}
