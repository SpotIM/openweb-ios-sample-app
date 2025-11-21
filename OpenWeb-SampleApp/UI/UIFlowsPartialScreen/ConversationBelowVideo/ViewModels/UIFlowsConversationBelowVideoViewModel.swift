//
//  UIFlowsConversationBelowVideoViewModel.swift
//  OpenWeb-SampleApp
//
//  Created by Alon Shprung on 28/09/2025.
//

import Combine
import OpenWebSDK

protocol UIFlowsConversationBelowVideoViewModelingInputs {}

protocol UIFlowsConversationBelowVideoViewModelingOutputs {
    var title: String { get }
    var componentRetrievingError: AnyPublisher<OWError, Never> { get }
    var preConversationRetrieved: AnyPublisher<UIView, Never> { get }
    var conversationRetrieved: AnyPublisher<UIViewController, Never> { get }
    var openAuthentication: AnyPublisher<(OWSpotId, OWBasicCompletion), Never> { get }
    var videoExampleViewModel: VideoExampleViewModeling { get }
}

protocol UIFlowsConversationBelowVideoViewModeling {
    var inputs: UIFlowsConversationBelowVideoViewModelingInputs { get }
    var outputs: UIFlowsConversationBelowVideoViewModelingOutputs { get }
}

class UIFlowsConversationBelowVideoViewModel: UIFlowsConversationBelowVideoViewModeling, UIFlowsConversationBelowVideoViewModelingOutputs, UIFlowsConversationBelowVideoViewModelingInputs {

    var inputs: UIFlowsConversationBelowVideoViewModelingInputs { return self }
    var outputs: UIFlowsConversationBelowVideoViewModelingOutputs { return self }

    private let postId: OWPostId
    private let userDefaultsProvider: UserDefaultsProviderProtocol
    private let commonCreatorService: CommonCreatorServicing

    lazy var title: String = {
        return NSLocalizedString("VideoExample", comment: "")
    }()

    let videoExampleViewModel: VideoExampleViewModeling = VideoExampleViewModel()

    private let _componentRetrievingError = PassthroughSubject<OWError?, Never>()
    var componentRetrievingError: AnyPublisher<OWError, Never> {
        return _componentRetrievingError
            .unwrap()
            .eraseToAnyPublisher()
    }

    private let _preConversationRetrieved = CurrentValueSubject<UIView?, Never>(value: nil)
    var preConversationRetrieved: AnyPublisher<UIView, Never> {
        return _preConversationRetrieved
            .unwrap()
            .eraseToAnyPublisher()
    }

    private let _conversationRetrieved = CurrentValueSubject<UIViewController?, Never>(value: nil)
    var conversationRetrieved: AnyPublisher<UIViewController, Never> {
        return _conversationRetrieved
            .unwrap()
            .eraseToAnyPublisher()
    }

    private let _openAuthentication = PassthroughSubject<(OWSpotId, OWBasicCompletion), Never>()
    var openAuthentication: AnyPublisher<(OWSpotId, OWBasicCompletion), Never> {
        return _openAuthentication
            .eraseToAnyPublisher()
    }

    init(postId: OWPostId,
         userDefaultsProvider: UserDefaultsProviderProtocol = UserDefaultsProvider.shared,
         commonCreatorService: CommonCreatorServicing = CommonCreatorService()) {
        self.postId = postId
        self.userDefaultsProvider = userDefaultsProvider
        self.commonCreatorService = commonCreatorService
        setupObservers()
        initialSetup()
    }

    // Providing `displayAuthenticationFlow` callback
    private lazy var authenticationFlowCallback: OWAuthenticationFlowCallback = { [weak self] _, completion in
        guard let self else { return }
        self._openAuthentication.send((OpenWeb.manager.spotId, completion))
    }

    private lazy var actionsCallbacks: OWPreConversationActionsCallbacks = { [weak self] callbackType, postId in
        guard let self else { return }

        let log = "Received OWPreConversationActionsCallbacks type: \(callbackType), postId: \(postId)\n"
        DLog(log)
        switch callbackType {
        case .openConversationFlow(let route):
            retrieveConversationComponent(route: route)
        default:
            break
        }
    }
}

private extension UIFlowsConversationBelowVideoViewModel {
    func initialSetup() {
        // Setup authentication flow callback
        let authenticationUI = OpenWeb.manager.ui.authenticationUI
        authenticationUI.displayAuthenticationFlow = authenticationFlowCallback

        // Setup renew SSO callback
        let authentication = OpenWeb.manager.authentication
        authentication.renewSSO = commonCreatorService.renewSSOCallback

        retrievePreConversationComponent()
    }

    func setupObservers() {}

    func retrievePreConversationComponent() {
        let uiViewsLayer = OpenWeb.manager.ui.views
        let article = self.commonCreatorService.mockArticle(for: OpenWeb.manager.spotId)

        let additionalSettings = self.commonCreatorService.additionalSettings()

        if shouldUseAsyncAwaitCallingMethod() {
            Task { @MainActor [weak self] in
                guard let self else { return }
                do {
                    let view = try await uiViewsLayer.preConversation(
                        postId: postId,
                        article: article,
                        additionalSettings: additionalSettings,
                        callbacks: self.actionsCallbacks
                    )
                    self._preConversationRetrieved.send(view)
                } catch {
                    guard let err: OWError = error as? OWError else { return }
                    self._componentRetrievingError.send(err)
                }
            }
        } else {
            uiViewsLayer.preConversation(postId: self.postId,
                                         article: article,
                                         additionalSettings: additionalSettings,
                                         callbacks: self.actionsCallbacks,
                                         completion: { [weak self] result in

                guard let self else { return }
                switch result {
                case .failure(let err):
                    self._componentRetrievingError.send(err)
                case .success(let view):
                    self._preConversationRetrieved.send(view)
                }
            })
        }
    }

    func retrieveConversationComponent(route: OWConversationRoute = .none) {
        let uiFlowsLayer = OpenWeb.manager.ui.flows
        let article = self.commonCreatorService.mockArticle(for: OpenWeb.manager.spotId)

        let additionalSettings = self.commonCreatorService.additionalSettings()

        if shouldUseAsyncAwaitCallingMethod() {
            Task { @MainActor [weak self] in
                guard let self else { return }
                do {
                    let conversationViewController = try await uiFlowsLayer.conversation(
                        postId: postId,
                        article: article,
                        route: route,
                        additionalSettings: additionalSettings
                    )
                    self._conversationRetrieved.send(conversationViewController)
                } catch {
                    guard let err: OWError = error as? OWError else { return }
                    self._componentRetrievingError.send(err)
                }
            }
        } else {
            uiFlowsLayer.conversation(postId: postId,
                                      article: article,
                                      route: route,
                                      additionalSettings: additionalSettings,
                                      completion: { [weak self] result in
                guard let self else { return }
                switch result {
                case .success(let conversationViewController):
                    self._conversationRetrieved.send(conversationViewController)
                case .failure(let error):
                    self._componentRetrievingError.send(error)
                }
            })
        }
    }

    func shouldUseAsyncAwaitCallingMethod() -> Bool {
        return SampleAppCallingMethod.asyncAwait == userDefaultsProvider.get(key: .callingMethodOption, defaultValue: .default)
    }
}
