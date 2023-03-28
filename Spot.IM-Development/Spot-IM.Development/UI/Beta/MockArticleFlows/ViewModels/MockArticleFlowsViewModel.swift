//
//  MockArticleFlowsViewModel.swift
//  Spot-IM.Development
//
//  Created by Alon Haiut on 04/09/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift
import SpotImCore

#if NEW_API

protocol MockArticleFlowsViewModelingInputs {
    func setNavigationController(_ navController: UINavigationController?)
    func setPresentationalVC(_ viewController: UIViewController)
    var fullConversationButtonTapped: PublishSubject<Void> { get }
    var commentCreationButtonTapped: PublishSubject<Void> { get }
    var commentThreadButtonTapped: PublishSubject<Void> { get }
}

protocol MockArticleFlowsViewModelingOutputs {
    var title: String { get }
    var showFullConversationButton: Observable<PresentationalModeCompact> { get }
    var showCommentCreationButton: Observable<PresentationalModeCompact> { get }
    var showPreConversation: Observable<UIView> { get }
    var showCommentThreadButton: Observable<PresentationalModeCompact> { get }
    var articleImageURL: Observable<URL> { get }
    var showError: Observable<String> { get }
    var preConversationHorizontalMargin: CGFloat { get }
}

protocol MockArticleFlowsViewModeling {
    var inputs: MockArticleFlowsViewModelingInputs { get }
    var outputs: MockArticleFlowsViewModelingOutputs { get }
}

class MockArticleFlowsViewModel: MockArticleFlowsViewModeling, MockArticleFlowsViewModelingInputs, MockArticleFlowsViewModelingOutputs {
    var inputs: MockArticleFlowsViewModelingInputs { return self }
    var outputs: MockArticleFlowsViewModelingOutputs { return self }

    fileprivate struct Metrics {
        static let preConversationCompactHorizontalMargin: CGFloat = 16.0
    }

    fileprivate let disposeBag = DisposeBag()

    fileprivate let imageProviderAPI: ImageProviding

    fileprivate weak var navController: UINavigationController?
    fileprivate weak var presentationalVC: UIViewController?

    fileprivate let _articleImageURL = BehaviorSubject<URL?>(value: nil)
    var articleImageURL: Observable<URL> {
        return _articleImageURL
            .unwrap()
            .asObservable()
    }

    fileprivate let userDefaultsProvider: UserDefaultsProviderProtocol

    fileprivate let _actionSettings = BehaviorSubject<SDKUIFlowActionSettings?>(value: nil)
    fileprivate var actionSettings: Observable<SDKUIFlowActionSettings> {
        return _actionSettings
            .unwrap()
            .asObservable()
    }

    init(userDefaultsProvider: UserDefaultsProviderProtocol = UserDefaultsProvider.shared,
         imageProviderAPI: ImageProviding = ImageProvider(),
         actionSettings: SDKUIFlowActionSettings) {
        self.imageProviderAPI = imageProviderAPI
        self.userDefaultsProvider = userDefaultsProvider
        _actionSettings.onNext(actionSettings)
        setupObservers()
    }

    fileprivate let _showError = PublishSubject<String>()
    var showError: Observable<String> {
        return _showError
            .asObservable()
    }

    fileprivate let _showPreConversation = PublishSubject<UIView>()
    var showPreConversation: Observable<UIView> {
        return _showPreConversation
            .asObservable()
    }

    let fullConversationButtonTapped = PublishSubject<Void>()
    let commentCreationButtonTapped = PublishSubject<Void>()
    let commentThreadButtonTapped = PublishSubject<Void>()

