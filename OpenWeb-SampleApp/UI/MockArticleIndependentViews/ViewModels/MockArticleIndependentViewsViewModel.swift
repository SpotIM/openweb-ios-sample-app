//
//  MockArticleIndependentViewsViewModel.swift
//  OpenWeb-Development
//
//  Created by Refael Sommer on 21/03/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import UIKit
import RxSwift
import OpenWebSDK

typealias ComponentAndType = (UIView, SDKUIIndependentViewType)

protocol MockArticleIndependentViewsViewModelingInputs {
    var settingsTapped: PublishSubject<Void> { get }
}

protocol MockArticleIndependentViewsViewModelingOutputs {
    var title: String { get }
    var loggerViewModel: UILoggerViewModeling { get }
    var openSettings: Observable<SettingsGroupType> { get }
    var showComponent: Observable<ComponentAndType> { get }
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

    private let disposeBag = DisposeBag()
    let settingsTapped = PublishSubject<Void>()

    private let userDefaultsProvider: UserDefaultsProviderProtocol
    private let commonCreatorService: CommonCreatorServicing

    private let _actionSettings = BehaviorSubject<SDKUIIndependentViewsActionSettings?>(value: nil)
    private var actionSettings: Observable<SDKUIIndependentViewsActionSettings> {
        return _actionSettings
            .unwrap()
            .asObservable()
    }

