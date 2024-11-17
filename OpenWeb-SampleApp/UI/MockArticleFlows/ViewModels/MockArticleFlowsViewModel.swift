//
//  MockArticleFlowsViewModel.swift
//  OpenWeb-Development
//
//  Created by Alon Haiut on 04/09/2022.
//  Copyright © 2022 OpenWeb. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import OpenWebSDK
#if !PUBLIC_DEMO_APP
import OpenWeb_SampleApp_Internal_Configs
#endif

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
    var loggerViewModel: UILoggerViewModeling { get }
    var floatingViewViewModel: OWFloatingViewModeling { get }
    var loggerEnabled: Observable<Bool> { get }
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

    lazy var loggerEnabled: Observable<Bool> = {
        return userDefaultsProvider.values(key: .flowsLoggerEnabled, defaultValue: false)
    }()

    private struct Metrics {
        static let preConversationCompactHorizontalMargin: CGFloat = 16.0
    }

    private let disposeBag = DisposeBag()

    private let imageProviderAPI: ImageProviding
    private let silentSSOAuthentication: SilentSSOAuthenticationNewAPIProtocol

    private weak var navController: UINavigationController?
    private weak var presentationalVC: UIViewController?

    private let _articleImageURL = BehaviorSubject<URL?>(value: nil)
    var articleImageURL: Observable<URL> {
        return _articleImageURL
            .unwrap()
            .asObservable()
    }

    private let userDefaultsProvider: UserDefaultsProviderProtocol
    private let commonCreatorService: CommonCreatorServicing

    private let _actionSettings = BehaviorSubject<SDKUIFlowActionSettings?>(value: nil)
    private var actionSettings: Observable<SDKUIFlowActionSettings> {
        return _actionSettings
            .unwrap()
            .asObservable()
    }

    init(userDefaultsProvider: UserDefaultsProviderProtocol = UserDefaultsProvider.shared,
         silentSSOAuthentication: SilentSSOAuthenticationNewAPIProtocol = SilentSSOAuthenticationNewAPI(),
         commonCreatorService: CommonCreatorServicing = CommonCreatorService(),
         imageProviderAPI: ImageProviding = ImageProvider(),
         actionSettings: SDKUIFlowActionSettings) {
        self.imageProviderAPI = imageProviderAPI
        self.silentSSOAuthentication = silentSSOAuthentication
        self.commonCreatorService = commonCreatorService
        self.userDefaultsProvider = userDefaultsProvider
        _actionSettings.onNext(actionSettings)
        setupObservers()
    }

    private let _showError = PublishSubject<String>()
    var showError: Observable<String> {
        return _showError
            .asObservable()
    }

    private let _showPreConversation = PublishSubject<UIView>()
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
            .withLatestFrom(loggerEnabled) { result, loggerEnabled -> (PresentationalModeCompact, String, Bool) in
                return (result.0, result.1, loggerEnabled)
            }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] result in
                guard let self else { return }
                let mode = result.0
                let postId = result.1
                let loggerEnabled = result.2

                let manager = OpenWeb.manager
                let flows = manager.ui.flows

                let additionalSettings = self.commonCreatorService.additionalSettings()
                let article = self.commonCreatorService.mockArticle(for: manager.spotId)

                guard let presentationalMode = self.presentationalMode(fromCompactMode: mode) else { return }

                flows.preConversation(postId: postId,
                                      article: article,
                                      presentationalMode: presentationalMode,
                                      additionalSettings: additionalSettings,
                                      callbacks: loggerActionCallbacks(loggerEnabled: loggerEnabled),
                                      completion: { [weak self] result in
                    guard let self else { return }
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
            .withLatestFrom(loggerEnabled) { result, loggerEnabled -> (PresentationalModeCompact, String, Bool) in
                return (result.0, result.1, loggerEnabled)
            }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] result in
                guard let self else { return }
                let mode = result.0
                let postId = result.1
                let loggerEnabled = result.2

                guard let presentationalMode = self.presentationalMode(fromCompactMode: mode) else { return }

                let manager = OpenWeb.manager
                let flows = manager.ui.flows

                let additionalSettings = self.commonCreatorService.additionalSettings()
                let article = self.commonCreatorService.mockArticle(for: manager.spotId)

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
            .withLatestFrom(loggerEnabled) { result, loggerEnabled -> (PresentationalModeCompact, String, Bool) in
                return (result.0, result.1, loggerEnabled)
            }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] result in
                guard let self else { return }
                let mode = result.0
                let postId = result.1
                let loggerEnabled = result.2

                guard let presentationalMode = self.presentationalMode(fromCompactMode: mode) else { return }

                let manager = OpenWeb.manager
                let flows = manager.ui.flows

                let additionalSettings = self.commonCreatorService.additionalSettings()
                let article = self.commonCreatorService.mockArticle(for: OpenWeb.manager.spotId)

                flows.commentCreation(postId: postId,
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
            .withLatestFrom(loggerEnabled) { result, loggerEnabled -> (PresentationalModeCompact, String, Bool) in
                return (result.0, result.1, loggerEnabled)
            }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] result in
                guard let self else { return }
                let mode = result.0
                let postId = result.1
                let loggerEnabled = result.2

                guard let presentationalMode = self.presentationalMode(fromCompactMode: mode) else { return }

                let manager = OpenWeb.manager
                let flows = manager.ui.flows

                let additionalSettings = self.commonCreatorService.additionalSettings()
                let article = self.commonCreatorService.mockArticle(for: OpenWeb.manager.spotId)

                flows.commentThread(postId: postId,
                                    article: article,
                                    commentId: self.commonCreatorService.commentThreadCommentId(),
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
                        DLog("Calling flows.commentThread error: \(message)")
                        self._showError.onNext(message)
                    }
                })
            })
            .disposed(by: disposeBag)

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

            _ = authenticationVM.outputs.dismissed
                .take(1)
                .subscribe(onNext: { [completion] _ in
                    completion()
                })
        }

        var authenticationUI = OpenWeb.manager.ui.authenticationUI
        authenticationUI.displayAuthenticationFlow = authenticationFlowCallback

        // Providing `renewSSO` callback
        let renewSSOCallback: OWRenewSSOCallback = { [weak self] userId, completion in
            guard let self else { return }
            #if !PUBLIC_DEMO_APP
            let demoSpotId = DevelopmentConversationPreset.demoSpot().toConversationPreset().conversationDataModel.spotId
            if OpenWeb.manager.spotId == demoSpotId,
               let genericSSO = GenericSSOAuthentication.mockModels.first(where: { $0.user.userId == userId }) {
                _ = self.silentSSOAuthentication.silentSSO(for: genericSSO, ignoreLoginStatus: true)
                    .take(1) // No need to disposed since we only take 1
                    .subscribe(onNext: { userId in
                        DLog("Silent SSO completed successfully with userId: \(userId)")
                        completion()
                    }, onError: { error in
                        DLog("Silent SSO failed with error: \(error)")
                        completion()
                    })
            } else {
                DLog("`renewSSOCallback` triggered, but this is not our demo spot: \(demoSpotId)")
                completion()
            }
            #else
            DLog("`renewSSOCallback` triggered")
            #endif
        }

        var authentication = OpenWeb.manager.authentication
        authentication.renewSSO = renewSSOCallback
    }
    // swiftlint:enable function_body_length

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

    func loggerActionCallbacks(loggerEnabled: Bool) -> OWFlowActionsCallbacks? {
        guard loggerEnabled else { return nil }
        return { [weak self] callbackType, sourceType, postId in
            guard let self else { return }
            let log = "Received OWFlowActionsCallback type: \(callbackType), from source: \(sourceType), postId: \(postId)\n"
            self.loggerViewModel.inputs.log(text: log)
        }
    }
}
