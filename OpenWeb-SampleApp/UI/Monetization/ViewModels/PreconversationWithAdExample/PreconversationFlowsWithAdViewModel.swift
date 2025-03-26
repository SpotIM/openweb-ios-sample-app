//
//  PreconversationFlowsWithAdViewModel.swift
//  OpenWeb-SampleApp
//
//  Created by Anael on 11/12/2024.
//

import RxSwift
import OpenWebSDK

protocol PreconversationFlowsWithAdViewModelingInputs {
    func setNavigationController(_ navController: UINavigationController?)
    func setPresentationalVC(_ viewController: UIViewController)
}

protocol PreconversationFlowsWithAdViewModelingOutputs {
    var title: String { get }
    var articleImageURL: Observable<URL> { get }
    var preconversationCellViewModel: PreconversationCellViewModeling { get }
    var independentAdCellViewModel: IndependentAdCellViewModeling { get }
    var cells: Observable<[PreconversationWithAdCellOption]> { get }
    var loggerEnabled: Observable<Bool> { get }
    var floatingViewViewModel: OWFloatingViewModeling { get }
    var loggerViewModel: UILoggerViewModeling { get }
}

protocol PreconversationFlowsWithAdViewModeling {
    var inputs: PreconversationFlowsWithAdViewModelingInputs { get }
    var outputs: PreconversationFlowsWithAdViewModelingOutputs { get }
}

class PreconversationFlowsWithAdViewModel: PreconversationFlowsWithAdViewModeling, PreconversationFlowsWithAdViewModelingInputs, PreconversationFlowsWithAdViewModelingOutputs {

    var inputs: PreconversationFlowsWithAdViewModelingInputs { return self }
    var outputs: PreconversationFlowsWithAdViewModelingOutputs { return self }

    private let disposeBag = DisposeBag()
    private let imageProviderAPI: ImageProviding
    private let postId: OWPostId
    private let userDefaultsProvider: UserDefaultsProviderProtocol
    private let commonCreatorService: CommonCreatorServicing
    private weak var navController: UINavigationController?
    private weak var presentationalVC: UIViewController?
    var cells: Observable<[PreconversationWithAdCellOption]> = Observable.just(PreconversationWithAdCellOption.cells)

    private let _articleImageURL = BehaviorSubject<URL?>(value: nil)
    var articleImageURL: Observable<URL> {
        return _articleImageURL
            .unwrap()
            .asObservable()
    }

    private let _actionSettings = BehaviorSubject<SDKUIFlowActionSettings?>(value: nil)
    private var actionSettings: Observable<SDKUIFlowActionSettings> {
        return _actionSettings
            .unwrap()
            .asObservable()
    }

    private let _showPreConversation = BehaviorSubject<UIView?>(value: nil)
    var showPreConversation: Observable<UIView?> {
        return _showPreConversation
            .asObservable()
    }

    private let _adSizeChanged = PublishSubject<Void>()
    var adSizeChanged: Observable<Void> {
        return _adSizeChanged
            .asObservable()
    }

    lazy var loggerEnabled: Observable<Bool> = {
        return userDefaultsProvider.values(key: .flowsLoggerEnabled, defaultValue: false)
    }()

    lazy var loggerViewModel: UILoggerViewModeling = {
        return UILoggerViewModel(title: "Logger")
    }()

    lazy var floatingViewViewModel: OWFloatingViewModeling = {
        return OWFloatingViewModel()
    }()

    lazy var preconversationCellViewModel: PreconversationCellViewModeling = {
        PreconversationCellViewModel(showPreConversation: showPreConversation,
                                     adSizeChanged: adSizeChanged)
    }()

    lazy var independentAdCellViewModel: IndependentAdCellViewModeling = {
        IndependentAdCellViewModel(postId: postId)
    }()

    lazy var title: String = {
        return NSLocalizedString("MockArticle", comment: "")
    }()

    init(userDefaultsProvider: UserDefaultsProviderProtocol = UserDefaultsProvider.shared,
         commonCreatorService: CommonCreatorServicing = CommonCreatorService(),
         imageProviderAPI: ImageProviding = ImageProvider(),
         actionSettings: SDKUIFlowActionSettings,
         postId: OWPostId
    ) {
        self.userDefaultsProvider = userDefaultsProvider
        self.commonCreatorService = commonCreatorService
        self.imageProviderAPI = imageProviderAPI
        self.postId = postId
        _actionSettings.onNext(actionSettings)
        setupObservers()
        setupBICallaback()
    }

    func setNavigationController(_ navController: UINavigationController?) {
        self.navController = navController
    }

    func setPresentationalVC(_ viewController: UIViewController) {
        presentationalVC = viewController
    }
}

private extension PreconversationFlowsWithAdViewModel {
    func setupObservers() {
        let articleURL = imageProviderAPI.randomImageUrl()
        _articleImageURL.onNext(articleURL)

        independentAdCellViewModel.outputs.loggerEvents
            .subscribe(onNext: { [weak self] logEvent in
                self?.loggerViewModel.inputs.log(text: logEvent)
            })
            .disposed(by: disposeBag)

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

                if shouldUseAsyncAwaitCallingMethod() {
                    Task { @MainActor [weak self] in
                        guard let self else { return }
                        do {
                            let preConversationView = try await flows.preConversation(
                                postId: postId,
                                article: article,
                                presentationalMode: presentationalMode,
                                additionalSettings: additionalSettings,
                                callbacks: actionCallbacks(loggerEnabled: loggerEnabled)
                            )
                            _showPreConversation.onNext(preConversationView)
                        } catch {
                            DLog("Calling flows.preConversation error: \(error)")
                        }
                    }
                } else {
                    flows.preConversation(postId: postId,
                                          article: article,
                                          presentationalMode: presentationalMode,
                                          additionalSettings: additionalSettings,
                                          callbacks: actionCallbacks(loggerEnabled: loggerEnabled),
                                          completion: { [weak self] result in
                        guard let self else { return }
                        switch result {
                        case .success(let preConversationView):
                            self._showPreConversation.onNext(preConversationView)
                        case .failure(let error):
                            DLog("Calling flows.preConversation error: \(error)")
                        }
                    })
                }
            })
            .disposed(by: disposeBag)
    }

    func setupBICallaback() {
        let analytics: OWAnalytics = OpenWeb.manager.analytics

        let BIClosure: OWBIAnalyticEventCallback = { [weak self] event, additionalInfo, postId in
            let log = "Received BI Event: \(event), additional info: \(additionalInfo), postId: \(postId)\n"
            self?.loggerViewModel.inputs.log(text: log)
        }

        analytics.addBICallback(BIClosure)
    }

    func actionCallbacks(loggerEnabled: Bool) -> OWFlowActionsCallbacks? {
        return { [weak self] callbackType, sourceType, postId in
            guard let self else { return }

            switch callbackType {
            case .adSizeChanged:
                _adSizeChanged.onNext()
            case let .adEvent(event, index):
                let log = "preconversationAd: \(event.description) for index: \(index)\n"
                self.loggerViewModel.inputs.log(text: log)
            default:
                guard loggerEnabled else { return }
                let log = "Received OWFlowActionsCallback type: \(callbackType), from source: \(sourceType), postId: \(postId)\n"
                self.loggerViewModel.inputs.log(text: log)
            }
        }
    }

    func shouldUseAsyncAwaitCallingMethod() -> Bool {
        return SampleAppCallingMethod.asyncAwait == userDefaultsProvider.get(key: .callingMethodOption, defaultValue: .default)
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
