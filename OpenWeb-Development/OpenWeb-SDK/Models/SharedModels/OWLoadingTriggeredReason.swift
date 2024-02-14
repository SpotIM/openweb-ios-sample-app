//
//  OWLoadingTriggeredReason.swift
//  SpotImCore
//
//  Created by Alon Haiut on 13/09/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import Foundation

enum OWLoadingTriggeredReason {
    case initialLoading
    case pullToRefresh
    case sortingChanged
    case tryAgainAfterError
    case forceRefresh
}
