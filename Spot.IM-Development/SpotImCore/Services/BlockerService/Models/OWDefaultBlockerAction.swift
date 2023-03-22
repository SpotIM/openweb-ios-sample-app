//
//  OWDefaultBlockerAction.swift
//  SpotImCore
//
//  Created by Alon Haiut on 14/03/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

class OWDefaultBlockerAction: OWBlockerActionProtocol {
    let blockerType: OWBlockerActionType
    var completion: OWBasicCompletion {
        return _completion
    }

    fileprivate var _completion: OWBasicCompletion!

    init(blockerType: OWBlockerActionType) {
        self.blockerType = blockerType
        setupCompletion()
    }
}

fileprivate extension OWDefaultBlockerAction {
    func setupCompletion() {
        _completion = { [weak self] in
            self?.finish()
        }
    }
}