    init(userDefaultsProvider: UserDefaultsProviderProtocol = UserDefaultsProvider.shared,
         commonCreatorService: CommonCreatorServicing = CommonCreatorService(),
         actionSettings: SDKUIIndependentViewsActionSettings) {
        self.userDefaultsProvider = userDefaultsProvider
        self.commonCreatorService = commonCreatorService
        _actionSettings.onNext(actionSettings)

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

    var openSettings: Observable<SettingsGroupType> {
        return settingsTapped
            .withLatestFrom(actionSettings)
            .map { SettingsGroupType(independentViewType: $0.viewType) }
            .asObservable()
    }

    private let loggerViewTitle: String

    lazy var title: String = {
        return NSLocalizedString("MockArticle", comment: "")
    }()

    lazy var loggerViewModel: UILoggerViewModeling = {
        return UILoggerViewModel(title: loggerViewTitle)
    }()

    lazy var showComponent: Observable<ComponentAndType> = {
        return self.viewTypeUpdaters
            .flatMap { [weak self] settings -> Observable<ComponentAndType> in
                guard let self else { return .empty() }
                return self.retrieveComponent(for: settings)
                    .map { ($0, settings.viewType) }
            }
    }()

    private lazy var viewTypeUpdaters: Observable<SDKUIIndependentViewsActionSettings> = {
        return Observable.merge(preConversationUpdater, conversationUpdater, commentCreationUpdater, commentThreadUpdater, independentAdUnitUpdater, clarityDetailsUpdater)
            .flatMapLatest { [weak self] _ -> Observable<SDKUIIndependentViewsActionSettings> in
                guard let self else { return .empty() }
                return self.actionSettings
                    .take(1)
            }
            .delay(.milliseconds(Metrics.timeForPersistenceToUpdate), scheduler: MainScheduler.asyncInstance)
    }()

    private var _horizontalMargin: CGFloat = 0.0
    var independentViewHorizontalMargin: CGFloat {
        return _horizontalMargin
    }

    // All the stuff which should trigger new pre conversation component
    private lazy var preConversationStyleChanged: Observable<Void> = {
        return self.userDefaultsProvider.values(key: .preConversationStyle, defaultValue: OWPreConversationStyle.default)
            .asObservable()
            .flatMap { [weak self] _ -> Observable<SDKUIIndependentViewType> in
                guard let self else { return .empty() }
                return self.actionSettings
                    .take(1)
                    .map { $0.viewType }
            }
            .filter { $0 == .preConversation }
            .voidify()
    }()
    private lazy var preConversationUpdater: Observable<Void> = {
        return Observable.merge(self.preConversationStyleChanged)
    }()

    // All the stuff which should trigger new conversation component
    private lazy var conversationStyleChanged: Observable<Void> = {
        return self.userDefaultsProvider.values(key: .conversationStyle, defaultValue: OWConversationStyle.default)
            .asObservable()
            .flatMap { [weak self] _ -> Observable<SDKUIIndependentViewType> in
                guard let self else { return .empty() }
                return self.actionSettings
                    .take(1)
                    .map { $0.viewType }
            }
            .filter { $0 == .conversation }
            .voidify()
    }()
    private lazy var conversationUpdater: Observable<Void> = {
        return Observable.merge(self.conversationStyleChanged)
    }()

    private lazy var commentCreationStyleChanged: Observable<Void> = {
        return self.userDefaultsProvider.values(key: .commentCreationStyle, defaultValue: OWCommentCreationStyle.default)
            .asObservable()
            .flatMap { [weak self] _ -> Observable<SDKUIIndependentViewType> in
                guard let self else { return .empty() }
                return self.actionSettings
                    .take(1)
                    .map { $0.viewType }
            }
            .filter { $0 == .commentCreation }
            .voidify()
    }()
    private lazy var commentCreationUpdater: Observable<Void> = {
        return Observable.merge(self.commentCreationStyleChanged)
    }()

    // All the stuff which should trigger new comment thread component
    private lazy var commentThreadStyleChanged: Observable<Void> = {
        return self.userDefaultsProvider.values(key: .conversationStyle, defaultValue: OWConversationStyle.default)
            .asObservable()
            .flatMap { [weak self] _ -> Observable<SDKUIIndependentViewType> in
                guard let self else { return .empty() }
                return self.actionSettings
                    .take(1)
                    .map { $0.viewType }
            }
            .filter { $0 == .commentThread }
            .voidify()
    }()

    private lazy var commentThreadUpdater: Observable<Void> = {
        return Observable.merge(self.commentThreadStyleChanged)
    }()

    // All the stuff which should trigger new comment thread component
    private lazy var independentAdUnitStyleChanged: Observable<Void> = {
        // TODO: Complete once developed
        return Observable.never()
    }()
    private lazy var independentAdUnitUpdater: Observable<Void> = {
        return Observable.merge(self.independentAdUnitStyleChanged)
    }()

    // All the stuff which should trigger new comment thread component
    private lazy var clarityDetailsStyleChanged: Observable<Void> = {
        return Observable.just(())
    }()
    private lazy var clarityDetailsUpdater: Observable<Void> = {
        return Observable.merge(self.clarityDetailsStyleChanged)
    }()
}

private extension MockArticleIndependentViewsViewModel {
    func setupObservers() {
        // Addressing horizontal margin
        viewTypeUpdaters
            .subscribe(onNext: { [weak self] settings in
                guard let self else { return }
                switch settings.viewType {
                case .preConversation:
                    let preConversationStyle = self.userDefaultsProvider.get(key: .preConversationStyle, defaultValue: OWPreConversationStyle.default)
                    self._horizontalMargin = preConversationStyle == OWPreConversationStyle.compact ? Metrics.preConversationCompactHorizontalMargin : 0.0
                default:
                    self._horizontalMargin = 0.0
                }
            })
            .disposed(by: disposeBag)

        // Clear logger
        viewTypeUpdaters
            .voidify()
            .subscribe(onNext: { [weak self] _ in
                guard let self else { return }
                self.loggerViewModel.inputs.clear()
            })
            .disposed(by: disposeBag)
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

    func retrieveComponent(for settings: SDKUIIndependentViewsActionSettings) -> Observable<UIView> {
        switch settings.viewType {
        case .preConversation:
            return self.retrievePreConversation(settings: settings)
        case .conversation:
            return self.retrieveConversation(settings: settings)
        case .commentCreation:
            return self.retrieveCommentCreation(settings: settings)
        case .commentThread:
            return self.retrieveCommentThread(settings: settings)
        case .clarityDetails:
            return self.retrieveClarityDetails(settings: settings)
        default:
            return Observable.error(GeneralErrors.missingImplementation)
        }
    }

    func retrievePreConversation(settings: SDKUIIndependentViewsActionSettings) -> Observable<UIView> {
        return Observable.create { [weak self] observer in
            guard let self else { return Disposables.create() }

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
                        observer.onNext(preConversationView)
                        observer.onCompleted()
                    } catch {
                        let message = error.localizedDescription
                        DLog("Calling retrievePreConversation error: \(message)")
                        observer.onError(error)
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
                        observer.onNext(preConversationView)
                        observer.onCompleted()
                    case .failure(let error):
                        let message = error.description
                        DLog("Calling retrievePreConversation error: \(message)")
                        observer.onError(error)
                    }
                })
            }

