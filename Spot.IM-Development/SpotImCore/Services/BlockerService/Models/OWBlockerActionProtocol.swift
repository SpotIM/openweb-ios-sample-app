//
//  OWBlockerActionProtocol.swift
//  SpotImCore
//
//  Created by Alon Haiut on 14/03/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

protocol OWBlockerActionProtocol {
    var blockerType: OWBlockerActionType { get }
    func finish()
}

extension OWBlockerActionProtocol {
    func finish() {
        let blockerService = OWSharedServicesProvider.shared.blockerServicing()
        blockerService.removeBlocker(perType: self.blockerType)
    }
}
