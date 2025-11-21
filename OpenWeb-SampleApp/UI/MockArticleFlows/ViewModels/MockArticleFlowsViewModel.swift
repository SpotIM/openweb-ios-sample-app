//
//  MockArticleFlowsViewModel.swift
//  OpenWeb-Development
//
//  Created by Alon Haiut on 04/09/2022.
//  Copyright © 2022 OpenWeb. All rights reserved.
//

import Foundation
import UIKit
import Combine
import OpenWebSDK

protocol MockArticleFlowsViewModelingInputs {
    func setNavigationController(_ navController: UINavigationController?)
    func setPresentationalVC(_ viewController: UIViewController)
    var fullConversationButtonTapped: PassthroughSubject<Void, Never> { get }
    var commentCreationButtonTapped: PassthroughSubject<Void, Never> { get }
    var commentThreadButtonTapped: PassthroughSubject<Void, Never> { get }
}

protocol MockArticleFlowsViewModelingOutputs {
    var title: String { get }
    var showFullConversationButton: AnyPublisher<PresentationalModeCompact, Never> { get }
    var showCommentCreationButton: AnyPublisher<PresentationalModeCompact, Never> { get }
    var showPreConversation: AnyPublisher<UIView, Never> { get }
    var showCommentThreadButton: AnyPublisher<PresentationalModeCompact, Never> { get }
    var articleImageURL: AnyPublisher<URL, Never> { get }
    var showError: AnyPublisher<String, Never> { get }
    var preConversationHorizontalMargin: CGFloat { get }
    var loggerViewModel: UILoggerViewModeling { get }
    var floatingViewViewModel: OWFloatingViewModeling { get }
    var loggerEnabled: AnyPublisher<Bool, Never> { get }
}

protocol MockArticleFlowsViewModeling {
    var inputs: MockArticleFlowsViewModelingInputs { get }
    var outputs: MockArticleFlowsViewModelingOutputs { get }
}

class MockArticleFlowsViewModel: MockArticleFlowsViewModeling, MockArticleFlowsViewModelingInputs, MockArticleFlowsViewModelingOutputs {
    var inputs: MockArticleFlowsViewModelingInputs { return self }
    var outputs: MockArticleFlowsViewModelingOutputs { return self }

    lazy var loggerViewModel: UILoggerViewModeling = {
        return UILoggerViewModel(title: "Flows Logger")
    }()

    lazy var floatingViewViewModel: OWFloatingViewModeling = {
        return OWFloatingViewModel()
    }()

    lazy var loggerEnabled: AnyPublisher<Bool, Never> = {
        return userDefaultsProvider.values(key: .flowsLoggerEnabled, defaultValue: false)
    }()

    private struct Metrics {
        static let preConversationCompactHorizontalMargin: CGFloat = 16.0
    }

    private var cancellables = Set<AnyCancellable>()

    private let imageProviderAPI: ImageProviding

    private weak var navController: UINavigationController?
    private weak var presentationalVC: UIViewController?

    private let _articleImageURL = CurrentValueSubject<URL?, Never>(value: nil)
    var articleImageURL: AnyPublisher<URL, Never> {
        return _articleImageURL
            .unwrap()
            .eraseToAnyPublisher()
    }

    private let userDefaultsProvider: UserDefaultsProviderProtocol
    private let commonCreatorService: CommonCreatorServicing

    private let _actionSettings = CurrentValueSubject<SDKUIFlowActionSettings?, Never>(value: nil)
    private var actionSettings: AnyPublisher<SDKUIFlowActionSettings, Never> {
        return _actionSettings
            .unwrap()
            .eraseToAnyPublisher()
    }

