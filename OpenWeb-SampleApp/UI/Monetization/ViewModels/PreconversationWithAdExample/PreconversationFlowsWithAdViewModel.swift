//
//  PreconversationFlowsWithAdViewModel.swift
//  OpenWeb-SampleApp
//
//  Created by Anael on 11/12/2024.
//

import Combine
import UIKit
import OpenWebSDK

protocol PreconversationFlowsWithAdViewModelingInputs {
    func setNavigationController(_ navController: UINavigationController?)
    func setPresentationalVC(_ viewController: UIViewController)
}

protocol PreconversationFlowsWithAdViewModelingOutputs {
    var title: String { get }
    var articleImageURL: AnyPublisher<URL, Never> { get }
    var preconversationCellViewModel: PreconversationCellViewModeling { get }
    var independentAdCellViewModel: IndependentAdCellViewModeling { get }
    var cells: AnyPublisher<[PreconversationWithAdCellOption], Never> { get }
    var loggerEnabled: AnyPublisher<Bool, Never> { get }
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

    private var cancellables = Set<AnyCancellable>()
    private let imageProviderAPI: ImageProviding
    private let postId: OWPostId
    private let userDefaultsProvider: UserDefaultsProviderProtocol
    private let commonCreatorService: CommonCreatorServicing
    private weak var navController: UINavigationController?
    private weak var presentationalVC: UIViewController?
    var cells: AnyPublisher<[PreconversationWithAdCellOption], Never> = Just(PreconversationWithAdCellOption.cells).eraseToAnyPublisher()

    private let _articleImageURL = CurrentValueSubject<URL?, Never>(value: nil)
    var articleImageURL: AnyPublisher<URL, Never> {
        return _articleImageURL
            .unwrap()
            .eraseToAnyPublisher()
    }

    private let _actionSettings = CurrentValueSubject<SDKUIFlowActionSettings?, Never>(value: nil)
    private var actionSettings: AnyPublisher<SDKUIFlowActionSettings, Never> {
        return _actionSettings
            .unwrap()
            .eraseToAnyPublisher()
    }

    private let _showPreConversation = CurrentValueSubject<UIView?, Never>(value: nil)
    var showPreConversation: AnyPublisher<UIView?, Never> {
        return _showPreConversation
            .eraseToAnyPublisher()
    }

    private let _adSizeChanged = PassthroughSubject<Void, Never>()
    var adSizeChanged: AnyPublisher<Void, Never> {
        return _adSizeChanged
            .eraseToAnyPublisher()
    }

    lazy var loggerEnabled: AnyPublisher<Bool, Never> = {
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

private extension PreconversationFlowsWithAdViewModel {
    func setupObservers() {
        let articleURL = imageProviderAPI.randomImageUrl()
        _articleImageURL.send(articleURL)

        independentAdCellViewModel.outputs.loggerEvents
            .sink(receiveValue: { [weak self] logEvent in
                self?.loggerViewModel.inputs.log(text: logEvent)
            })
            .store(in: &cancellables)

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
            .delay(for: .milliseconds(50), scheduler: DispatchQueue.global(qos: .userInteractive))
            .withLatestFrom(loggerEnabled) { result, loggerEnabled -> (PresentationalModeCompact, String, Bool) in
                return (result.0, result.1, loggerEnabled)
            }
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] result in
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
                            _showPreConversation.send(preConversationView)
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
                            self._showPreConversation.send(preConversationView)
                        case .failure(let error):
                            DLog("Calling flows.preConversation error: \(error)")
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

    func actionCallbacks(loggerEnabled: Bool) -> OWFlowActionsCallbacks? {
        return { [weak self] callbackType, sourceType, postId in
            guard let self else { return }

            switch callbackType {
            case .adSizeChanged:
                _adSizeChanged.send()
            case let .adEvent(event, index):
                let log = "AdEvent (index: \(index)): \(event.description)\n"
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
              let presentationalVC else { return nil }

        switch mode {
        case .present(let style):
            return OWPresentationalMode.present(viewController: presentationalVC, style: style)
        case .push:
            return OWPresentationalMode.push(navigationController: navController)
        }
    }
}
