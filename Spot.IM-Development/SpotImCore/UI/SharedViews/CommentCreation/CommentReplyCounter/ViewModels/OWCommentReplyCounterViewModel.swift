//
//  OWCommentReplyCounterViewModel.swift
//  SpotImCore
//
//  Created by Alon Shprung on 26/06/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

protocol OWCommentReplyCounterViewModelingInputs {
    var commentTextCount: BehaviorSubject<Int> { get }
}

protocol OWCommentReplyCounterViewModelingOutputs {
    var counterText: Observable<String> { get }
    var showCounter: Observable<Bool> { get }
}

protocol OWCommentReplyCounterViewModeling {
    var inputs: OWCommentReplyCounterViewModelingInputs { get }
    var outputs: OWCommentReplyCounterViewModelingOutputs { get }
}

class OWCommentReplyCounterViewModel: OWCommentReplyCounterViewModeling,
                                        OWCommentReplyCounterViewModelingInputs,
                                        OWCommentReplyCounterViewModelingOutputs {

    var inputs: OWCommentReplyCounterViewModelingInputs { return self }
    var outputs: OWCommentReplyCounterViewModelingOutputs { return self }

    fileprivate let servicesProvider: OWSharedServicesProviding

    var commentTextCount = BehaviorSubject<Int>(value: 0)

    var counterText: Observable<String> {
        Observable.combineLatest(commentTextCount, servicesProvider.spotConfigurationService().config(spotId: OWManager.manager.spotId)) { count, config in
            return "\(count)/\(config.mobileSdk.commentCounterCharactersLimit)"
        }
    }

    var showCounter: Observable<Bool> {
        servicesProvider.spotConfigurationService()
            .config(spotId: OWManager.manager.spotId)
            .map { config -> Bool in
                config.mobileSdk.shouldShowCommentCounter
            }
            .share(replay: 1)
    }

    init(servicesProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared) {
        self.servicesProvider = servicesProvider
    }
}
