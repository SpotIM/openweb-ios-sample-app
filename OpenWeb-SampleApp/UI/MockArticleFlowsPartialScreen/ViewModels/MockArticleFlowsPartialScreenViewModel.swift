//
//  MockArticleFlowsPartialScreenViewModel.swift
//  OpenWeb-SampleApp
//
//  Created by Alon Shprung on 22/10/2025.
//

import Foundation
import UIKit
import Combine
import OpenWebSDK
#if !PUBLIC_DEMO_APP
import OpenWeb_SampleApp_Internal_Configs
#endif

protocol MockArticleFlowsPartialScreenViewModelingInputs {
    func setPresentationalVC(_ viewController: UIViewController)
}

protocol MockArticleFlowsPartialScreenViewModelingOutputs {
    var title: String { get }
    var showPreConversation: AnyPublisher<UIView, Never> { get }
    var showWrappedConversation: AnyPublisher<(UIViewController, PresentationalModeCompact), Never> { get }
    var showFullConversation: AnyPublisher<UIViewController, Never> { get }
    var articleImageURL: AnyPublisher<URL, Never> { get }
    var showError: AnyPublisher<String, Never> { get }
    var loggerViewModel: UILoggerViewModeling { get }
    var floatingViewViewModel: OWFloatingViewModeling { get }
    var loggerEnabled: AnyPublisher<Bool, Never> { get }
}

protocol MockArticleFlowsPartialScreenViewModeling {
    var inputs: MockArticleFlowsPartialScreenViewModelingInputs { get }
    var outputs: MockArticleFlowsPartialScreenViewModelingOutputs { get }
}

class MockArticleFlowsPartialScreenViewModel: MockArticleFlowsPartialScreenViewModeling, MockArticleFlowsPartialScreenViewModelingInputs, MockArticleFlowsPartialScreenViewModelingOutputs {
    var inputs: MockArticleFlowsPartialScreenViewModelingInputs { return self }
    var outputs: MockArticleFlowsPartialScreenViewModelingOutputs { return self }

    lazy var loggerViewModel: UILoggerViewModeling = {
        return UILoggerViewModel(title: "Flows Logger")
    }()

    lazy var floatingViewViewModel: OWFloatingViewModeling = {
        return OWFloatingViewModel()
    }()

    private var _loggerEnabled = CurrentValueSubject<Bool, Never>(value: false)
    var loggerEnabled: AnyPublisher<Bool, Never> {
        _loggerEnabled
            .eraseToAnyPublisher()
    }

    private var cancellables = Set<AnyCancellable>()

    private let imageProviderAPI: ImageProviding
    private let silentSSOAuthentication: SilentSSOAuthenticationNewAPIProtocol

    private weak var presentationalVC: UIViewController?

    private let _articleImageURL = CurrentValueSubject<URL?, Never>(value: nil)
    var articleImageURL: AnyPublisher<URL, Never> {
        return _articleImageURL
            .unwrap()
            .eraseToAnyPublisher()
    }

    private let userDefaultsProvider: UserDefaultsProviderProtocol
    private let commonCreatorService: CommonCreatorServicing

    private let _actionSettings = CurrentValueSubject<SDKUIFlowPartialScreenActionSettings?, Never>(value: nil)
    private var actionSettings: AnyPublisher<SDKUIFlowPartialScreenActionSettings, Never> {
        return _actionSettings
            .unwrap()
            .eraseToAnyPublisher()
    }

    init(userDefaultsProvider: UserDefaultsProviderProtocol = UserDefaultsProvider.shared,
         silentSSOAuthentication: SilentSSOAuthenticationNewAPIProtocol = SilentSSOAuthenticationNewAPI(),
         commonCreatorService: CommonCreatorServicing = CommonCreatorService(),
         imageProviderAPI: ImageProviding = ImageProvider(),
         actionSettings: SDKUIFlowPartialScreenActionSettings) {
        self.imageProviderAPI = imageProviderAPI
        self.silentSSOAuthentication = silentSSOAuthentication
        self.commonCreatorService = commonCreatorService
        self.userDefaultsProvider = userDefaultsProvider
        _actionSettings.send(actionSettings)
        setupBICallaback()
        setupObservers()
    }

    private let _showError = PassthroughSubject<String, Never>()
    var showError: AnyPublisher<String, Never> {
        return _showError
            .eraseToAnyPublisher()
    }

    private let _showPreConversation = PassthroughSubject<UIView, Never>()
    var showPreConversation: AnyPublisher<UIView, Never> {
        return _showPreConversation
            .eraseToAnyPublisher()
    }

    private let _showWrappedConversation = PassthroughSubject<(UIViewController, PresentationalModeCompact), Never>()
    var showWrappedConversation: AnyPublisher<(UIViewController, PresentationalModeCompact), Never> {
        return _showWrappedConversation
            .eraseToAnyPublisher()
    }

