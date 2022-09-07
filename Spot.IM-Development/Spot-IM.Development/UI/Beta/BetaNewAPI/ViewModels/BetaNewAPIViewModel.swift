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
    var preConversationTapped: PublishSubject<PresentationalModeCompact> { get }
    var fullConversationTapped: PublishSubject<PresentationalModeCompact> { get }
    var commentCreationTapped: PublishSubject<PresentationalModeCompact> { get }
    var conversationCounterTapped: PublishSubject<Void> { get }
}

protocol BetaNewAPIViewModelingOutputs {
    var title: String { get }
    var preFilledSpotId: Observable<String> { get }
    var preFilledPostId: Observable<String> { get }
    // Usually the coordinator layer will handle this, however current architecture is missing a coordinator layer until we will do a propper refactor
    var openMockArticleScreen: Observable<SDKUIFlowActionSettings> { get }
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
    let preConversationTapped = PublishSubject<PresentationalModeCompact>()
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
    
    fileprivate let _openMockArticleScreen = BehaviorSubject<SDKUIFlowActionSettings?>(value: nil)
    var openMockArticleScreen: Observable<SDKUIFlowActionSettings> {
        return _openMockArticleScreen
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
        
        let fullConversationTappedModel = fullConversationTapped
            .withLatestFrom(postId) { mode, postId -> SDKUIFlowActionSettings in
                let action = SDKUIFlowActionType.fullConversation(presentationalMode: mode)
                let model = SDKUIFlowActionSettings(postId: postId, actionType: action)
                return model
            }
        
        let commentCreationTappedModel = commentCreationTapped
            .withLatestFrom(postId) { mode, postId -> SDKUIFlowActionSettings in
                let action = SDKUIFlowActionType.commentCreation(presentationalMode: mode)
                let model = SDKUIFlowActionSettings(postId: postId, actionType: action)
                return model
            }
        
        let preConversationTappedModel = preConversationTapped
            .withLatestFrom(postId) { mode, postId -> SDKUIFlowActionSettings in
                let action = SDKUIFlowActionType.preConversation(presentationalMode: mode)
                let model = SDKUIFlowActionSettings(postId: postId, actionType: action)
                return model
            }
        
        Observable.merge(fullConversationTappedModel, commentCreationTappedModel, preConversationTappedModel)
            .bind(to: _openMockArticleScreen)
            .disposed(by: disposeBag)
    }
    
    func setSDKSpotId(_ spotId: String) {
        var manager = OpenWeb.manager
        manager.spotId = spotId
    }
}

#endif
