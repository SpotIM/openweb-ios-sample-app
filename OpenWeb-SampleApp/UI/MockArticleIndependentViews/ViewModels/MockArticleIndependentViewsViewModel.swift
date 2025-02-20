//
//  MockArticleIndependentViewsViewModel.swift
//  OpenWeb-Development
//
//  Created by Refael Sommer on 21/03/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import UIKit
import Combine
import OpenWebSDK

typealias ComponentAndType = (UIView, SDKUIIndependentViewType)

protocol MockArticleIndependentViewsViewModelingInputs {
    var settingsTapped: PassthroughSubject<Void, Never> { get }
}

protocol MockArticleIndependentViewsViewModelingOutputs {
    var title: String { get }
    var loggerViewModel: UILoggerViewModeling { get }
    var openSettings: AnyPublisher<SettingsGroupType, Never> { get }
    var showComponent: AnyPublisher<ComponentAndType, Never> { get }
    var independentViewHorizontalMargin: CGFloat { get }
}

protocol MockArticleIndependentViewsViewModeling {
    var inputs: MockArticleIndependentViewsViewModelingInputs { get }
    var outputs: MockArticleIndependentViewsViewModelingOutputs { get }
}

class MockArticleIndependentViewsViewModel: MockArticleIndependentViewsViewModeling, MockArticleIndependentViewsViewModelingInputs, MockArticleIndependentViewsViewModelingOutputs {
    var inputs: MockArticleIndependentViewsViewModelingInputs { return self }
    var outputs: MockArticleIndependentViewsViewModelingOutputs { return self }

    private struct Metrics {
        static let preConversationCompactHorizontalMargin: CGFloat = 16.0
        static let timeForPersistenceToUpdate: Int = 100 // In ms
    }

    private var cancellables = Set<AnyCancellable>()
    let settingsTapped = PassthroughSubject<Void, Never>()

    private let userDefaultsProvider: UserDefaultsProviderProtocol
    private let commonCreatorService: CommonCreatorServicing

    private let _actionSettings = CurrentValueSubject<SDKUIIndependentViewsActionSettings?, Never>(nil)
    private var actionSettings: AnyPublisher<SDKUIIndependentViewsActionSettings, Never> {
        return _actionSettings
            .unwrap()
            .eraseToAnyPublisher()
    }

    init(userDefaultsProvider: UserDefaultsProviderProtocol = UserDefaultsProvider.shared,
         commonCreatorService: CommonCreatorServicing = CommonCreatorService(),
         actionSettings: SDKUIIndependentViewsActionSettings) {
        self.userDefaultsProvider = userDefaultsProvider
        self.commonCreatorService = commonCreatorService
        _actionSettings.send(actionSettings)

        switch actionSettings.viewType {
        case .preConversation:
            loggerViewTitle = "Pre conversation logger"
        case .conversation:
            loggerViewTitle = "Conversation logger"
        case .commentCreation:
            loggerViewTitle = "Comment creation logger"
        case .commentThread:
            loggerViewTitle = "Comment thread logger"
        case .independentAdUnit:
            loggerViewTitle = "Independed ad unit logger"
        case .clarityDetails:
            loggerViewTitle = "Clarity details logger"
        }

        setupCustomizationsCallaback()
        setupBICallaback()
        setupObservers()
    }
    var openSettings: AnyPublisher<SettingsGroupType, Never> {
        return settingsTapped
            .withLatestFrom(actionSettings)
            .map { SettingsGroupType(independentViewType: $0.viewType) }
            .eraseToAnyPublisher()
    }

    private let loggerViewTitle: String

    lazy var title: String = {
        return NSLocalizedString("MockArticle", comment: "")
    }()

    lazy var loggerViewModel: UILoggerViewModeling = {
        return UILoggerViewModel(title: loggerViewTitle)
    }()