    private let _showFullConversation = PassthroughSubject<UIViewController, Never>()
    var showFullConversation: AnyPublisher<UIViewController, Never> {
        return _showFullConversation
            .eraseToAnyPublisher()
    }

    private lazy var actionsCallbacks: OWPreConversationActionsCallbacks = { [weak self] callbackType, postId in
        guard let self else { return }

        let log = "Received OWPreConversationActionsCallbacks type: \(callbackType), postId: \(postId)\n"
        DLog(log)
        switch callbackType {
        case .openConversationFlow(let route):
            self.handleConversationFlow(route: route, postId: postId)
        default:
            break
        }
    }

    lazy var title: String = {
        return NSLocalizedString("MockArticle", comment: "")
    }()

    func setPresentationalVC(_ viewController: UIViewController) {
        presentationalVC = viewController
    }
}

private extension MockArticleFlowsPartialScreenViewModel {
    // swiftlint:disable function_body_length
    func setupObservers() {
        let articleURL = imageProviderAPI.randomImageUrl()
        _articleImageURL.send(articleURL)

        userDefaultsProvider.values(key: .flowsLoggerEnabled, defaultValue: false)
            .bind(to: _loggerEnabled)
            .store(in: &cancellables)

        // Pre conversation
        actionSettings
            .compactMap { settings -> String? in
                if case .preConversationToFullConversation = settings.actionType {
                    return settings.postId
                } else {
                    return nil
                }
            }
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] postId in
                guard let self else { return }

                let manager = OpenWeb.manager
                let views = manager.ui.views

                let additionalSettings = self.commonCreatorService.additionalSettings()
                let article = self.commonCreatorService.mockArticle(for: manager.spotId)

