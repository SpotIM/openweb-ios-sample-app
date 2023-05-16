//
//  MockArticleIndependentViewsViewModel.swift
//  Spot-IM.Development
//
//  Created by Refael Sommer on 21/03/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import UIKit
import RxSwift
import SpotImCore

#if NEW_API

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

    fileprivate struct Metrics {
        static let preConversationCompactHorizontalMargin: CGFloat = 16.0
        static let timeForPersistenceToUpdate: Int = 100 // In ms
    }

    fileprivate let disposeBag = DisposeBag()
    let settingsTapped = PublishSubject<Void>()

    fileprivate let userDefaultsProvider: UserDefaultsProviderProtocol
    fileprivate let commonCreatorService: CommonCreatorServicing

    fileprivate let _actionSettings = BehaviorSubject<SDKUIIndependentViewsActionSettings?>(value: nil)
    fileprivate var actionSettings: Observable<SDKUIIndependentViewsActionSettings> {
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
        }

        setupCustomizationsCallaback()
        setupObservers()
    }

    var openSettings: Observable<SettingsGroupType> {
        return settingsTapped
            .withLatestFrom(actionSettings)
            .map { SettingsGroupType(independentViewType: $0.viewType) }
            .asObservable()
    }

    fileprivate let loggerViewTitle: String

    lazy var title: String = {
        return NSLocalizedString("MockArticle", comment: "")
    }()

    lazy var loggerViewModel: UILoggerViewModeling = {
        return UILoggerViewModel(title: loggerViewTitle)
    }()

    lazy var showComponent: Observable<ComponentAndType> = {
        return self.viewTypeUpdaters
            .flatMap { [weak self] settings -> Observable<ComponentAndType> in
                guard let self = self else { return .empty() }
                return self.retrieveComponent(for: settings)
                    .map { ($0, settings.viewType) }
            }
    }()

    fileprivate lazy var viewTypeUpdaters: Observable<SDKUIIndependentViewsActionSettings> = {
        return Observable.merge(preConversationUpdater, conversationUpdater, commentCreationUpdater, commentThreadUpdater, independentAdUnitUpdater)
            .flatMapLatest { [weak self] _ -> Observable<SDKUIIndependentViewsActionSettings> in
                guard let self = self else { return .empty() }
                return self.actionSettings
                    .take(1)
            }
            .delay(.milliseconds(Metrics.timeForPersistenceToUpdate), scheduler: MainScheduler.asyncInstance)
    }()

    fileprivate var _horizontalMargin: CGFloat = 0.0
    var independentViewHorizontalMargin: CGFloat {
        return _horizontalMargin
    }

    // All the stuff which should trigger new pre conversation component
    fileprivate lazy var preConversationStyleChanged: Observable<Void> = {
        return self.userDefaultsProvider.values(key: .preConversationStyle, defaultValue: OWPreConversationStyle.default)
            .asObservable()
            .flatMap { [weak self] _ -> Observable<SDKUIIndependentViewType> in
                guard let self = self else { return .empty() }
                return self.actionSettings
                    .take(1)
                    .map { $0.viewType }
            }
            .filter { $0 == .preConversation }
            .voidify()
    }()
    fileprivate lazy var preConversationUpdater: Observable<Void> = {
        return Observable.merge(self.preConversationStyleChanged)
    }()

    // All the stuff which should trigger new conversation component
    fileprivate lazy var conversationStyleChanged: Observable<Void> = {
        return self.userDefaultsProvider.values(key: .conversationStyle, defaultValue: OWConversationStyle.default)
            .asObservable()
            .flatMap { [weak self] _ -> Observable<SDKUIIndependentViewType> in
                guard let self = self else { return .empty() }
                return self.actionSettings
                    .take(1)
                    .map { $0.viewType }
            }
            .filter { $0 == .conversation }
            .voidify()
    }()
    fileprivate lazy var conversationUpdater: Observable<Void> = {
        return Observable.merge(self.conversationStyleChanged)
    }()

    // All the stuff which should trigger new comment creation component
    fileprivate lazy var commentCreationStyleChanged: Observable<Void> = {
        // TODO: Complete once developed
        return Observable.never()
    }()
    fileprivate lazy var commentCreationUpdater: Observable<Void> = {
        return Observable.merge(self.commentCreationStyleChanged)
    }()

    // All the stuff which should trigger new comment thread component
    fileprivate lazy var commentThreadStyleChanged: Observable<Void> = {
        // TODO: Complete once developed
        return Observable.never()
    }()
    fileprivate lazy var commentThreadUpdater: Observable<Void> = {
        return Observable.merge(self.commentThreadStyleChanged)
    }()

    // All the stuff which should trigger new comment thread component
    fileprivate lazy var independentAdUnitStyleChanged: Observable<Void> = {
        // TODO: Complete once developed
        return Observable.never()
    }()
    fileprivate lazy var independentAdUnitUpdater: Observable<Void> = {
        return Observable.merge(self.independentAdUnitStyleChanged)
    }()
}