    lazy var showComponent: AnyPublisher<ComponentAndType, Never> = {
        return viewTypeUpdaters
            .flatMap { [weak self] settings -> AnyPublisher<ComponentAndType, Never> in
                guard let self else { return Empty().eraseToAnyPublisher() }
                return self.retrieveComponent(for: settings)
                    .map { ($0, settings.viewType) }
                    .catch { error in Empty().eraseToAnyPublisher() }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }()

    private lazy var viewTypeUpdaters: AnyPublisher<SDKUIIndependentViewsActionSettings, Never> = {
        return Publishers.Merge6(
            preConversationStyleChanged,
            conversationStyleChanged,
            commentCreationStyleChanged,
            commentThreadStyleChanged,
            independentAdUnitStyleChanged,
            clarityDetailsStyleChanged
        )
        .flatMap { [weak self] _ -> AnyPublisher<SDKUIIndependentViewsActionSettings, Never> in
            guard let self else { return Empty().eraseToAnyPublisher() }
            return self.actionSettings
                .first()
                .eraseToAnyPublisher()
        }
        .delay(for: .milliseconds(Metrics.timeForPersistenceToUpdate), scheduler: RunLoop.main)
        .share()
        .eraseToAnyPublisher()
    }()

    private var _horizontalMargin: CGFloat = 0.0
    var independentViewHorizontalMargin: CGFloat {
        return _horizontalMargin
    }

    // All the stuff which should trigger new pre conversation component
    private lazy var preConversationStyleChanged: AnyPublisher<Void, Never> = {
        return self.userDefaultsProvider.values(key: .preConversationStyle, defaultValue: OWPreConversationStyle.default)
            .flatMap { [weak self] _ -> AnyPublisher<SDKUIIndependentViewType, Never> in
                guard let self else { return Empty().eraseToAnyPublisher() }
                return self.actionSettings
                    .first()
                    .map { $0.viewType }
                    .eraseToAnyPublisher()
            }
            .filter { $0 == .preConversation }
            .voidify()
            .share()
            .eraseToAnyPublisher()
    }()

    // All the stuff which should trigger new conversation component
    private lazy var conversationStyleChanged: AnyPublisher<Void, Never> = {
        return self.userDefaultsProvider.values(key: .conversationStyle, defaultValue: OWConversationStyle.default)
            .flatMap { [weak self] _ -> AnyPublisher<SDKUIIndependentViewType, Never> in
                guard let self else { return Empty().eraseToAnyPublisher() }
                return self.actionSettings
                    .first()
                    .map { $0.viewType }
                    .eraseToAnyPublisher()
            }
            .filter { $0 == .conversation }
            .voidify()
            .share()
            .eraseToAnyPublisher()
    }()

    private lazy var commentCreationStyleChanged: AnyPublisher<Void, Never> = {
        return self.userDefaultsProvider.values(key: .commentCreationStyle, defaultValue: OWCommentCreationStyle.default)
            .flatMap { [weak self] _ -> AnyPublisher<SDKUIIndependentViewType, Never> in
                guard let self else { return Empty().eraseToAnyPublisher() }
                return self.actionSettings
                    .first()
                    .map { $0.viewType }
                    .eraseToAnyPublisher()
            }
            .filter { $0 == .commentCreation }
            .voidify()
            .share()
            .eraseToAnyPublisher()
    }()

    // All the stuff which should trigger new comment thread component
    private lazy var commentThreadStyleChanged: AnyPublisher<Void, Never> = {
        return self.userDefaultsProvider.values(key: .conversationStyle, defaultValue: OWConversationStyle.default)
            .flatMap { [weak self] _ -> AnyPublisher<SDKUIIndependentViewType, Never> in
                guard let self else { return Empty().eraseToAnyPublisher() }
                return self.actionSettings
                    .first()
                    .map { $0.viewType }
                    .eraseToAnyPublisher()
            }
            .filter { $0 == .commentThread }
            .voidify()
            .share()
            .eraseToAnyPublisher()
    }()

    // All the stuff which should trigger new comment thread component
    private lazy var independentAdUnitStyleChanged: AnyPublisher<Void, Never> = {
        // TODO: Complete once developed
        return Empty().eraseToAnyPublisher()
    }()

    // All the stuff which should trigger new comment thread component
    private lazy var clarityDetailsStyleChanged: AnyPublisher<Void, Never> = {
        // TODO: Complete once developed
        return Empty().eraseToAnyPublisher()
    }()
}

private extension MockArticleIndependentViewsViewModel {
    func setupObservers() {
        // Addressing horizontal margin
        viewTypeUpdaters
            .sink { [weak self] settings in
                guard let self else { return }
                switch settings.viewType {
                case .preConversation:
                    let preConversationStyle = self.userDefaultsProvider.get(key: .preConversationStyle, defaultValue: OWPreConversationStyle.default)
                    self._horizontalMargin = preConversationStyle == OWPreConversationStyle.compact ? Metrics.preConversationCompactHorizontalMargin : 0.0
                default:
                    self._horizontalMargin = 0.0
                }
            }
            .store(in: &cancellables)

        // Clear logger
        viewTypeUpdaters
            .sink { [weak self] _ in
                guard let self else { return }
                self.loggerViewModel.inputs.clear()
            }
            .store(in: &cancellables)
    }