                if shouldUseAsyncAwaitCallingMethod() {
                    Task { @MainActor [weak self] in
                        guard let self else { return }
                        do {
                            let preConversationView = try await views.preConversation(
                                postId: postId,
                                article: article,
                                additionalSettings: additionalSettings,
                                callbacks: actionsCallbacks
                            )
                            self._showPreConversation.send(preConversationView)
                        } catch {
                            let message = error.localizedDescription
                            DLog("Calling views.preConversation error: \(error)")
                            _showError.send(message)
                        }
                    }
                } else {
                    views.preConversation(postId: postId,
                                          article: article,
                                          additionalSettings: additionalSettings,
                                          callbacks: actionsCallbacks) { result in
                        switch result {
                        case .success(let preConversationView):
                            self._showPreConversation.send(preConversationView)
                        case .failure(let error):
                            let message = error.description
                            DLog("Calling views.preConversation error: \(error)")
                            self._showError.send(message)
                        }
                    }
                }
            })
            .store(in: &cancellables)

        // Conversation-based flows (full conversation, comment creation, comment thread)
        actionSettings
            .compactMap { settings -> String? in
                if case .fullConversation = settings.actionType {
                    return settings.postId
                } else {
                    return nil
                }
            }
            .withLatestFrom(loggerEnabled) { postId, loggerEnabled -> (String, Bool) in
                return (postId, loggerEnabled)
            }
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] result in
                guard let self else { return }
                let (postId, loggerEnabled) = result

                let manager = OpenWeb.manager
                let flows = manager.ui.flows

                let additionalSettings = self.commonCreatorService.additionalSettings()
                let article = self.commonCreatorService.mockArticle(for: manager.spotId)

                if shouldUseAsyncAwaitCallingMethod() {
                    Task { @MainActor [weak self] in
                        guard let self else { return }
                        do {
                            let conversationViewController = try await flows.conversation(
                                postId: postId,
                                article: article,
                                additionalSettings: additionalSettings,
                                callbacks: loggerActionCallbacks(loggerEnabled: loggerEnabled)
                            )
                            self._showFullConversation.send(conversationViewController)
                        } catch {
                            let message = error.localizedDescription
                            DLog("Calling flows.conversation error: \(error)")
                            _showError.send(message)
                        }
                    }
                } else {
                    flows.conversation(postId: postId,
                                       article: article,
                                       additionalSettings: additionalSettings,
                                       callbacks: loggerActionCallbacks(loggerEnabled: loggerEnabled),
                                       completion: { [weak self] result in
                        guard let self else { return }
                        switch result {
                        case .success(let conversationViewController):
                            self._showFullConversation.send(conversationViewController)
                        case .failure(let error):
                            let message = error.description
                            DLog("Calling flows.conversation error: \(error)")
                            self._showError.send(message)
                        }
                    })
                }
            })
            .store(in: &cancellables)

        // Providing `displayAuthenticationFlow` callback
        let authenticationFlowCallback: OWAuthenticationFlowCallback = { [weak self] _, completion in
            guard let self else { return }
            let authenticationVM = AuthenticationPlaygroundViewModel(filterBySpotId: OpenWeb.manager.spotId)
            let authenticationVC = AuthenticationPlaygroundVC(viewModel: authenticationVM)

            // Here we intentionally perform direct `navigation controller` methods, instead of doing so in the coordinators layer, to demonstrate how one would interact with OpenWeb SDK in a simple way
            self.presentationalVC?.present(authenticationVC, animated: true)

            authenticationVM.outputs.dismissed
                .prefix(1)
                .sink(receiveValue: { [completion] _ in
                    completion()
                })
                .store(in: &cancellables)
        }

        let authenticationUI = OpenWeb.manager.ui.authenticationUI
        authenticationUI.displayAuthenticationFlow = authenticationFlowCallback

        // Providing `renewSSO` callback
        let renewSSOCallback: OWRenewSSOCallback = { [weak self] userId, completion in
            guard let self else { return }
            #if !PUBLIC_DEMO_APP
            let demoSpotId = DevelopmentConversationPreset.demoSpot().toConversationPreset().conversationDataModel.spotId
            if OpenWeb.manager.spotId == demoSpotId,
               let genericSSO = GenericSSOAuthentication.mockModels.first(where: { $0.user.userId == userId }) {
                self.silentSSOAuthentication.silentSSO(for: genericSSO, ignoreLoginStatus: true)
                    .prefix(1)
                    .sink(receiveCompletion: { result in
                        if case .failure(let error) = result {
                            DLog("Silent SSO failed with error: \(error)")
                            completion()
                        }
                    }, receiveValue: { userId in
                        DLog("Silent SSO completed successfully with userId: \(userId)")
                        completion()
                    })
                    .store(in: &cancellables)
            } else {
                DLog("`renewSSOCallback` triggered, but this is not our demo spot: \(demoSpotId)")
                completion()
            }
            #else
            DLog("`renewSSOCallback` triggered")
            #endif
        }

        let authentication = OpenWeb.manager.authentication
        authentication.renewSSO = renewSSOCallback
    }

    func setupBICallaback() {
        let analytics: OWAnalytics = OpenWeb.manager.analytics

        let BIClosure: OWBIAnalyticEventCallback = { [weak self] event, additionalInfo, postId in
            let log = "Received BI Event: \(event), additional info: \(additionalInfo), postId: \(postId)\n"
            self?.loggerViewModel.inputs.log(text: log)
        }

        analytics.addBICallback(BIClosure)
    }

    func shouldUseAsyncAwaitCallingMethod() -> Bool {
        return SampleAppCallingMethod.asyncAwait == userDefaultsProvider.get(key: .callingMethodOption, defaultValue: .default)
    }

    func loggerActionCallbacks(loggerEnabled: Bool) -> OWFlowActionsCallbacks? {
        guard loggerEnabled else { return nil }
        return { [weak self] callbackType, sourceType, postId in
            guard let self else { return }
            switch callbackType {
            case .adSizeChanged: break
            case let .adEvent(event, eventData):
                let log = "AdEvent (index: \(eventData.index), position: \(eventData.position)): \(event.description)\n"
                self.loggerViewModel.inputs.log(text: log)
            default:
                let log = "Received OWFlowActionsCallback type: \(callbackType), from source: \(sourceType), postId: \(postId)\n"
                self.loggerViewModel.inputs.log(text: log)
            }
        }
    }

    func handleConversationFlow(route: OWConversationRoute, postId: String) {
        guard case let .preConversationToFullConversation(presentationalMode) = _actionSettings.value?.actionType else {
            return
        }
        let manager = OpenWeb.manager
        let flows = manager.ui.flows

        let additionalSettings = commonCreatorService.additionalSettings()
        let article = commonCreatorService.mockArticle(for: manager.spotId)

        if shouldUseAsyncAwaitCallingMethod() {
            Task { @MainActor [weak self] in
                guard let self else { return }
                do {
                    let conversationViewController = try await flows.conversation(
                        postId: postId,
                        article: article,
                        route: route,
                        additionalSettings: additionalSettings,
                        callbacks: loggerActionCallbacks(loggerEnabled: _loggerEnabled.value)
                    )
                    let wrapperVC = ConversationWrapperVC(conversationViewController: conversationViewController)
                    self._showWrappedConversation.send((wrapperVC, presentationalMode))
                } catch {
                    let message = error.localizedDescription
                    DLog("Calling flows.conversation error: \(error)")
                    _showError.send(message)
                }
            }
        } else {
            flows.conversation(postId: postId,
                               article: article,
                               route: route,
                               additionalSettings: additionalSettings,
                               callbacks: loggerActionCallbacks(loggerEnabled: _loggerEnabled.value),
                               completion: { [weak self] result in
                guard let self else { return }
                switch result {
                case .success(let conversationViewController):
                    let wrapperVC = ConversationWrapperVC(conversationViewController: conversationViewController)
                    self._showWrappedConversation.send((wrapperVC, presentationalMode))
                case .failure(let error):
                    let message = error.description
                    DLog("Calling flows.conversation error: \(error)")
                    self._showError.send(message)
                }
            })
        }
    }
}
