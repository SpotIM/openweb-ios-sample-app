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

    lazy var title: String = {
        return NSLocalizedString("VideoExample", comment: "")
    }()

    let videoExampleViewModel: VideoExampleViewModeling = VideoExampleViewModel()

    init(postId: OWPostId,
         commonCreatorService: CommonCreatorServicing = CommonCreatorService(),
         silentSSOAuthentication: SilentSSOAuthenticationNewAPIProtocol = SilentSSOAuthenticationNewAPI()) {
        self.postId = postId
        self.commonCreatorService = commonCreatorService
        setupObservers()
        initialSetup()
    }
}

private extension UIFlowsConversationBelowVideoViewModel {
    func initialSetup() {
        retrieveConversationComponent()
    }
    func setupObservers() {}

    func retrieveConversationComponent() {
    }
}