    func setupCustomizationsCallaback() {
        let customizations: OWCustomizations = OpenWeb.manager.ui.customizations

        let customizableClosure: OWCustomizableElementCallback = { [weak self] element, source, style, postId in
            guard let self else { return }
            let postIdString = postId ?? "No postId"
            let log = "Received OWCustomizableElementCallback element: \(element), from source: \(source), style: \(style), postId: \(postIdString)\n"
            self.loggerViewModel.inputs.log(text: log)
        }

        customizations.addElementCallback(customizableClosure)
    }

    func setupBICallaback() {
        let analytics: OWAnalytics = OpenWeb.manager.analytics

        let BIClosure: OWBIAnalyticEventCallback = { [weak self] event, additionalInfo, postId in
            let log = "Received BI Event: \(event), additional info: \(additionalInfo), postId: \(postId)"
            self?.loggerViewModel.inputs.log(text: log)
        }

        analytics.addBICallback(BIClosure)
    }

    func retrieveComponent(for settings: SDKUIIndependentViewsActionSettings) -> AnyPublisher<UIView, Error> {
        switch settings.viewType {
        case .preConversation:
            return self.retrievePreConversation(settings: settings)
        case .conversation:
            return self.retrieveConversation(settings: settings)
        case .commentCreation:
            return self.retrieveCommentCreation(settings: settings)
        case .commentThread:
            return self.retrieveCommentThread(settings: settings)
        case .independentAdUnit:
            return Empty().eraseToAnyPublisher()
        case .clarityDetails:
            return self.retrieveClarityDetails(settings: settings)
        }
    }

    func retrievePreConversation(settings: SDKUIIndependentViewsActionSettings) -> AnyPublisher<UIView, Error> {
        return AnyPublisher<UIView, Error>.create { [weak self] observer in
            guard let self else {
                observer.send(completion: .failure(GeneralErrors.missingImplementation))
                return AnyCancellable {}
            }

            let additionalSettings = self.commonCreatorService.additionalSettings()
            let article = self.commonCreatorService.mockArticle(for: OpenWeb.manager.spotId)

            let manager = OpenWeb.manager
            let uiViews = manager.ui.views

            let actionsCallbacks: OWViewActionsCallbacks = { [weak self] callbackType, sourceType, postId in
                guard let self else { return }
                switch callbackType {
                case .adSizeChanged: break
                case let .adEvent(event, index):
                    let log = "preconversationAd: \(event.description) for index: \(index)\n"
                    self.loggerViewModel.inputs.log(text: log)
                default:
                    let log = "Received OWViewActionsCallback type: \(callbackType), from source: \(sourceType), postId: \(postId)\n"
                    self.loggerViewModel.inputs.log(text: log)
                }
            }

            if shouldUseAsyncAwaitCallingMethod() {
                Task { @MainActor in
                    do {
                        let preConversationView = try await uiViews.preConversation(
                            postId: settings.postId,
                            article: article,
                            additionalSettings: additionalSettings,
                            callbacks: actionsCallbacks
                        )
                        observer.send(preConversationView)
                        observer.send(completion: .finished)
                    } catch {
                        let message = error.localizedDescription
                        DLog("Calling retrievePreConversation error: \(message)")
                        observer.send(completion: .failure(error))
                    }
                }
            } else {
                uiViews.preConversation(postId: settings.postId,
                                        article: article,
                                        additionalSettings: additionalSettings,
                                        callbacks: actionsCallbacks,
                                        completion: { result in
                    switch result {
                    case .success(let preConversationView):
                        observer.send(preConversationView)
                        observer.send(completion: .finished)
                    case .failure(let error):
                        let message = error.description
                        DLog("Calling retrievePreConversation error: \(message)")
                        observer.send(completion: .failure(error))
                    }
                })
            }

            return AnyCancellable {}
        }
    }

