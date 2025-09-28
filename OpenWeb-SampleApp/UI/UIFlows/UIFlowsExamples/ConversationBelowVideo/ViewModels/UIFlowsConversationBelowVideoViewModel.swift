//
//  UIFlowsConversationBelowVideoViewModel.swift
//  OpenWeb-SampleApp
//
//  Created by Alon Shprung on 28/09/2025.
//

import Combine
import OpenWebSDK
#if !PUBLIC_DEMO_APP
import OpenWeb_SampleApp_Internal_Configs
#endif

protocol UIFlowsConversationBelowVideoViewModelingInputs {}

protocol UIFlowsConversationBelowVideoViewModelingOutputs {
    var title: String { get }
    var componentRetrievingError: AnyPublisher<OWError, Never> { get }
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
    private let commonCreatorService: CommonCreatorServicing
    private let silentSSOAuthentication: SilentSSOAuthenticationNewAPIProtocol
    private lazy var cancellables: Set<AnyCancellable> = []

    lazy var title: String = {
        return NSLocalizedString("VideoExample", comment: "")
    }()

    let videoExampleViewModel: VideoExampleViewModeling = VideoExampleViewModel()

    private let _componentRetrievingError = CurrentValueSubject<OWError?, Never>(value: nil)
    var componentRetrievingError: AnyPublisher<OWError, Never> {
        return _componentRetrievingError
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
         commonCreatorService: CommonCreatorServicing = CommonCreatorService(),
         silentSSOAuthentication: SilentSSOAuthenticationNewAPIProtocol = SilentSSOAuthenticationNewAPI()) {
        self.postId = postId
        self.commonCreatorService = commonCreatorService
        self.silentSSOAuthentication = silentSSOAuthentication
        setupObservers()
        initialSetup()
    }

    // Providing `displayAuthenticationFlow` callback
    private lazy var authenticationFlowCallback: OWAuthenticationFlowCallback = { [weak self] _, completion in
        guard let self else { return }
        self._openAuthentication.send((OpenWeb.manager.spotId, completion))
    }

    // Providing `renewSSO` callback
    private lazy var  renewSSOCallback: OWRenewSSOCallback = { [weak self] userId, completion in
        guard let self else { return }
        #if !PUBLIC_DEMO_APP
        let demoSpotId = DevelopmentConversationPreset.demoSpot().toConversationPreset().conversationDataModel.spotId
        if OpenWeb.manager.spotId == demoSpotId,
           let genericSSO = GenericSSOAuthentication.mockModels.first(where: { $0.user.userId == userId }) {
            self.silentSSOAuthentication.silentSSO(for: genericSSO, ignoreLoginStatus: true)
                .prefix(1) // No need to disposed since we only take 1
                .sink(receiveCompletion: { result in
                    if case .failure(let error) = result {
                        DLog("Silent SSO failed with error: \(error)")
                        completion()
                    }
                }, receiveValue: { userId in
                    DLog("Silent SSO completed successfully with userId: \(userId)")
                    completion()
                })
                .store(in: &cancellables)
        } else {
            DLog("`renewSSOCallback` triggered, but this is not our demo spot: \(demoSpotId)")
            completion()
        }
        #else
        DLog("`renewSSOCallback` triggered")
        #endif
    }
}

private extension UIFlowsConversationBelowVideoViewModel {
    func initialSetup() {
        // Setup authentication flow callback
        let authenticationUI = OpenWeb.manager.ui.authenticationUI
        authenticationUI.displayAuthenticationFlow = authenticationFlowCallback

        // Setup renew SSO callback
        let authentication = OpenWeb.manager.authentication
        authentication.renewSSO = renewSSOCallback

        retrieveConversationComponent()
    }
    func setupObservers() {}

    func retrieveConversationComponent() {
        let uiFlowsLayer = OpenWeb.manager.ui.flows
        let article = self.commonCreatorService.mockArticle(for: OpenWeb.manager.spotId)

        let additionalSettings = OWAdditionalSettings(
            fullConversationSettings: OWConversationSettings(style: .compact),
            commentCreationSettings: OWCommentCreationSettings(style: .floatingKeyboard(accessoryViewStrategy: .none))
        )

        uiFlowsLayer.conversation(postId: postId,
                                  article: article,
                                  additionalSettings: additionalSettings,
                                  callbacks: nil,
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
