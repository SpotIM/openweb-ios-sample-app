//
//  OnlineUsersViewingCounterViewModel.swift
//  SpotImCore
//
//  Created by Alon Haiut on 13/12/2021.
//  Copyright © 2021 Spot.IM. All rights reserved.
//

import Foundation
import UIKit

protocol OnlineUsersViewingCounterViewModelingInputs {
    func configureModel(_ model: RealTimeOnlineUsersViewingModel)
}

protocol OnlineUsersViewingCounterViewModelingOutputs {
    var viewingCount: ((Int) -> Void)? { get }
    var image: UIImage { get }
    var text: String { get }
}

protocol OnlineUsersViewingCounterViewModeling {
    var inputs: OnlineUsersViewingCounterViewModelingInputs { get }
    var outputs: OnlineUsersViewingCounterViewModelingOutputs { get }
}

class OnlineUsersViewingCounterViewModel: OnlineUsersViewingCounterViewModeling, OnlineUsersViewingCounterViewModelingInputs, OnlineUsersViewingCounterViewModelingOutputs {
    
    var inputs: OnlineUsersViewingCounterViewModelingInputs { return self }
    var outputs: OnlineUsersViewingCounterViewModelingOutputs { return self }
    
    fileprivate var model: RealTimeOnlineUsersViewingModel? {
        didSet {
            viewingCount?(model!.count)
        }
    }

    init (_ model: RealTimeOnlineUsersViewingModel) {
        configureModel(model)
    }
    
    // Allow creation without a model due to current limitations
    // Idealy we will never create a VM without a model
    init () {}

    // We will currently use closures with didSet combination until we will decide on a better soultion
    // I.e. RxSwift / Combine.
    var viewingCount: ((Int) -> Void)?
    
    lazy var text: String = {
        return LocalizationManager.localizedString(key: "Viewing")
    }()
    
    lazy var image: UIImage = {
        return UIImage()
    }()
    
    func configureModel(_ model: RealTimeOnlineUsersViewingModel) {
        self.model = model
    }
}
