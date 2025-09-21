//
//  TestAPIViewModel.swift
//  OpenWeb-Development
//
//  Created by Alon Haiut on 31/08/2022.
//  Copyright © 2022 OpenWeb. All rights reserved.
//

import Foundation
import Combine
import CombineExt
import OpenWebSDK
#if !PUBLIC_DEMO_APP
import OpenWeb_SampleApp_Internal_Configs
#endif

protocol TestAPIViewModelingInputs {
    var enteredSpotId: PassthroughSubject<OWSpotId, Never> { get }
    var enteredPostId: PassthroughSubject<OWPostId, Never> { get }
    var uiFlowsTapped: PassthroughSubject<Void, Never> { get }
    var uiViewsTapped: PassthroughSubject<Void, Never> { get }
    var miscellaneousTapped: PassthroughSubject<Void, Never> { get }
    var testingPlaygroundTapped: PassthroughSubject<Void, Never> { get }
    var automationTapped: PassthroughSubject<Void, Never> { get }
    var selectPresetTapped: PassthroughSubject<Void, Never> { get }
    var doneSelectPresetTapped: PassthroughSubject<Void, Never> { get }
    var settingsTapped: PassthroughSubject<Void, Never> { get }
    var authenticationTapped: PassthroughSubject<Void, Never> { get }
    var selectedConversationPresetIndex: PassthroughSubject<Int, Never> { get }
    var viewWillAppear: PassthroughSubject<Void, Never> { get }
}

protocol TestAPIViewModelingOutputs {
    var title: String { get }
    var conversationPresets: AnyPublisher<[ConversationPreset], Never> { get }
    var shouldShowSelectPreset: AnyPublisher<Bool, Never> { get }
    // Usually the coordinator layer will handle this, however current architecture is missing a coordinator layer until we will do a propper refactor
    var openUIFlows: AnyPublisher<SDKConversationDataModel, Never> { get }
    var openUIViews: AnyPublisher<SDKConversationDataModel, Never> { get }
    var openMiscellaneous: AnyPublisher<SDKConversationDataModel, Never> { get }
    var openTestingPlayground: AnyPublisher<SDKConversationDataModel, Never> { get }
    var openAutomation: AnyPublisher<SDKConversationDataModel, Never> { get }
    var openSettings: AnyPublisher<Void, Never> { get }
    var openAuthentication: AnyPublisher<Void, Never> { get }
    var selectedSpotId: AnyPublisher<OWSpotId, Never> { get }
    var selectedPostId: AnyPublisher<OWPostId, Never> { get }
    var envLabelString: AnyPublisher<String, Never> { get }
    var isEnvLabelVisible: AnyPublisher<Bool, Never> { get }
    var configurationLabelString: AnyPublisher<String, Never> { get }
    var isConfigurationLabelVisible: AnyPublisher<Bool, Never> { get }
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

    private struct Metrics {
        #if PUBLIC_DEMO_APP
        static let preFilledSpotId: String = ConversationPreset.publicMainPreset().conversationDataModel.spotId
        static let preFilledPostId: String = ConversationPreset.publicMainPreset().conversationDataModel.postId
        #else
        static let preFilledSpotId: String = DevelopmentConversationPreset.demoSpot().conversationDataModel.spotId
        static let preFilledPostId: String = DevelopmentConversationPreset.demoSpot().conversationDataModel.postId
        #endif
    }

    private var cancellables = Set<AnyCancellable>()

    let enteredSpotId = PassthroughSubject<OWSpotId, Never>()
    let enteredPostId = PassthroughSubject<OWPostId, Never>()
    let uiFlowsTapped = PassthroughSubject<Void, Never>()
    let uiViewsTapped = PassthroughSubject<Void, Never>()
    let miscellaneousTapped = PassthroughSubject<Void, Never>()
    let testingPlaygroundTapped = PassthroughSubject<Void, Never>()
    let automationTapped = PassthroughSubject<Void, Never>()
    let selectPresetTapped = PassthroughSubject<Void, Never>()
    let settingsTapped = PassthroughSubject<Void, Never>()
    let authenticationTapped = PassthroughSubject<Void, Never>()
    let doneSelectPresetTapped = PassthroughSubject<Void, Never>()
    let viewWillAppear = PassthroughSubject<Void, Never>()

