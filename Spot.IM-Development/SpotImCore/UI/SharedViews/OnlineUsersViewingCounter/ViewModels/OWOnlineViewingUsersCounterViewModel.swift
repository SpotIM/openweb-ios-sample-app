//
//  OWOnlineViewingUsersCounterViewModel.swift
//  SpotImCore
//
//  Created by Alon Haiut on 13/12/2021.
//  Copyright © 2021 Spot.IM. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

protocol OWOnlineViewingUsersCounterViewModelingInputs {
    // TODO: once old view is removed this configureModel function should be removed
    func configureModel(_ model: RealTimeOnlineViewingUsersModel)
}

protocol OWOnlineViewingUsersCounterViewModelingOutputs {
    var viewingCount: Observable<String> { get }
    var image: UIImage { get }
}

protocol OWOnlineViewingUsersCounterViewModeling {
    var inputs: OWOnlineViewingUsersCounterViewModelingInputs { get }
    var outputs: OWOnlineViewingUsersCounterViewModelingOutputs { get }
}

class OWOnlineViewingUsersCounterViewModel: OWOnlineViewingUsersCounterViewModeling, OWOnlineViewingUsersCounterViewModelingInputs, OWOnlineViewingUsersCounterViewModelingOutputs {
    var inputs: OWOnlineViewingUsersCounterViewModelingInputs { return self }
    var outputs: OWOnlineViewingUsersCounterViewModelingOutputs { return self }

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

// New VM using new services
class OWOnlineViewingUsersCounterViewModelNew: OWOnlineViewingUsersCounterViewModeling, OWOnlineViewingUsersCounterViewModelingInputs, OWOnlineViewingUsersCounterViewModelingOutputs {
    var inputs: OWOnlineViewingUsersCounterViewModelingInputs { return self }
    var outputs: OWOnlineViewingUsersCounterViewModelingOutputs { return self }

    var viewingCount: Observable<String> {
        guard let postId = OWManager.manager.postId else { return .empty()}

        return OWSharedServicesProvider.shared.realtimeService().realtimeData
            .map { realtimeData in
                try? realtimeData.data?.onlineViewingUsersCount("\(OWManager.manager.spotId)_\(postId)")
            }
            .unwrap()
            .map { max($0.count, 1) }
            .map {
                $0.decimalFormatted
            }
            .asObservable()
    }

    lazy var image: UIImage = {
        return UIImage(spNamed: "viewingUsers", supportDarkMode: false)!
    }()

    // TODO: once old view is removed this configureModel function should be removed
    func configureModel(_ model: RealTimeOnlineViewingUsersModel) {
    }
}