    init(userDefaultsProvider: UserDefaultsProviderProtocol = UserDefaultsProvider.shared,
         commonCreatorService: CommonCreatorServicing = CommonCreatorService(),
         imageProviderAPI: ImageProviding = ImageProvider(),
         actionSettings: SDKUIFlowActionSettings) {
        self.imageProviderAPI = imageProviderAPI
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

    let fullConversationButtonTapped = PassthroughSubject<Void, Never>()
    let commentCreationButtonTapped = PassthroughSubject<Void, Never>()
    let commentThreadButtonTapped = PassthroughSubject<Void, Never>()

    var showFullConversationButton: AnyPublisher<PresentationalModeCompact, Never> {
        return actionSettings
            // Map here is also like a filter
            .map { settings in
                if case .fullConversation(let mode) = settings.actionType {
                    return mode
                } else {
                    return nil
                }
            }
            .unwrap()

    }

    var showCommentCreationButton: AnyPublisher<PresentationalModeCompact, Never> {
        return actionSettings
            // Map here is also like a filter
            .map { settings in
                if case .commentCreation(let mode) = settings.actionType {
                    return mode
                } else {
                    return nil
                }
            }
            .unwrap()
    }

    var showCommentThreadButton: AnyPublisher<PresentationalModeCompact, Never> {
        return actionSettings
            // Map here is also like a filter
            .map { settings in
                if case .commentThread(let mode) = settings.actionType {
                    return mode
                } else {
                    return nil
                }
            }
            .unwrap()
    }

    var preConversationHorizontalMargin: CGFloat {
        let preConversationStyle = userDefaultsProvider.get(key: .preConversationStyle, defaultValue: OWPreConversationStyle.default)
        let margin = preConversationStyle == OWPreConversationStyle.compact ? Metrics.preConversationCompactHorizontalMargin : 0.0
        return margin
    }

    lazy var title: String = {
        return NSLocalizedString("MockArticle", comment: "")
    }()

    func setNavigationController(_ navController: UINavigationController?) {
        self.navController = navController
    }

    func setPresentationalVC(_ viewController: UIViewController) {
        presentationalVC = viewController
    }
}

private extension MockArticleFlowsViewModel {
    // swiftlint:disable function_body_length
    func setupObservers() {
        let articleURL = imageProviderAPI.randomImageUrl()
        _articleImageURL.send(articleURL)

        // Pre conversation
        actionSettings
            .map { settings -> (PresentationalModeCompact, String)? in
                if case .preConversation(let mode) = settings.actionType {
                    return (mode, settings.postId)
                } else {
                    return nil
                }
            }
            .unwrap()
            // Small delay so the navigation controller will be set from the view controller
            .delay(for: .milliseconds(50), scheduler: DispatchQueue.global(qos: .userInteractive)) // swiftlint:disable:this no_magic_numbers
            .withLatestFrom(loggerEnabled) { result, loggerEnabled -> (PresentationalModeCompact, String, Bool) in
                return (result.0, result.1, loggerEnabled)
            }
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] result in
                guard let self else { return }
                let mode = result.0
                let postId = result.1
                let loggerEnabled = result.2

                let manager = OpenWeb.manager
                let flows = manager.ui.flows

                let additionalSettings = self.commonCreatorService.additionalSettings()
                let article = self.commonCreatorService.mockArticle(for: manager.spotId)

                guard let presentationalMode = self.presentationalMode(fromCompactMode: mode) else { return }