fileprivate extension MockArticleIndependentViewsViewModel {
    func setupObservers() {
        // Addressing horizontal margin
        viewTypeUpdaters
            .subscribe(onNext: { [weak self] settings in
                guard let self = self else { return }
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
                guard let self = self else { return }
                self.loggerViewModel.inputs.clear()
            })
            .disposed(by: disposeBag)
    }

    func setupCustomizationsCallaback() {
        let customizations: OWCustomizations = OpenWeb.manager.ui.customizations

        let customizableClosure: OWCustomizableElementCallback = { [weak self] element, source, style, postId in
            guard let self = self else { return }
            let postIdString = postId ?? "No postId"
            let log = "Received OWCustomizableElementCallback element: \(element), from source: \(source), style: \(style), postId: \(postIdString)\n"
            self.loggerViewModel.inputs.log(text: log)
        }

        customizations.addElementCallback(customizableClosure)
    }

    func retrieveComponent(for settings: SDKUIIndependentViewsActionSettings) -> Observable<UIView> {
        switch settings.viewType {
        case .preConversation:
            return self.retrievePreConversation(settings: settings)
        case .conversation:
            return self.retrieveConversation(settings: settings)
        default:
            return Observable.error(GeneralErrors.missingImplementation)
        }
    }

    func retrievePreConversation(settings: SDKUIIndependentViewsActionSettings) -> Observable<UIView> {
        return Observable.create { [weak self] observer in
            guard let self = self else { return Disposables.create() }

            let additionalSettings = self.commonCreatorService.preConversationSettings()
            let article = self.commonCreatorService.mockArticle()

            let manager = OpenWeb.manager
            let uiViews = manager.ui.views

            let actionsCallbacks: OWViewActionsCallbacks = { [weak self] callbackType, sourceType, postId in
                guard let self = self else { return }
                let log = "Received OWViewActionsCallback type: \(callbackType), from source: \(sourceType), postId: \(postId)\n"
                self.loggerViewModel.inputs.log(text: log)
            }

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

            return Disposables.create()
        }
    }

    func retrieveConversation(settings: SDKUIIndependentViewsActionSettings) -> Observable<UIView> {
        return Observable.create { [weak self] observer in
            guard let self = self else { return Disposables.create() }

            let additionalSettings = self.commonCreatorService.conversationSettings()
            let article = self.commonCreatorService.mockArticle()

            let manager = OpenWeb.manager
            let uiViews = manager.ui.views

            let actionsCallbacks: OWViewActionsCallbacks = { [weak self] callbackType, sourceType, postId in
                guard let self = self else { return }
                let log = "Received OWViewActionsCallback type: \(callbackType), from source: \(sourceType), postId: \(postId)\n"
                self.loggerViewModel.inputs.log(text: log)
            }

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

            return Disposables.create()
        }
    }
}

#endif
