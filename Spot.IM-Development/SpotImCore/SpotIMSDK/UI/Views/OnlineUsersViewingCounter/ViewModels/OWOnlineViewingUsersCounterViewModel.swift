//
//  OWOnlineViewingUsersCounterViewModel.swift
//  SpotImCore
//
//  Created by Alon Haiut on 13/12/2021.
//  Copyright © 2021 Spot.IM. All rights reserved.
//

import Foundation
import UIKit

protocol OWOnlineViewingUsersCounterViewModelingInputs {
    func configureModel(_ model: RealTimeOnlineViewingUsersModel)
}

protocol OWOnlineViewingUsersCounterViewModelingOutputs {
    var viewingCount: ((String) -> Void)? { get set }
    var image: UIImage { get }
}

protocol OWOnlineViewingUsersCounterViewModeling {
    var inputs: OWOnlineViewingUsersCounterViewModelingInputs { get }
    var outputs: OWOnlineViewingUsersCounterViewModelingOutputs { get set }
}

class OWOnlineViewingUsersCounterViewModel: OWOnlineViewingUsersCounterViewModeling, OWOnlineViewingUsersCounterViewModelingInputs, OWOnlineViewingUsersCounterViewModelingOutputs {
    var inputs: OWOnlineViewingUsersCounterViewModelingInputs { return self }
    var outputs: OWOnlineViewingUsersCounterViewModelingOutputs {
        get {
            return self
        }
        set(value) {
            // Do nothing
            // Current solution because we use closures. We won't need this when we will move to RxSwift / Combine
        }
    }
    
    fileprivate var model: RealTimeOnlineViewingUsersModel? {
        didSet {
            viewingCount?(model!.count.decimalFormatted)
        }
    }

    init (_ model: RealTimeOnlineViewingUsersModel) {
        configureModel(model)
    }
    
    // Allow creation without a model due to current limitations
    // Idealy we will never create a VM without a model or services
    init () {}

    // We will currently use closures with didSet combination until we will decide on a better soultion
    // I.e. RxSwift / Combine.
    var viewingCount: ((String) -> Void)?
    
    lazy var image: UIImage = {
        return UIImage(spNamed: "viewingUsers")!
    }()
    
    func configureModel(_ model: RealTimeOnlineViewingUsersModel) {
        self.model = model
    }
}