    var showFullConversationButton: Observable<PresentationalModeCompact> {
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

    var showCommentCreationButton: Observable<PresentationalModeCompact> {
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

    var showCommentThreadButton: Observable<PresentationalModeCompact> {
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
        let preConversationStyle = OWPreConversationStyle.preConversationStyle(fromData: userDefaultsProvider.get(key: .preConversationCustomStyle, defaultValue: Data()))
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

fileprivate extension MockArticleFlowsViewModel {
    // swiftlint:disable function_body_length
    func setupObservers() {
        let articleURL = imageProviderAPI.randomImageUrl()
        _articleImageURL.onNext(articleURL)

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
            .delay(.milliseconds(50), scheduler: ConcurrentDispatchQueueScheduler(qos: .userInteractive))
            .subscribe(onNext: { [weak self] result in
                guard let self = self else { return }
                let mode = result.0
                let postId = result.1

                let manager = OpenWeb.manager
                let flows = manager.ui.flows

                let preConversationStyle =  OWPreConversationStyle.preConversationStyle(fromData: self.userDefaultsProvider.get(key: .preConversationCustomStyle, defaultValue: Data()))
                let additionalSettings: OWPreConversationSettingsBuilder = .init(style: preConversationStyle)

                guard let presentationalMode = self.presentationalMode(fromCompactMode: mode) else { return }

                flows.preConversation(postId: postId,
                                   article: self.createMockArticle(),
                                   presentationalMode: presentationalMode,
                                   additionalSettings: additionalSettings,
                                   callbacks: nil,
                                   completion: { [weak self] result in
                    guard let self = self else { return }
                    switch result {
                    case .success(let preConversationView):
                        self._showPreConversation.onNext(preConversationView)
                    case .failure(let error):
                        let message = error.description
                        DLog("Calling flows.preConversation error: \(error)")
                        self._showError.onNext(message)
                    }
                })
            })
            .disposed(by: disposeBag)

        // Full conversation
        fullConversationButtonTapped
            .withLatestFrom(showFullConversationButton)
            .withLatestFrom(actionSettings) { mode, settings -> (PresentationalModeCompact, String) in
                return (mode, settings.postId)
            }
            .subscribe(onNext: { [weak self] result in
                guard let self = self else { return }
                let mode = result.0
                let postId = result.1

                guard let presentationalMode = self.presentationalMode(fromCompactMode: mode) else { return }

                let manager = OpenWeb.manager
                let flows = manager.ui.flows

                let styleIndexFromPersistence = self.userDefaultsProvider.get(key: .conversationCustomStyleIndex, defaultValue: OWConversationStyle.defaultIndex)
                let style = OWConversationStyle.conversationStyle(fromIndex: styleIndexFromPersistence)
                let additionalSettings: OWConversationSettingsBuilder = .init(style: style)

                flows.conversation(postId: postId,
                                   article: self.createMockArticle(),
                                   presentationalMode: presentationalMode,
                                   additionalSettings: additionalSettings,
                                   callbacks: nil,
                                   completion: { [weak self] result in
                    guard let self = self else { return }
                    switch result {
                    case .success(_):
                        // All good
                        break
                    case .failure(let error):
                        let message = error.description
                        DLog("Calling flows.conversation error: \(message)")
                        self._showError.onNext(message)
                    }
                })
            })
            .disposed(by: disposeBag)

        // Comment creation
        commentCreationButtonTapped
            .withLatestFrom(showCommentCreationButton)
            .withLatestFrom(actionSettings) { mode, settings -> (PresentationalModeCompact, String) in
                return (mode, settings.postId)
            }
            .subscribe(onNext: { [weak self] result in
                guard let self = self else { return }
                let mode = result.0
                let postId = result.1

                guard let presentationalMode = self.presentationalMode(fromCompactMode: mode) else { return }

                let manager = OpenWeb.manager
                let flows = manager.ui.flows

                flows.commentCreation(postId: postId,
                                      article: self.createMockArticle(),
                                      presentationalMode: presentationalMode,
                                      additionalSettings: nil,
                                      callbacks: nil,
                                      completion: { [weak self] result in
                    guard let self = self else { return }
                    switch result {
                    case .success(_):
                        // All good
                        break
                    case .failure(let error):
                        let message = error.description
                        DLog("Calling flows.commentCreation error: \(message)")
                        self._showError.onNext(message)
                    }
                })
            })
            .disposed(by: disposeBag)

        // Comment creation
        commentThreadButtonTapped
            .withLatestFrom(showCommentThreadButton)
            .withLatestFrom(actionSettings) { mode, settings -> (PresentationalModeCompact, String) in
                return (mode, settings.postId)
            }
            .subscribe(onNext: { [weak self] result in
                guard let self = self else { return }
                let mode = result.0
                let postId = result.1

                guard let presentationalMode = self.presentationalMode(fromCompactMode: mode) else { return }

                let manager = OpenWeb.manager
                let flows = manager.ui.flows

                flows.commentThread(postId: postId,
                                    article: self.createMockArticle(),
                                    commentId: "TODO - Comment ID",
                                    presentationalMode: presentationalMode,
                                    additionalSettings: nil,
                                    callbacks: nil,
                                    completion: { [weak self] result in
                    guard let self = self else { return }
                    switch result {
                    case .success(_):
                        // All good
                        break
                    case .failure(let error):
                        let message = error.description
                        DLog("Calling flows.commentThread error: \(message)")
                        self._showError.onNext(message)
                    }
                })
            })
            .disposed(by: disposeBag)
    }
    // swiftlint:enable function_body_length

    func createMockArticle() -> OWArticle {
        let articleStub = OWArticle.stub()

        // swiftlint:disable line_length
        let persistenceReadOnlyMode = OWReadOnlyMode.readOnlyMode(fromIndex: self.userDefaultsProvider.get(key: .readOnlyModeIndex, defaultValue: OWReadOnlyMode.defaultIndex))
        // swiftlint:enable line_length
        let settings = OWArticleSettings(section: articleStub.additionalSettings.section,
                                         readOnlyMode: persistenceReadOnlyMode)

        var url = articleStub.url
        if let strURL = self.userDefaultsProvider.get(key: UserDefaultsProvider.UDKey<String>.articleAssociatedURL),
           let persistenceURL = URL(string: strURL) {
            url = persistenceURL
        }

        let article = OWArticle(url: url,
                                title: articleStub.title,
                                subtitle: articleStub.subtitle,
                                thumbnailUrl: articleStub.thumbnailUrl,
                                additionalSettings: settings)
        return article
    }

    func presentationalMode(fromCompactMode mode: PresentationalModeCompact) -> OWPresentationalMode? {
        guard let navController = self.navController,
              let presentationalVC = self.presentationalVC else { return nil }

        switch mode {
        case .present(let style):
            return OWPresentationalMode.present(viewController: presentationalVC, style: style)
        case .push:
            return OWPresentationalMode.push(navigationController: navController)
        }
    }
}

#endif