            return Disposables.create()
        }
    }

    func retrieveConversation(settings: SDKUIIndependentViewsActionSettings) -> Observable<UIView> {
        return Observable.create { [weak self] observer in
            guard let self else { return Disposables.create() }

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
                        observer.onNext(conversationView)
                        observer.onCompleted()
                    } catch {
                        let message = error.localizedDescription
                        DLog("Calling retrieveConversation error: \(message)")
                        observer.onError(error)
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
                        observer.onNext(conversationView)
                        observer.onCompleted()
                    case .failure(let error):
                        let message = error.description
                        DLog("Calling retrieveConversation error: \(message)")
                        observer.onError(error)
                    }
                })
            }

            return Disposables.create()
        }
    }

    func retrieveCommentCreation(settings: SDKUIIndependentViewsActionSettings) -> Observable<UIView> {
        return Observable.create { [weak self] observer in
            guard let self else { return Disposables.create() }

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
                        observer.onNext(commentCreationView)
                        observer.onCompleted()
                    } catch {
                        let message = error.localizedDescription
                        DLog("Calling retrieveCommentCreation error: \(message)")
                        observer.onError(error)
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
                        observer.onNext(commentCreationView)
                        observer.onCompleted()
                    case .failure(let error):
                        let message = error.description
                        DLog("Calling retrieveCommentCreation error: \(message)")
                        observer.onError(error)
                    }
                })
            }

            return Disposables.create()
        }
    }

    func retrieveCommentThread(settings: SDKUIIndependentViewsActionSettings) -> Observable<UIView> {
        return Observable.create { [weak self] observer in
            guard let self else { return Disposables.create() }

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
                        observer.onNext(commentThreadView)
                        observer.onCompleted()
                    } catch {
                        let message = error.localizedDescription
                        DLog("Calling retrieveCommentThread error: \(message)")
                        observer.onError(error)
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
                        observer.onNext(commentThreadView)
                        observer.onCompleted()
                    case .failure(let error):
                        let message = error.description
                        DLog("Calling retrieveCommentThread error: \(message)")
                        observer.onError(error)
                    }
                })
            }

            return Disposables.create()
        }
    }

    func retrieveClarityDetails(settings: SDKUIIndependentViewsActionSettings) -> Observable<UIView> {
        return Observable.create { [weak self] observer in
            guard let self else { return Disposables.create() }

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
                        observer.onNext(clarityDetailsView)
                        observer.onCompleted()
                    } catch {
                        let message = error.localizedDescription
                        DLog("Calling retrieveClarityDetails error: \(message)")
                        observer.onError(error)
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
                        observer.onNext(clarityDetailsView)
                        observer.onCompleted()
                    case .failure(let error):
                        let message = error.description
                        DLog("Calling retrieveClarityDetails error: \(message)")
                        observer.onError(error)
                    }
                })
            }

            return Disposables.create()
        }
    }

    func shouldUseAsyncAwaitCallingMethod() -> Bool {
        return SampleAppCallingMethod.asyncAwait == userDefaultsProvider.get(key: .callingMethodOption, defaultValue: .default)
    }
}
