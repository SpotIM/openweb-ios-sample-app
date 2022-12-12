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
    var uiFlowsTapped: PublishSubject<Void> { get }
    var uiViewsTapped: PublishSubject<Void> { get }
    var miscellaneousTapped: PublishSubject<Void> { get }
    var selectPresetTapped: PublishSubject<Void> { get }
    var settingsTapped: PublishSubject<Void> { get }
}

protocol BetaNewAPIViewModelingOutputs {
    var title: String { get }
    var preFilledSpotId: Observable<String> { get }
    var preFilledPostId: Observable<String> { get }
    // Usually the coordinator layer will handle this, however current architecture is missing a coordinator layer until we will do a propper refactor
    var openUIFlows: Observable<SDKConversationDataModel> { get }
    var openUIViews: Observable<SDKConversationDataModel> { get }
    var openMiscellaneous: Observable<Void> { get }
    var showSelectPreset: Observable<Void> { get }
    var openSettings: Observable<Void> { get }
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
    let uiFlowsTapped = PublishSubject<Void>()
    let uiViewsTapped = PublishSubject<Void>()
    let miscellaneousTapped = PublishSubject<Void>()
    let selectPresetTapped = PublishSubject<Void>()
    let settingsTapped = PublishSubject<Void>()
    
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
    
    fileprivate let _openUIFlows = PublishSubject<SDKConversationDataModel>()
    var openUIFlows: Observable<SDKConversationDataModel> {
        return _openUIFlows.asObservable()
    }
    
    fileprivate let _openUIViews = PublishSubject<SDKConversationDataModel>()
    var openUIViews: Observable<SDKConversationDataModel> {
        return _openUIViews.asObservable()
    }
    
    fileprivate let _openMiscellaneous = PublishSubject<Void>()
    var openMiscellaneous: Observable<Void> {
        return _openMiscellaneous.asObservable()
    }
    
    fileprivate let _showSelectPreset = PublishSubject<Void>()
    var showSelectPreset: Observable<Void> {
        return _showSelectPreset.asObservable()
    }
    
    fileprivate let _openSettings = PublishSubject<Void>()
    var openSettings: Observable<Void> {
        return _openSettings.asObservable()
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
        
        uiFlowsTapped
            .withLatestFrom(spotId)
            .withLatestFrom(postId) { [weak self] spotId, postId -> SDKConversationDataModel in
                self?.setSDKSpotId(spotId)
                return SDKConversationDataModel(postId: postId, spotId: spotId)
            }
            .bind(to: _openUIFlows)
            .disposed(by: disposeBag)
        
        uiViewsTapped
            .withLatestFrom(spotId)
            .withLatestFrom(postId) { [weak self] spotId, postId -> SDKConversationDataModel in
                self?.setSDKSpotId(spotId)
                return SDKConversationDataModel(postId: postId, spotId: spotId)
            }
            .bind(to: _openUIViews)
            .disposed(by: disposeBag)
        
        miscellaneousTapped
            .bind(to: _openMiscellaneous)
            .disposed(by: disposeBag)
        
        selectPresetTapped
            .bind(to: _showSelectPreset)
            .disposed(by: disposeBag)

        settingsTapped
            .bind(to: _openSettings)
            .disposed(by: disposeBag)
    }
    
    func setSDKSpotId(_ spotId: String) {
        var manager = OpenWeb.manager
        manager.spotId = spotId
    }
}

#endif
