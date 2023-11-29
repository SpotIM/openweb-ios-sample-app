//
//  TestAPIViewModel.swift
//  Spot-IM.Development
//
//  Created by Alon Haiut on 31/08/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift
import SpotImCore

protocol TestAPIViewModelingInputs {
    var enteredSpotId: PublishSubject<String> { get }
    var enteredPostId: PublishSubject<String> { get }
    var uiFlowsTapped: PublishSubject<Void> { get }
    var uiViewsTapped: PublishSubject<Void> { get }
    var miscellaneousTapped: PublishSubject<Void> { get }
    var testingPlaygroundTapped: PublishSubject<Void> { get }
    var automationTapped: PublishSubject<Void> { get }
    var selectPresetTapped: PublishSubject<Void> { get }
    var doneSelectPresetTapped: PublishSubject<Void> { get }
    var settingsTapped: PublishSubject<Void> { get }
    var authenticationTapped: PublishSubject<Void> { get }
    var selectedConversationPresetIndex: PublishSubject<Int> { get }
}

protocol TestAPIViewModelingOutputs {
    var title: String { get }
    var conversationPresets: Observable<[ConversationPreset]> { get }
    var spotId: Observable<String> { get }
    var postId: Observable<String> { get }
    var shouldShowSelectPreset: Observable<Bool> { get }
    // Usually the coordinator layer will handle this, however current architecture is missing a coordinator layer until we will do a propper refactor
    var openUIFlows: Observable<SDKConversationDataModel> { get }
    var openUIViews: Observable<SDKConversationDataModel> { get }
    var openMiscellaneous: Observable<SDKConversationDataModel> { get }
    var openTestingPlayground: Observable<SDKConversationDataModel> { get }
    var openAutomation: Observable<SDKConversationDataModel> { get }
    var openSettings: Observable<Void> { get }
    var openAuthentication: Observable<Void> { get }
}

protocol TestAPIViewModeling {
    var inputs: TestAPIViewModelingInputs { get }
    var outputs: TestAPIViewModelingOutputs { get }
}