                if shouldUseAsyncAwaitCallingMethod() {
                    Task { @MainActor [weak self] in
                        guard let self else { return }
                        do {
                            let preConversationView = try await flows.preConversation(
                                postId: postId,
                                article: article,
                                presentationalMode: presentationalMode,
                                additionalSettings: additionalSettings,
                                callbacks: loggerActionCallbacks(loggerEnabled: loggerEnabled)
                            )
                            _showPreConversation.send(preConversationView)
                        } catch {
                            let message = error.localizedDescription
                            DLog("Calling flows.preConversation error: \(error)")
                            _showError.send(message)
                        }
                    }
                } else {
                    flows.preConversation(postId: postId,
                                          article: article,
                                          presentationalMode: presentationalMode,
                                          additionalSettings: additionalSettings,
                                          callbacks: loggerActionCallbacks(loggerEnabled: loggerEnabled),
                                          completion: { [weak self] result in
                        guard let self else { return }
                        switch result {
                        case .success(let preConversationView):
                            self._showPreConversation.send(preConversationView)
                        case .failure(let error):
                            let message = error.description
                            DLog("Calling flows.preConversation error: \(error)")
                            self._showError.send(message)
                        }
                    })
                }
            })
            .store(in: &cancellables)

        // Full conversation
        fullConversationButtonTapped
            .withLatestFrom(showFullConversationButton)
            .withLatestFrom(actionSettings) { mode, settings -> (PresentationalModeCompact, String) in
                return (mode, settings.postId)
            }
            .withLatestFrom(loggerEnabled) { result, loggerEnabled -> (PresentationalModeCompact, String, Bool) in
                return (result.0, result.1, loggerEnabled)
            }
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] result in
                guard let self else { return }
                let mode = result.0
                let postId = result.1
                let loggerEnabled = result.2

                guard let presentationalMode = self.presentationalMode(fromCompactMode: mode) else { return }

                let manager = OpenWeb.manager
                let flows = manager.ui.flows

                let additionalSettings = self.commonCreatorService.additionalSettings()
                let article = self.commonCreatorService.mockArticle(for: manager.spotId)

                if shouldUseAsyncAwaitCallingMethod() {
                    Task { @MainActor [weak self] in
                        guard let self else { return }
                        do {
                            try await flows.conversation(
                                postId: postId,
                                article: article,
                                presentationalMode: presentationalMode,
                                additionalSettings: additionalSettings,
                                callbacks: loggerActionCallbacks(loggerEnabled: loggerEnabled)
                            )
                        } catch {
                            let message = error.localizedDescription
                            DLog("Calling flows.conversation error: \(message)")
                            _showError.send(message)
                        }
                    }
                } else {
                    flows.conversation(postId: postId,
                                       article: article,
                                       presentationalMode: presentationalMode,
                                       additionalSettings: additionalSettings,
                                       callbacks: loggerActionCallbacks(loggerEnabled: loggerEnabled),
                                       completion: { [weak self] result in
                        guard let self else { return }
                        switch result {
                        case .success:
                            // All good
                            break
                        case .failure(let error):
                            let message = error.description
                            DLog("Calling flows.conversation error: \(message)")
                            self._showError.send(message)
                        }
                    })
                }
            })
            .store(in: &cancellables)

        // Comment creation
        commentCreationButtonTapped
            .withLatestFrom(showCommentCreationButton)
            .withLatestFrom(actionSettings) { mode, settings -> (PresentationalModeCompact, String) in
                return (mode, settings.postId)
            }
            .withLatestFrom(loggerEnabled) { result, loggerEnabled -> (PresentationalModeCompact, String, Bool) in
                return (result.0, result.1, loggerEnabled)
            }
            .receive(on: DispatchQueue.main)
            .sink(
                receiveValue: { [weak self] result in
                    guard let self else { return }
                    let mode = result.0
                    let postId = result.1
                    let loggerEnabled = result.2

                    guard let presentationalMode = self.presentationalMode(fromCompactMode: mode) else { return }

                    let manager = OpenWeb.manager
                    let flows = manager.ui.flows

                    let additionalSettings = self.commonCreatorService.additionalSettings()
                    let article = self.commonCreatorService.mockArticle(for: OpenWeb.manager.spotId)

                    if shouldUseAsyncAwaitCallingMethod() {
                        Task { @MainActor [weak self] in
                            guard let self else { return }
                            do {
                                try await flows.conversation(
                                    postId: postId,
                                    article: article,
                                    route: .commentCreation(type: .comment),
                                    presentationalMode: presentationalMode,
                                    additionalSettings: additionalSettings,
                                    callbacks: loggerActionCallbacks(loggerEnabled: loggerEnabled)
                                )
                            } catch {
                                let message = error.localizedDescription
                                DLog("Calling flows.commentCreation error: \(message)")
                                _showError.send(message)
                            }
                        }
                    } else {
                        flows.conversation(
                            postId: postId,
                            article: article,
                            route: .commentCreation(type: .comment),
                            presentationalMode: presentationalMode,
                            additionalSettings: additionalSettings,
                            callbacks: loggerActionCallbacks(loggerEnabled: loggerEnabled),
                            completion: { [weak self] result in
                        guard let self else { return }
                        switch result {
                        case .success:
                            // All good
                            break
                        case .failure(let error):
                            let message = error.description
                            DLog("Calling flows.commentCreation error: \(message)")
                            self._showError.send(message)
                        }
                            })
                }
                })
            .store(in: &cancellables)

        // Comment creation
        commentThreadButtonTapped
            .withLatestFrom(showCommentThreadButton)
            .withLatestFrom(actionSettings) { mode, settings -> (PresentationalModeCompact, String) in
                return (mode, settings.postId)
            }
            .withLatestFrom(loggerEnabled) { result, loggerEnabled -> (PresentationalModeCompact, String, Bool) in
                return (result.0, result.1, loggerEnabled)
            }
            .receive(on: DispatchQueue.main)
            .sink(
                receiveValue: { [weak self] result in
                    guard let self else { return }
                    let mode = result.0
                    let postId = result.1
                    let loggerEnabled = result.2

                    guard let presentationalMode = self.presentationalMode(fromCompactMode: mode) else { return }

                    let manager = OpenWeb.manager
                    let flows = manager.ui.flows

                    let additionalSettings = self.commonCreatorService.additionalSettings()
                    let article = self.commonCreatorService.mockArticle(for: OpenWeb.manager.spotId)

                    if shouldUseAsyncAwaitCallingMethod() {
                        Task { @MainActor [weak self] in
                            guard let self else { return }
                            do {
                                try await flows.conversation(
                                    postId: postId,
                                    article: article,
                                    route: .commentThread(commentId: self.commonCreatorService.commentThreadCommentId()),
                                    presentationalMode: presentationalMode,
                                    additionalSettings: additionalSettings,
                                    callbacks: loggerActionCallbacks(loggerEnabled: loggerEnabled)
                                )
                            } catch {
                                let message = error.localizedDescription
                                DLog("Calling flows.commentThread error: \(message)")
                                _showError.send(message)
                            }
                        }
                    } else {
                        flows.conversation(
                            postId: postId,
                            article: article,
                            route: .commentThread(commentId: self.commonCreatorService.commentThreadCommentId()),
                            presentationalMode: presentationalMode,
                            additionalSettings: additionalSettings,
                            callbacks: loggerActionCallbacks(
                                loggerEnabled: loggerEnabled
                            ),
                            completion: { [weak self] result in
                        guard let self else { return }
                        switch result {
                        case .success:
                            // All good
                            break
                        case .failure(let error):
                            let message = error.description
                            DLog("Calling flows.commentThread error: \(message)")
                            self._showError.send(message)
                        }
                            })
                }
                })
            .store(in: &cancellables)

        // Providing `displayAuthenticationFlow` callback
        let authenticationFlowCallback: OWAuthenticationFlowCallback = { [weak self] routeringMode, completion in
            guard let self else { return }
            let authenticationVM = AuthenticationPlaygroundViewModel(filterBySpotId: OpenWeb.manager.spotId)
            let authenticationVC = AuthenticationPlaygroundVC(viewModel: authenticationVM)

            // Here we intentionally perform direct `navigation controller` methods, instead of doing so in the coordinators layer, to demonstrate how one would interact with OpenWeb SDK in a simple way
            switch routeringMode {
            case .flow(let navController):
                navController.pushViewController(authenticationVC, animated: true)
            case .none:
                self.navController?.pushViewController(authenticationVC, animated: true)
            default:
                break
            }

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
        let authentication = OpenWeb.manager.authentication
        authentication.renewSSO = commonCreatorService.renewSSOCallback
    }
    // swiftlint:enable function_body_length

    func presentationalMode(fromCompactMode mode: PresentationalModeCompact) -> OWPresentationalMode? {
        guard let navController = self.navController,
              let presentationalVC else { return nil }

        switch mode {
        case .present(let style):
            return OWPresentationalMode.present(viewController: presentationalVC, style: style)
        case .push:
            return OWPresentationalMode.push(navigationController: navController)
        }
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
}
