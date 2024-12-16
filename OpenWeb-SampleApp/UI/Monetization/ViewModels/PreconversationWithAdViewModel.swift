//
//  PreconversationWithAdViewModel.swift
//  OpenWeb-SampleApp
//
//  Created by Anael on 11/12/2024.
//

import RxSwift
import OpenWebSDK
#if !PUBLIC_DEMO_APP
import OpenWeb_SampleApp_Internal_Configs
#endif

protocol PreconversationWithAdViewModelingInputs {
    func setNavigationController(_ navController: UINavigationController?)
    func setPresentationalVC(_ viewController: UIViewController)
}

protocol PreconversationWithAdViewModelingOutputs {
    var title: String { get }
    var showPreConversation: Observable<UIView> { get }
    var articleImageURL: Observable<URL> { get }
    var showError: Observable<String> { get }
    var preConversationHorizontalMargin: CGFloat { get }
    var loggerViewModel: UILoggerViewModeling { get }
    var floatingViewViewModel: OWFloatingViewModeling { get }
    var loggerEnabled: Observable<Bool> { get }
}

protocol PreconversationWithAdViewModeling {
    var inputs: PreconversationWithAdViewModelingInputs { get }
    var outputs: PreconversationWithAdViewModelingOutputs { get }
}

class PreconversationWithAdViewModel: PreconversationWithAdViewModeling, PreconversationWithAdViewModelingInputs, PreconversationWithAdViewModelingOutputs {
    var inputs: PreconversationWithAdViewModelingInputs { return self }
    var outputs: PreconversationWithAdViewModelingOutputs { return self }

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
        setupBICallaback()
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

private extension PreconversationWithAdViewModel {
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

    func setupBICallaback() {
        let analytics: OWAnalytics = OpenWeb.manager.analytics

        let BIClosure: OWBIAnalyticEventCallback = { [weak self] event, additionalInfo, postId in
            let log = "Received BI Event: \(event), additional info: \(additionalInfo), postId: \(postId)"
            self?.loggerViewModel.inputs.log(text: log)
        }

        analytics.addBICallback(BIClosure)
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