class TestAPIViewModel: TestAPIViewModeling,
                           TestAPIViewModelingInputs,
                           TestAPIViewModelingOutputs {
    var inputs: TestAPIViewModelingInputs { return self }
    var outputs: TestAPIViewModelingOutputs { return self }

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
    let testingPlaygroundTapped = PublishSubject<Void>()
    let automationTapped = PublishSubject<Void>()
    let selectPresetTapped = PublishSubject<Void>()
    let settingsTapped = PublishSubject<Void>()
    let authenticationTapped = PublishSubject<Void>()
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
            .distinctUntilChanged()
            .asObservable()
    }

    fileprivate let _postId = BehaviorSubject<String>(value: Metrics.preFilledPostId)
    var postId: Observable<String> {
        return _postId
            .distinctUntilChanged()
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

    fileprivate let _openTestingPlayground = PublishSubject<SDKConversationDataModel>()
    var openTestingPlayground: Observable<SDKConversationDataModel> {
        return _openTestingPlayground.asObservable()
    }

    fileprivate let _openAutomation = PublishSubject<SDKConversationDataModel>()
    var openAutomation: Observable<SDKConversationDataModel> {
        return _openAutomation.asObservable()
    }

    fileprivate let _openSettings = PublishSubject<Void>()
    var openSettings: Observable<Void> {
        return _openSettings.asObservable()
    }

    fileprivate let _openAuthentication = PublishSubject<Void>()
    var openAuthentication: Observable<Void> {
        return _openAuthentication.asObservable()
    }

    lazy var title: String = {
        return NSLocalizedString("TestAPI", comment: "")
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

fileprivate extension TestAPIViewModel {
    func setupObservers() {
        enteredSpotId
            .distinctUntilChanged()
            .bind(to: _spotId)
            .disposed(by: disposeBag)

        enteredPostId
            .distinctUntilChanged()
            .bind(to: _postId)
            .disposed(by: disposeBag)

        let conversationDataModelObservable =
        Observable.combineLatest(spotId, postId) { spotId, postId -> SDKConversationDataModel in
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

        testingPlaygroundTapped
            .withLatestFrom(conversationDataModelObservable)
            .bind(to: _openTestingPlayground)
            .disposed(by: disposeBag)

        automationTapped
            .withLatestFrom(conversationDataModelObservable)
            .bind(to: _openAutomation)
            .disposed(by: disposeBag)

        selectPresetTapped
            .map { true }
            .bind(to: _shouldShowSelectPreset)
            .disposed(by: disposeBag)

        settingsTapped
            .bind(to: _openSettings)
            .disposed(by: disposeBag)

        authenticationTapped
            .bind(to: _openAuthentication)
            .disposed(by: disposeBag)

        Observable.merge(uiFlowsTapped.voidify(),
                         uiViewsTapped.voidify(),
                         miscellaneousTapped.voidify(),
                         testingPlaygroundTapped.voidify(),
                         automationTapped.voidify(),
                         settingsTapped.voidify(),
                         authenticationTapped.voidify(),
                         enteredSpotId.voidify().skip(1),
                         enteredPostId.voidify().skip(1),
                         doneSelectPresetTapped)
            .subscribe(onNext: { [weak self] _ in

                self?._shouldShowSelectPreset.onNext(false)
            })
            .disposed(by: disposeBag)

        Observable.merge(settingsTapped.voidify(),
                         uiFlowsTapped.voidify(),
                         uiViewsTapped.voidify(),
                         miscellaneousTapped.voidify(),
                         testingPlaygroundTapped.voidify())
            .withLatestFrom(spotId)
            .subscribe(onNext: { [weak self] spotId in

                self?.setSDKConfigurations(spotId)
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

    func setSDKConfigurations(_ spotId: String) {
        var manager = OpenWeb.manager
        manager.spotId = spotId
        var customizations = manager.ui.customizations
        // swiftlint:disable line_length
        customizations.themeEnforcement = .themeStyle(fromIndex: UserDefaultsProvider.shared.get(key: .themeModeIndex, defaultValue: OWThemeStyleEnforcement.default.index))
        // swiftlint:disable line_length
        customizations.statusBarEnforcement = .statusBarStyle(fromIndex: UserDefaultsProvider.shared.get(key: .statusBarStyleIndex, defaultValue: OWStatusBarEnforcement.default.index))
        // swiftlint:disable line_length
        customizations.navigationBarEnforcement = .navigationBarEnforcement(fromIndex: UserDefaultsProvider.shared.get(key: .navigationBarStyleIndex, defaultValue: OWNavigationBarEnforcement.default.index))
        // swiftlint:enable line_length
        var sorting = customizations.sorting
        sorting.initialOption = .initialSort(fromIndex: UserDefaultsProvider.shared.get(key: .initialSortIndex, defaultValue: OWInitialSortStrategy.default.index))
        customizations.fontFamily = UserDefaultsProvider.shared.get(key: .fontGroupType, defaultValue: OWFontGroupFamily.default)
        var helpers = OpenWeb.manager.helpers
        helpers.languageStrategy = UserDefaultsProvider.shared.get(key: .languageStrategy, defaultValue: OWLanguageStrategy.default)
        helpers.localeStrategy = UserDefaultsProvider.shared.get(key: .localeStrategy, defaultValue: OWLocaleStrategy.default)
        helpers.orientationEnforcement = UserDefaultsProvider.shared.get(key: .orientationEnforcement, defaultValue: OWOrientationEnforcement.default)
        var authentication = OpenWeb.manager.authentication
        authentication.shouldDisplayLoginPrompt = UserDefaultsProvider.shared.get(key: .showLoginPrompt, defaultValue: false)

        ElementsCustomizationCreatorService.addElementsCustomization()
        setupBICallaback()
    }

    func setupBICallaback() {
        let analytics: OWAnalytics = OpenWeb.manager.analytics

        let BIClosure: OWBIAnalyticEventCallback = { event, additionalInfo, postId in
            DLog("Received BI Event: \(event), additional info: \(additionalInfo), postId: \(postId)")
        }

        analytics.addBICallback(BIClosure)
    }
}
