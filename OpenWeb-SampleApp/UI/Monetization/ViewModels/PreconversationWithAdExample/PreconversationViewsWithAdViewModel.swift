//
//  PreconversationViewsWithAdViewModel.swift
//  OpenWeb-SampleApp
//
//  Created by Anael on 15/01/2025.
//

 import Foundation
 import Combine
 import OpenWebSDK

 protocol PreconversationViewsWithAdViewModelingInput {
     func setNavigationController(_ navController: UINavigationController?)
     func setPresentationalVC(_ viewController: UIViewController)
 }

 protocol PreconversationViewsWithAdViewModelingOutput {
     var title: String { get }
     var articleImageURL: AnyPublisher<URL, Never> { get }
     var preconversationCellViewModel: PreconversationCellViewModeling { get }
     var independentAdCellViewModel: IndependentAdCellViewModeling { get }
     var cells: AnyPublisher<[PreconversationWithAdCellOption], Never> { get }
     var loggerEnabled: AnyPublisher<Bool, Never> { get }
     var floatingViewViewModel: OWFloatingViewModeling { get }
     var loggerViewModel: UILoggerViewModeling { get }
 }

 protocol PreconversationViewsWithAdViewModeling {
    var inputs: PreconversationViewsWithAdViewModelingInput { get }
    var outputs: PreconversationViewsWithAdViewModelingOutput { get }
 }

class PreconversationViewsWithAdViewModel: PreconversationViewsWithAdViewModeling,
                                                         PreconversationViewsWithAdViewModelingOutput,
                                                         PreconversationViewsWithAdViewModelingInput {

    var inputs: PreconversationViewsWithAdViewModelingInput { self }
    var outputs: PreconversationViewsWithAdViewModelingOutput { self }

    private var cancellables = Set<AnyCancellable>()
    private let userDefaultsProvider: UserDefaultsProviderProtocol
    private let commonCreatorService: CommonCreatorServicing
    private let imageProviderAPI: ImageProviding
    private weak var navController: UINavigationController?
    private weak var presentationalVC: UIViewController?
    private let postId: OWPostId
    private let _actionSettings = CurrentValueSubject<SDKUIIndependentViewsActionSettings?, Never>(value: nil)
    private var actionSettings: AnyPublisher<SDKUIIndependentViewsActionSettings, Never> {
        return _actionSettings
            .unwrap()
            .eraseToAnyPublisher()
    }

    lazy var title: String = {
        return NSLocalizedString("MockArticle", comment: "")
    }()

    private let _articleImageURL = CurrentValueSubject<URL?, Never>(value: nil)
     var cells: AnyPublisher<[PreconversationWithAdCellOption], Never> = Just(PreconversationWithAdCellOption.cells).eraseToAnyPublisher()
    var articleImageURL: AnyPublisher<URL, Never> {
        return _articleImageURL
            .unwrap()
            .eraseToAnyPublisher()
    }

    lazy var floatingViewViewModel: OWFloatingViewModeling = {
        return OWFloatingViewModel()
    }()

    lazy var preconversationCellViewModel: PreconversationCellViewModeling = {
        PreconversationCellViewModel(showPreConversation: showPreConversation,
                                     adSizeChanged: adSizeChanged)
    }()

    private let _adSizeChanged = PassthroughSubject<Void, Never>()
    var adSizeChanged: AnyPublisher<Void, Never> {
        return _adSizeChanged
            .eraseToAnyPublisher()
    }

    lazy var independentAdCellViewModel: IndependentAdCellViewModeling = {
        IndependentAdCellViewModel(postId: postId)
    }()

    lazy var loggerEnabled: AnyPublisher<Bool, Never> = {
        return userDefaultsProvider.values(key: .flowsLoggerEnabled, defaultValue: false)
    }()

    lazy var loggerViewModel: UILoggerViewModeling = {
        return UILoggerViewModel(title: "Logger")
    }()

    private let _showPreConversation = CurrentValueSubject<UIView?, Never>(value: nil)
    var showPreConversation: AnyPublisher<UIView?, Never> {
        return _showPreConversation
            .eraseToAnyPublisher()
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
        _actionSettings.send(actionSettings)
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
        _articleImageURL.send(articleURL)

        independentAdCellViewModel.outputs.loggerEvents
            .sink(receiveValue: { [weak self] logEvent in
                self?.loggerViewModel.inputs.log(text: logEvent)
            })
            .store(in: &cancellables)

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
            .delay(for: .milliseconds(50), scheduler: DispatchQueue.global(qos: .userInteractive))
            .withLatestFrom(loggerEnabled) { result, loggerEnabled -> (String, Bool) in
                return (result, loggerEnabled)
            }
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] result in
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
                            _showPreConversation.send(preConversationView)
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
                            _showPreConversation.send(preConversationView)

                        case .failure(let error):
                            let message = error.description
                            DLog("Calling Views PreConversation error: \(message)")
                        }
                    })
                }
            })
            .store(in: &cancellables)
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
                _adSizeChanged.send()
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
