//
//  PreconversationViewsWithAdViewModel.swift
//  OpenWeb-SampleApp
//
//  Created by Anael on 15/01/2025.
//

 import Foundation
 import RxSwift
 import OpenWebSDK

 protocol PreconversationViewsWithAdViewModelingInput {
     func setNavigationController(_ navController: UINavigationController?)
     func setPresentationalVC(_ viewController: UIViewController)
 }

 protocol PreconversationViewsWithAdViewModelingOutput {
     var title: String { get }
     var articleImageURL: Observable<URL> { get }
     var preconversationCellViewModel: PreconversationCellViewModeling { get }
     var independentAdCellViewModel: IndependentAdCellViewModeling { get }
     var cells: Observable<[PreconversationWithAdCellOption]> { get }
     var loggerEnabled: Observable<Bool> { get }
     var floatingViewViewModel: OWFloatingViewModeling { get }
     var loggerViewModel: UILoggerViewModeling { get }
 }

 protocol PreconversationViewsWithAdViewModeling {
    var inputs: PreconversationViewsWithAdViewModelingInput { get }
    var outputs: PreconversationViewsWithAdViewModelingOutput { get }
 }

 public final class PreconversationViewsWithAdViewModel: PreconversationViewsWithAdViewModeling,
                                                         PreconversationViewsWithAdViewModelingOutput,
                                                         PreconversationViewsWithAdViewModelingInput {

    var inputs: PreconversationViewsWithAdViewModelingInput { self }
    var outputs: PreconversationViewsWithAdViewModelingOutput { self }

    private let disposeBag = DisposeBag()
    private let userDefaultsProvider: UserDefaultsProviderProtocol
    private let commonCreatorService: CommonCreatorServicing
    private let imageProviderAPI: ImageProviding
    private weak var navController: UINavigationController?
    private weak var presentationalVC: UIViewController?
    private let postId: OWPostId
    private let _actionSettings = BehaviorSubject<SDKUIIndependentViewsActionSettings?>(value: nil)
    private var actionSettings: Observable<SDKUIIndependentViewsActionSettings> {
        return _actionSettings
            .unwrap()
            .asObservable()
    }

    lazy var title: String = {
        return NSLocalizedString("MockArticle", comment: "")
    }()

    private let _articleImageURL = BehaviorSubject<URL?>(value: nil)
    var cells: Observable<[PreconversationWithAdCellOption]> = Observable.just(PreconversationWithAdCellOption.cells)
    var articleImageURL: Observable<URL> {
        return _articleImageURL
            .unwrap()
            .asObservable()
    }

    lazy var floatingViewViewModel: OWFloatingViewModeling = {
        return OWFloatingViewModel()
    }()

    lazy var preconversationCellViewModel: PreconversationCellViewModeling = {
        PreconversationCellViewModel(showPreConversation: showPreConversation,
                                     adSizeChanged: adSizeChanged)
    }()

    private let _adSizeChanged = PublishSubject<Void>()
    var adSizeChanged: Observable<Void> {
        return _adSizeChanged
            .asObservable()
    }

    lazy var independentAdCellViewModel: IndependentAdCellViewModeling = {
        IndependentAdCellViewModel(postId: postId)
    }()

    lazy var loggerEnabled: Observable<Bool> = {
        return userDefaultsProvider.values(key: .flowsLoggerEnabled, defaultValue: false)
    }()

    lazy var loggerViewModel: UILoggerViewModeling = {
        return UILoggerViewModel(title: "Logger")
    }()

    private let _showPreConversation = BehaviorSubject<UIView?>(value: nil)
    var showPreConversation: Observable<UIView?> {
        return _showPreConversation
            .asObservable()
    }

    init(userDefaultsProvider: UserDefaultsProviderProtocol = UserDefaultsProvider.shared,
         commonCreatorService: CommonCreatorServicing = CommonCreatorService(),
         imageProviderAPI: ImageProviding = ImageProvider(),
         actionSettings: SDKUIIndependentViewsActionSettings,
         postId: OWPostId) {
        self.userDefaultsProvider = userDefaultsProvider
        self.imageProviderAPI = imageProviderAPI
        self.commonCreatorService = commonCreatorService
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

 private extension PreconversationViewsWithAdViewModel {
    func setupObservers() {
        let articleURL = imageProviderAPI.randomImageUrl()
        _articleImageURL.onNext(articleURL)

        independentAdCellViewModel.outputs.loggerEvents
            .subscribe(onNext: { [weak self] logEvent in
                self?.loggerViewModel.inputs.log(text: logEvent)
            })
            .disposed(by: disposeBag)

        actionSettings
            .map { settings -> String? in
                if case .preConversation = settings.viewType {
                    return settings.postId
                } else {
                    return nil
                }
            }
            .unwrap()
        // Small delay so the navigation controller will be set from the view controller
            .delay(.milliseconds(50), scheduler: ConcurrentDispatchQueueScheduler(qos: .userInteractive))
            .withLatestFrom(loggerEnabled) { result, loggerEnabled -> (String, Bool) in
                return (result, loggerEnabled)
            }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] result in
                guard let self else { return }
                let postId = result.0
                let loggerEnabled = result.1

                let manager = OpenWeb.manager
                let uiViews = manager.ui.views

                let additionalSettings = self.commonCreatorService.additionalSettings()
                let article = self.commonCreatorService.mockArticle(for: manager.spotId)

                if shouldUseAsyncAwaitCallingMethod() {
                    Task { @MainActor [weak self] in
                        guard let self else { return }
                        do {
                            let preConversationView = try await uiViews.preConversation(
                                postId: postId,
                                article: article,
                                additionalSettings: additionalSettings,
                                callbacks: actionCallbacks(loggerEnabled: loggerEnabled)
                            )
                            _showPreConversation.onNext(preConversationView)
                        } catch {
                            let message = error.localizedDescription
                            DLog("Calling Views PreConversation error: \(message)")
                        }
                    }
                } else {
                    uiViews.preConversation(postId: postId,
                                            article: article,
                                            additionalSettings: additionalSettings,
                                            callbacks: actionCallbacks(loggerEnabled: loggerEnabled),
                                            completion: { [weak self] result in
                        guard let self else { return }
                        switch result {
                        case .success(let preConversationView):
                            _showPreConversation.onNext(preConversationView)

                        case .failure(let error):
                            let message = error.description
                            DLog("Calling Views PreConversation error: \(message)")
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

    func actionCallbacks(loggerEnabled: Bool) -> OWViewActionsCallbacks? {
        return { [weak self] callbackType, sourceType, postId in
            guard let self else { return }

            switch callbackType {
            case .adSizeChanged:
                _adSizeChanged.onNext()
            case let .adEvent(event, index):
                guard loggerEnabled else { return }
                let log = "preconversationAd: \(event.description) for index: \(index)\n"
                self.loggerViewModel.inputs.log(text: log)
            default:
                guard loggerEnabled else { return }
                let log = "Received OWViewActionsCallback type: \(callbackType), from source: \(sourceType), postId: \(postId)\n"
                self.loggerViewModel.inputs.log(text: log)
            }
        }
    }

    func shouldUseAsyncAwaitCallingMethod() -> Bool {
        return SampleAppCallingMethod.asyncAwait == userDefaultsProvider.get(key: .callingMethodOption, defaultValue: .default)
    }
 }