    private lazy var isBetaConfiguration: Bool = {
        #if BETA
        return true
        #else
        return false
        #endif
    }()

    private lazy var isBetaConfigurationSubject: CurrentValueSubject<Bool, Never> = {
        return CurrentValueSubject(value: isBetaConfiguration)
    }()

    var isEnvLabelVisible: AnyPublisher<Bool, Never> {
        return isBetaConfigurationSubject
            .eraseToAnyPublisher()
    }

    private var configurationString: String? {
        var configurationString = ""
        #if DEBUG && !PUBLIC_DEMO_APP
        configurationString.append(NSLocalizedString("ConfigurationDebug", comment: ""))
        #endif

        #if BETA || ADS
        configurationString.append(" | ")
        #endif

        #if BETA
        configurationString.append(NSLocalizedString("ConfigurationBeta", comment: ""))
        #elseif ADS
        configurationString.append(NSLocalizedString("ConfigurationAds", comment: ""))
        #endif
        return !configurationString.isEmpty ? configurationString : nil
    }

    private lazy var configurationStringSubject: CurrentValueSubject<String?, Never> = {
        return CurrentValueSubject(value: configurationString)
    }()

    var isConfigurationLabelVisible: AnyPublisher<Bool, Never> {
        return configurationStringSubject
            .map { $0 != nil }
            .eraseToAnyPublisher()
    }

    var envLabelString: AnyPublisher<String, Never> {
        return viewWillAppear
            .map {
                UserDefaultsProvider.shared.get(key: .networkEnvironment, defaultValue: OWNetworkEnvironment.production)
            }
            .map { env -> String? in
                switch env {
                case .production:
                    return nil // no label for production
                case .staging(let namespace):
                    return NSLocalizedString("Staging", comment: "") + " " + (namespace ?? "")
                case .cluster1d:
                    return NSLocalizedString("1DCluster", comment: "")
                case .custom(let url):
                    return NSLocalizedString("Custom", comment: "") + " " + (url ?? "")
                }

            }
            .map { envString in
                guard let envString else {
                    return ""
                }
                return NSLocalizedString("NetworkEnvironment", comment: "") + ": \(envString)"
            }
            .eraseToAnyPublisher()
    }

    var configurationLabelString: AnyPublisher<String, Never> {
        return viewWillAppear
            .flatMap {
                self.configurationStringSubject
            }
            .map { configurationString in
                guard let configurationString else {
                    return ""
                }
                return NSLocalizedString("BuildConfiguration", comment: "") + ": \(configurationString)"
            }
            .eraseToAnyPublisher()
    }

    var selectedSpotId: AnyPublisher<OWSpotId, Never> {
        return userDefaultsProvider.values(key: .selectedSpotId, defaultValue: Metrics.preFilledSpotId)
    }

    var selectedPostId: AnyPublisher<OWPostId, Never> {
        return userDefaultsProvider.values(key: .selectedPostId, defaultValue: Metrics.preFilledPostId)
    }