    func retrieveConversation(settings: SDKUIIndependentViewsActionSettings) -> AnyPublisher<UIView, Error> {
        return AnyPublisher<UIView, Error>.create { [weak self] observer in
            guard let self else {
                observer.send(completion: .failure(GeneralErrors.missingImplementation))
                return AnyCancellable {}
            }

            let additionalSettings = self.commonCreatorService.additionalSettings()
            let article = self.commonCreatorService.mockArticle(for: OpenWeb.manager.spotId)

            let manager = OpenWeb.manager
            let uiViews = manager.ui.views

            let actionsCallbacks: OWViewActionsCallbacks = { [weak self] callbackType, sourceType, postId in
                guard let self else { return }
                let log = "Received OWViewActionsCallback type: \(callbackType), from source: \(sourceType), postId: \(postId)\n"
                self.loggerViewModel.inputs.log(text: log)
            }

            if shouldUseAsyncAwaitCallingMethod() {
                Task { @MainActor in
                    do {
                        let conversationView = try await uiViews.conversation(
                            postId: settings.postId,
                            article: article,
                            additionalSettings: additionalSettings,
                            callbacks: actionsCallbacks
                        )
                        observer.send(conversationView)
                        observer.send(completion: .finished)
                    } catch {
                        let message = error.localizedDescription
                        DLog("Calling retrieveConversation error: \(message)")
                        observer.send(completion: .failure(error))
                    }
                }
            } else {
                uiViews.conversation(postId: settings.postId,
                                     article: article,
                                     additionalSettings: additionalSettings,
                                     callbacks: actionsCallbacks,
                                     completion: { result in
                    switch result {
                    case .success(let conversationView):
                        observer.send(conversationView)
                        observer.send(completion: .finished)
                    case .failure(let error):
                        let message = error.description
                        DLog("Calling retrieveConversation error: \(message)")
                        observer.send(completion: .failure(error))
                    }
                })
            }

            return AnyCancellable {}
        }
    }

    func retrieveCommentCreation(settings: SDKUIIndependentViewsActionSettings) -> AnyPublisher<UIView, Error> {
        return AnyPublisher<UIView, Error>.create { [weak self] observer in
            guard let self else {
                observer.send(completion: .failure(GeneralErrors.missingImplementation))
                return AnyCancellable {}
            }

            let additionalSettings = self.commonCreatorService.additionalSettings()
            let article = self.commonCreatorService.mockArticle(for: OpenWeb.manager.spotId)

            let manager = OpenWeb.manager
            let uiViews = manager.ui.views

            let actionsCallbacks: OWViewActionsCallbacks = { [weak self] callbackType, sourceType, postId in
                guard let self else { return }
                let log = "Received OWViewActionsCallback type: \(callbackType), from source: \(sourceType), postId: \(postId)\n"
                self.loggerViewModel.inputs.log(text: log)
            }

            if shouldUseAsyncAwaitCallingMethod() {
                Task { @MainActor in
                    do {
                        let commentCreationView = try await uiViews.commentCreation(
                            postId: settings.postId,
                            article: article,
                            commentCreationType: .comment,
                            additionalSettings: additionalSettings,
                            callbacks: actionsCallbacks
                        )
                        observer.send(commentCreationView)
                        observer.send(completion: .finished)
                    } catch {
                        let message = error.localizedDescription
                        DLog("Calling retrieveCommentCreation error: \(message)")
                        observer.send(completion: .failure(error))
                    }
                }
            } else {
                uiViews.commentCreation(postId: settings.postId,
                                        article: article,
                                        commentCreationType: .comment,
                                        additionalSettings: additionalSettings,
                                        callbacks: actionsCallbacks,
                                        completion: { result in
                    switch result {
                    case .success(let commentCreationView):
                        observer.send(commentCreationView)
                        observer.send(completion: .finished)
                    case .failure(let error):
                        let message = error.description
                        DLog("Calling retrieveCommentCreation error: \(message)")
                        observer.send(completion: .failure(error))
                    }
                })
            }

            return AnyCancellable {}
        }
    }

