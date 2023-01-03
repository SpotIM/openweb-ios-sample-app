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
    var doneSelectPresetTapped: PublishSubject<Void> { get }
    var settingsTapped: PublishSubject<Void> { get }
    var selectedConversationPresetIndex: PublishSubject<Int> { get }
}

protocol BetaNewAPIViewModelingOutputs {
    var title: String { get }
    var conversationPresets: Observable<[ConversationPreset]> { get }
    var spotId: Observable<String> { get }
    var postId: Observable<String> { get }
    var shouldShowSelectPreset: Observable<Bool> { get }
    // Usually the coordinator layer will handle this, however current architecture is missing a coordinator layer until we will do a propper refactor
    var openUIFlows: Observable<SDKConversationDataModel> { get }
    var openUIViews: Observable<SDKConversationDataModel> { get }
    var openMiscellaneous: Observable<SDKConversationDataModel> { get }
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
        static let preFilledSpotId: String = "sp_eCIlROSD"
        static let preFilledPostId: String = "sdk1"
    }
    
    fileprivate let disposeBag = DisposeBag()
    
    let enteredSpotId = PublishSubject<String>()
    let enteredPostId = PublishSubject<String>()
    let uiFlowsTapped = PublishSubject<Void>()
    let uiViewsTapped = PublishSubject<Void>()
    let miscellaneousTapped = PublishSubject<Void>()
    let selectPresetTapped = PublishSubject<Void>()
    let settingsTapped = PublishSubject<Void>()
    let doneSelectPresetTapped = PublishSubject<Void>()
    
    fileprivate let _shouldShowSelectPreset = BehaviorSubject<Bool>(value: false)
    var shouldShowSelectPreset: Observable<Bool> {
        return _shouldShowSelectPreset
            .distinctUntilChanged()
            .asObservable()
    }
    
    fileprivate let _spotId = BehaviorSubject<String>(value: Metrics.preFilledSpotId)
    var spotId: Observable<String> {
        return _spotId
            .asObservable()
    }
    
    fileprivate let _postId = BehaviorSubject<String>(value: Metrics.preFilledPostId)
    var postId: Observable<String> {
        return _postId
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
    
    fileprivate let _openMiscellaneous = PublishSubject<SDKConversationDataModel>()
    var openMiscellaneous: Observable<SDKConversationDataModel> {
        return _openMiscellaneous.asObservable()
    }
    
    fileprivate let _openSettings = PublishSubject<Void>()
    var openSettings: Observable<Void> {
        return _openSettings.asObservable()
    }
    
    lazy var title: String = {
        return NSLocalizedString("NewAPI", comment: "")
    }()
    
    fileprivate let _selectedConversationPresetIndex = BehaviorSubject(value: 0)
    var selectedConversationPresetIndex = PublishSubject<Int>()
    
    fileprivate let _conversationPresets = BehaviorSubject(value: ConversationPreset.mockModels)
    var conversationPresets: Observable<[ConversationPreset]> {
        return _conversationPresets
            .asObservable()
    }
    
    init() {
        setupObservers()
    }
}

fileprivate extension BetaNewAPIViewModel {
    func setupObservers() {
        enteredSpotId
            .bind(to: _spotId)
            .disposed(by: disposeBag)
        
        enteredPostId
            .bind(to: _postId)
            .disposed(by: disposeBag)
        
        let conversationDataModelObservable = Observable.combineLatest(spotId, postId) { spotId, postId -> SDKConversationDataModel in
            return SDKConversationDataModel(spotId: spotId, postId: postId)
        }.asObservable()
        
        uiFlowsTapped
            .withLatestFrom(conversationDataModelObservable)
            .bind(to: _openUIFlows)
            .disposed(by: disposeBag)
        
        uiViewsTapped
            .withLatestFrom(conversationDataModelObservable)
            .bind(to: _openUIViews)
            .disposed(by: disposeBag)
        
        miscellaneousTapped
            .withLatestFrom(conversationDataModelObservable)
            .bind(to: _openMiscellaneous)
            .disposed(by: disposeBag)
        
        selectPresetTapped
            .map { true }
            .bind(to: _shouldShowSelectPreset)
            .disposed(by: disposeBag)

        settingsTapped
            .bind(to: _openSettings)
            .disposed(by: disposeBag)
        
        Observable.merge(uiFlowsTapped.voidify(),
                         uiViewsTapped.voidify(),
                         miscellaneousTapped.voidify(),
                         settingsTapped.voidify(),
                         enteredSpotId.voidify(),
                         enteredPostId.voidify(),
                         doneSelectPresetTapped)
            .subscribe(onNext: { [weak self] _ in
                
                self?._shouldShowSelectPreset.onNext(false)
            })
            .disposed(by: disposeBag)
        
        Observable.merge(uiFlowsTapped.voidify(),
                         uiViewsTapped.voidify(),
                         miscellaneousTapped.voidify())
            .withLatestFrom(spotId)
            .subscribe(onNext: { [weak self] spotId in
                
                self?.setSDKSpotId(spotId)
            })
            .disposed(by: disposeBag)
        
        // Different conversation preset selected
        selectedConversationPresetIndex
            .bind(to: _selectedConversationPresetIndex)
            .disposed(by: disposeBag)
                
        doneSelectPresetTapped
            .withLatestFrom(_selectedConversationPresetIndex)
            .withLatestFrom(conversationPresets) { index, presets -> SDKConversationDataModel? in
                guard !presets.isEmpty else {
                    DLog("There isn't any conversation preset")
                    return nil
                }
                return presets[index].conversationDataModel
            }
            .unwrap()
            .do(onNext: { [weak self] dataModel in
                self?._spotId.onNext(dataModel.spotId)
                self?._postId.onNext(dataModel.postId)
            })
            .subscribe()
            .disposed(by: disposeBag)
            
    }
    
    func setSDKSpotId(_ spotId: String) {
        var manager = OpenWeb.manager
        manager.spotId = spotId
    }
}

#endif
