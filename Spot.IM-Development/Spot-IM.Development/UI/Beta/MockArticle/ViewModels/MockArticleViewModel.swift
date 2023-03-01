//
//  MockArticleViewModel.swift
//  Spot-IM.Development
//
//  Created by Alon Haiut on 04/09/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift
import SpotImCore

#if NEW_API

protocol MockArticleViewModelingInputs {
    func setNavigationController(_ navController: UINavigationController?)
    func setPresentationalVC(_ viewController: UIViewController)
    var fullConversationButtonTapped: PublishSubject<Void> { get }
    var commentCreationButtonTapped: PublishSubject<Void> { get }
}

protocol MockArticleViewModelingOutputs {
    var title: String { get }
    var showFullConversationButton: Observable<PresentationalModeCompact> { get }
    var showCommentCreationButton: Observable<PresentationalModeCompact> { get }
    var showPreConversation: Observable<UIView> { get }
    var updatePreConversationSize: Observable<UIView> { get }
    var articleImageURL: Observable<URL> { get }
    var showError: Observable<String> { get }
}

protocol MockArticleViewModeling {
    var inputs: MockArticleViewModelingInputs { get }
    var outputs: MockArticleViewModelingOutputs { get }
}

class MockArticleViewModel: MockArticleViewModeling, MockArticleViewModelingInputs, MockArticleViewModelingOutputs {
    var inputs: MockArticleViewModelingInputs { return self }
    var outputs: MockArticleViewModelingOutputs { return self }

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

    fileprivate let _actionSettings = BehaviorSubject<SDKUIFlowActionSettings?>(value: nil)
    fileprivate var actionSettings: Observable<SDKUIFlowActionSettings> {
        return _actionSettings
            .unwrap()
            .asObservable()
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

    fileprivate let _updatePreConversationSize = PublishSubject<UIView>()
    var updatePreConversationSize: Observable<UIView> {
        return _updatePreConversationSize
            .asObservable()
    }

    let fullConversationButtonTapped = PublishSubject<Void>()
    var commentCreationButtonTapped = PublishSubject<Void>()

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

    lazy var title: String = {
        return NSLocalizedString("MockArticle", comment: "")
    }()

    init(imageProviderAPI: ImageProviding = ImageProvider(),
         actionSettings: SDKUIFlowActionSettings) {
        self.imageProviderAPI = imageProviderAPI
        _actionSettings.onNext(actionSettings)
        setupObservers()
    }

    func setNavigationController(_ navController: UINavigationController?) {
        self.navController = navController
    }

    func setPresentationalVC(_ viewController: UIViewController) {
        presentationalVC = viewController
    }
}

fileprivate extension MockArticleViewModel {
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

                var manager = OpenWeb.manager
                let flows = manager.ui.flows

                guard let presentationalMode = self.presentationalMode(fromCompactMode: mode) else { return }

                flows.preConversation(postId: postId,
                                   article: self.createMockArticle(),
                                   presentationalMode: presentationalMode,
                                   additionalSettings: nil,
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

                flows.conversation(postId: postId,
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
    }
    // swiftlint:enable function_body_length

    func createMockArticle() -> OWArticle {
        let articleStub = OWArticle.stub()

        // swiftlint:disable line_length
        let persistenceReadOnlyMode = OWReadOnlyMode.modeFromPersistence(index: UserDefaultsProvider.shared.get(key: .readOnlyModeIndex, defaultValue: 0))
        // swiftlint:enable line_length
        let settings = OWArticleSettings(section: articleStub.additionalSettings.section,
                                         readOnlyMode: persistenceReadOnlyMode)

        var url = articleStub.url
        if let strURL =  UserDefaultsProvider.shared.get(key: UserDefaultsProvider.UDKey<String>.articleAssociatedURL),
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