    func retrieveCommentThread(settings: SDKUIIndependentViewsActionSettings) -> AnyPublisher<UIView, Error> {
        return AnyPublisher<UIView, Error>.create { [weak self] observer in
            guard let self else {
                observer.send(completion: .failure(GeneralErrors.missingImplementation))
                return AnyCancellable {}
            }

            let additionalSettings = self.commonCreatorService.additionalSettings()
            let article = self.commonCreatorService.mockArticle(for: OpenWeb.manager.spotId)

            let manager = OpenWeb.manager
            let uiViews = manager.ui.views

            let actionsCallbacks: OWViewActionsCallbacks = { [weak self] callbackType, sourceType, postId in
                guard let self else { return }
                let log = "Received OWViewActionsCallback type: \(callbackType), from source: \(sourceType), postId: \(postId)\n"
                self.loggerViewModel.inputs.log(text: log)
            }

            if shouldUseAsyncAwaitCallingMethod() {
                Task { @MainActor in
                    do {
                        let commentThreadView = try await uiViews.commentThread(
                            postId: settings.postId,
                            article: article,
                            commentId: self.commonCreatorService.commentThreadCommentId(),
                            additionalSettings: additionalSettings,
                            callbacks: actionsCallbacks
                        )
                        observer.send(commentThreadView)
                        observer.send(completion: .finished)
                    } catch {
                        let message = error.localizedDescription
                        DLog("Calling retrieveCommentThread error: \(message)")
                        observer.send(completion: .failure(error))
                    }
                }
            } else {
                uiViews.commentThread(postId: settings.postId,
                                      article: article,
                                      commentId: self.commonCreatorService.commentThreadCommentId(),
                                      additionalSettings: additionalSettings,
                                      callbacks: actionsCallbacks,
                                      completion: { result in
                    switch result {
                    case .success(let commentThreadView):
                        observer.send(commentThreadView)
                        observer.send(completion: .finished)
                    case .failure(let error):
                        let message = error.description
                        DLog("Calling retrieveCommentThread error: \(message)")
                        observer.send(completion: .failure(error))
                    }
                })
            }

            return AnyCancellable {}
        }
    }

    func retrieveClarityDetails(settings: SDKUIIndependentViewsActionSettings) -> AnyPublisher<UIView, Error> {
        return AnyPublisher<UIView, Error>.create { [weak self] observer in
            guard let self else {
                observer.send(completion: .failure(GeneralErrors.missingImplementation))
                return AnyCancellable {}
            }

            let manager = OpenWeb.manager
            let uiViews = manager.ui.views
            let additionalSettings = self.commonCreatorService.additionalSettings()

            let actionsCallbacks: OWViewActionsCallbacks = { [weak self] callbackType, sourceType, postId in
                guard let self else { return }
                let log = "Received OWViewActionsCallback type: \(callbackType), from source: \(sourceType), postId: \(postId)\n"
                self.loggerViewModel.inputs.log(text: log)
            }

            if shouldUseAsyncAwaitCallingMethod() {
                Task { @MainActor in
                    do {
                        let clarityDetailsView = try await uiViews.clarityDetails(
                            postId: settings.postId,
                            commentId: self.commonCreatorService.commentThreadCommentId(),
                            type: .rejected,
                            additionalSettings: additionalSettings,
                            callbacks: actionsCallbacks
                        )
                        observer.send(clarityDetailsView)
                        observer.send(completion: .finished)
                    } catch {
                        let message = error.localizedDescription
                        DLog("Calling retrieveClarityDetails error: \(message)")
                        observer.send(completion: .failure(error))
                    }
                }
            } else {
                uiViews.clarityDetails(postId: settings.postId,
                                       commentId: self.commonCreatorService.commentThreadCommentId(),
                                       type: .rejected,
                                       additionalSettings: additionalSettings,
                                       callbacks: actionsCallbacks,
                                       completion: { result in
                    switch result {
                    case .success(let clarityDetailsView):
                        observer.send(clarityDetailsView)
                        observer.send(completion: .finished)
                    case .failure(let error):
                        let message = error.description
                        DLog("Calling retrieveClarityDetails error: \(message)")
                        observer.send(completion: .failure(error))
                    }
                })
            }

            return AnyCancellable {}
        }
    }

    func shouldUseAsyncAwaitCallingMethod() -> Bool {
        return SampleAppCallingMethod.asyncAwait == userDefaultsProvider.get(key: .callingMethodOption, defaultValue: .default)
    }
}
