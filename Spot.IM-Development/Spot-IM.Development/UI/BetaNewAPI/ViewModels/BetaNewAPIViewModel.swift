//
//  BetaNewAPIViewModel.swift
//  Spot-IM.Development
//
//  Created by Alon Haiut on 31/08/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift
import SpotImCore

#if NEW_API

protocol BetaNewAPIViewModelingInputs {
    var enteredSpotId: PublishSubject<String> { get }
    var enteredPostId: PublishSubject<String> { get }
    var preConversationTapped: PublishSubject<Void> { get }
    var fullConversationTapped: PublishSubject<PresentationalModeCompact> { get }
    var commentCreationTapped: PublishSubject<PresentationalModeCompact> { get }
    var conversationCounterTapped: PublishSubject<Void> { get }
}

protocol BetaNewAPIViewModelingOutputs {
    var title: String { get }
    var preFilledSpotId: Observable<String> { get }
    var preFilledPostId: Observable<String> { get }
}

protocol BetaNewAPIViewModeling {
    var inputs: BetaNewAPIViewModelingInputs { get }
    var outputs: BetaNewAPIViewModelingOutputs { get }
}

class BetaNewAPIViewModel: BetaNewAPIViewModeling, BetaNewAPIViewModelingInputs, BetaNewAPIViewModelingOutputs {
    var inputs: BetaNewAPIViewModelingInputs { return self }
    var outputs: BetaNewAPIViewModelingOutputs { return self }
    
    fileprivate struct Metrics {
        static let preFilledSpotId: String? = "sp_eCIlROSD"
        static let preFilledPostId: String? = "sdk1"
    }
    
    fileprivate let disposeBag = DisposeBag()
    
    let enteredSpotId = PublishSubject<String>()
    let enteredPostId = PublishSubject<String>()
    let preConversationTapped = PublishSubject<Void>()
    let fullConversationTapped = PublishSubject<PresentationalModeCompact>()
    let commentCreationTapped = PublishSubject<PresentationalModeCompact>()
    let conversationCounterTapped = PublishSubject<Void>()
    
    fileprivate let _preFilledSpotId = BehaviorSubject<String?>(value: Metrics.preFilledSpotId)
    var preFilledSpotId: Observable<String> {
        return _preFilledSpotId
            .unwrap()
            .asObservable()
    }
    
    fileprivate let _preFilledPostId = BehaviorSubject<String?>(value: Metrics.preFilledPostId)
    var preFilledPostId: Observable<String> {
        return _preFilledPostId
            .unwrap()
            .asObservable()
    }
    
    lazy var title: String = {
        return NSLocalizedString("NewAPI", comment: "")
    }()
    
    fileprivate let spotId = BehaviorSubject<String>(value: "")
    fileprivate let postId = BehaviorSubject<String>(value: "")
    
    init() {
        setupObservers()
    }
}

fileprivate extension BetaNewAPIViewModel {
    func setupObservers() {
        Observable.merge(preFilledSpotId, enteredSpotId)
            .bind(to: spotId)
            .disposed(by: disposeBag)
        
        Observable.merge(preFilledPostId, enteredPostId)
            .bind(to: postId)
            .disposed(by: disposeBag)
        
    }
    
    func setSDKSpotId(_ spotId: String) {
        var manager = OpenWeb.manager
        manager.spotId = spotId
    }
}

#endif
