//
//  SPOnlineViewingUsersCounterViewModel.swift
//  SpotImCore
//
//  Created by Alon Haiut on 13/12/2021.
//  Copyright © 2021 Spot.IM. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

protocol SPOnlineViewingUsersCounterViewModelingInputs {
    func configureModel(_ model: RealTimeOnlineViewingUsersModel)
}

protocol SPOnlineViewingUsersCounterViewModelingOutputs {
    var viewingCount: Observable<String> { get }
    var image: UIImage { get }
}

protocol SPOnlineViewingUsersCounterViewModeling {
    var inputs: SPOnlineViewingUsersCounterViewModelingInputs { get }
    var outputs: SPOnlineViewingUsersCounterViewModelingOutputs { get }
}

class SPOnlineViewingUsersCounterViewModel: SPOnlineViewingUsersCounterViewModeling,
                                                SPOnlineViewingUsersCounterViewModelingInputs,
                                                SPOnlineViewingUsersCounterViewModelingOutputs {
    var inputs: SPOnlineViewingUsersCounterViewModelingInputs { return self }
    var outputs: SPOnlineViewingUsersCounterViewModelingOutputs { return self }

    fileprivate var model = BehaviorSubject<RealTimeOnlineViewingUsersModel?>(value: nil)

    init (_ model: RealTimeOnlineViewingUsersModel) {
        configureModel(model)
    }

    // Allow creation without a model due to current limitations
    // Idealy we will never create a VM without a model or services
    init () {}

    var viewingCount: Observable<String> {
        return model.unwrap()
            .map { max($0.count, 1) }
            .map { $0.decimalFormatted }
    }

    lazy var image: UIImage = {
        return UIImage(spNamed: "viewingUsers", supportDarkMode: false)!
    }()

    func configureModel(_ model: RealTimeOnlineViewingUsersModel) {
        self.model.onNext(model)
    }
}