    private let _shouldShowSelectPreset = CurrentValueSubject<Bool, Never>(value: false)
    var shouldShowSelectPreset: AnyPublisher<Bool, Never> {
        return _shouldShowSelectPreset
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    private let _spotId = CurrentValueSubject<String, Never>(value: Metrics.preFilledSpotId)
    var spotId: AnyPublisher<String, Never> {
        return _spotId
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    private let _postId = CurrentValueSubject<String, Never>(value: Metrics.preFilledPostId)
    var postId: AnyPublisher<String, Never> {
        return _postId
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    private let _openUIFlows = PassthroughSubject<SDKConversationDataModel, Never>()
    var openUIFlows: AnyPublisher<SDKConversationDataModel, Never> {
        return _openUIFlows.eraseToAnyPublisher()
    }

    private let _openUIViews = PassthroughSubject<SDKConversationDataModel, Never>()
    var openUIViews: AnyPublisher<SDKConversationDataModel, Never> {
        return _openUIViews.eraseToAnyPublisher()
    }

    private let _openMiscellaneous = PassthroughSubject<SDKConversationDataModel, Never>()
    var openMiscellaneous: AnyPublisher<SDKConversationDataModel, Never> {
        return _openMiscellaneous.eraseToAnyPublisher()
    }

    private let _openTestingPlayground = PassthroughSubject<SDKConversationDataModel, Never>()
    var openTestingPlayground: AnyPublisher<SDKConversationDataModel, Never> {
        return _openTestingPlayground.eraseToAnyPublisher()
    }

    private let _openAutomation = PassthroughSubject<SDKConversationDataModel, Never>()
    var openAutomation: AnyPublisher<SDKConversationDataModel, Never> {
        return _openAutomation.eraseToAnyPublisher()
    }

    private let _openSettings = PassthroughSubject<Void, Never>()
    var openSettings: AnyPublisher<Void, Never> {
        return _openSettings.eraseToAnyPublisher()
    }

    private let _openAuthentication = PassthroughSubject<Void, Never>()
    var openAuthentication: AnyPublisher<Void, Never> {
        return _openAuthentication.eraseToAnyPublisher()
    }

    lazy var title: String = {
        return NSLocalizedString("TestAPI", comment: "")
    }()

    private let _selectedConversationPresetIndex = CurrentValueSubject(value: 0)
    var selectedConversationPresetIndex = PassthroughSubject<Int, Never>()

    private let _conversationPresets = CurrentValueSubject(value: ConversationPreset.mockModels)
    var conversationPresets: AnyPublisher<[ConversationPreset], Never> {
        return _conversationPresets
            .eraseToAnyPublisher()
    }

    private var userDefaultsProvider: UserDefaultsProviderProtocol

    init(userDefaultsProvider: UserDefaultsProviderProtocol = UserDefaultsProvider.shared) {
        self.userDefaultsProvider = userDefaultsProvider
        setupObservers()
    }
}

private extension TestAPIViewModel {
    func setupObservers() {
        enteredSpotId
            .removeDuplicates()
            .bind(to: _spotId)
            .store(in: &cancellables)

        enteredPostId
            .removeDuplicates()
            .bind(to: _postId)
            .store(in: &cancellables)

        _spotId
            .dropFirst(1)
            .bind(to: userDefaultsProvider.setValues(key: UserDefaultsProvider.UDKey<OWSpotId>.selectedSpotId))
            .store(in: &cancellables)

        _postId
            .dropFirst(1)
            .bind(to: userDefaultsProvider.setValues(key: UserDefaultsProvider.UDKey<OWPostId>.selectedPostId))
            .store(in: &cancellables)

        let conversationDataModelObservable =
        Publishers.CombineLatest(spotId, postId).map { spotId, postId -> SDKConversationDataModel in
            return SDKConversationDataModel(spotId: spotId, postId: postId)
        }.eraseToAnyPublisher()

        uiFlowsTapped
            .withLatestFrom(conversationDataModelObservable)
            .bind(to: _openUIFlows)
            .store(in: &cancellables)

        uiViewsTapped
            .withLatestFrom(conversationDataModelObservable)
            .bind(to: _openUIViews)
            .store(in: &cancellables)

        miscellaneousTapped
            .withLatestFrom(conversationDataModelObservable)
            .bind(to: _openMiscellaneous)
            .store(in: &cancellables)

        testingPlaygroundTapped
            .withLatestFrom(conversationDataModelObservable)
            .bind(to: _openTestingPlayground)
            .store(in: &cancellables)

        automationTapped
            .withLatestFrom(conversationDataModelObservable)
            .bind(to: _openAutomation)
            .store(in: &cancellables)

        selectPresetTapped
            .map { true }
            .bind(to: _shouldShowSelectPreset)
            .store(in: &cancellables)

        settingsTapped
            .bind(to: _openSettings)
            .store(in: &cancellables)

        authenticationTapped
            .bind(to: _openAuthentication)
            .store(in: &cancellables)

        Publishers.MergeMany(
            uiFlowsTapped.voidify(),
            uiViewsTapped.voidify(),
            miscellaneousTapped.voidify(),
            testingPlaygroundTapped.voidify(),
            automationTapped.voidify(),
            settingsTapped.voidify(),
            authenticationTapped.voidify(),
            enteredSpotId.voidify().dropFirst(1).eraseToAnyPublisher(),
            enteredPostId.voidify().dropFirst(1).eraseToAnyPublisher(),
            doneSelectPresetTapped.eraseToAnyPublisher()
        )
            .sink { [weak self] _ in
                self?._shouldShowSelectPreset.send(false)
            }
            .store(in: &cancellables)

        Publishers.MergeMany(
            settingsTapped.voidify(),
            uiFlowsTapped.voidify(),
            uiViewsTapped.voidify(),
            miscellaneousTapped.voidify(),
            testingPlaygroundTapped.voidify(),
            authenticationTapped.voidify()
        )
            .withLatestFrom(spotId)
            .sink { [weak self] spotId in
                self?.setSDKConfigurations(spotId)
            }
            .store(in: &cancellables)

        // Different conversation preset selected
        selectedConversationPresetIndex
            .bind(to: _selectedConversationPresetIndex)
            .store(in: &cancellables)

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
            .sink { [weak self] dataModel in
                self?._spotId.send(dataModel.spotId)
                self?._postId.send(dataModel.postId)
            }
            .store(in: &cancellables)
    }

    func setSDKConfigurations(_ spotId: String) {
        setupEnvironment() // env must be set before spotId because we fetch config right after spotId set
        let manager = OpenWeb.manager
        manager.spotId = spotId
        let customizations = manager.ui.customizations
        customizations.themeEnforcement = .themeStyle(fromIndex: UserDefaultsProvider.shared.get(key: .themeModeIndex, defaultValue: OWThemeStyleEnforcement.default.index))
        customizations.statusBarEnforcement = .statusBarStyle(fromIndex: UserDefaultsProvider.shared.get(key: .statusBarStyleIndex, defaultValue: OWStatusBarEnforcement.default.index))
        // swiftlint:disable line_length
        customizations.navigationBarEnforcement = .navigationBarEnforcement(fromIndex: UserDefaultsProvider.shared.get(key: .navigationBarStyleIndex, defaultValue: OWNavigationBarEnforcement.default.index))
        // swiftlint:enable line_length
        let sorting = customizations.sorting
        sorting.initialOption = .initialSort(fromIndex: UserDefaultsProvider.shared.get(key: .initialSortIndex, defaultValue: OWInitialSortStrategy.default.index))
        let sortTitles: [OWSortOption: String]? = UserDefaultsProvider.shared.get(key: .customSortTitles)
        for (key, title) in sortTitles ?? [:] {
            if title.isEmpty { continue }
            sorting.setTitle(title, forOption: key)
        }
        customizations.fontFamily = UserDefaultsProvider.shared.get(key: .fontGroupType, defaultValue: OWFontGroupFamily.default)
        let helpers = OpenWeb.manager.helpers
        helpers.languageStrategy = UserDefaultsProvider.shared.get(key: .languageStrategy, defaultValue: OWLanguageStrategy.default)
        helpers.localeStrategy = UserDefaultsProvider.shared.get(key: .localeStrategy, defaultValue: OWLocaleStrategy.default)
        helpers.orientationEnforcement = UserDefaultsProvider.shared.get(key: .orientationEnforcement, defaultValue: OWOrientationEnforcement.default)
        helpers.loggerConfiguration.level = .verbose
        helpers.loggerConfiguration.methods = [.nsLog]
        let authentication = OpenWeb.manager.authentication
        authentication.shouldDisplayLoginPrompt = UserDefaultsProvider.shared.get(key: .showLoginPrompt, defaultValue: false)
        customizations.commentActions.color = UserDefaultsProvider.shared.get(key: .commentActionsColor, defaultValue: OWCommentActionsColor.default)
        customizations.commentActions.fontStyle = UserDefaultsProvider.shared.get(key: .commentActionsFontStyle, defaultValue: OWCommentActionsFontStyle.default)
        ElementsCustomizationCreatorService.addElementsCustomization()
        ColorCustomizationService.setColorCustomization()

        setupBICallaback()
    }

    func setupBICallaback() {
        let analytics: OWAnalytics = OpenWeb.manager.analytics

        let BIClosure: OWBIAnalyticEventCallback = { event, additionalInfo, postId in
            DLog("Received BI Event: \(event), additional info: \(additionalInfo), postId: \(postId)")
        }
        analytics.addBICallback(BIClosure)
    }

    func setupEnvironment() {
        #if BETA
        let env = UserDefaultsProvider.shared.get(key: .networkEnvironment, defaultValue: OWNetworkEnvironment.production)
        let manager = OpenWeb.manager
        manager.environment = env.toSDKEnvironmentType
        #endif
    }
}
