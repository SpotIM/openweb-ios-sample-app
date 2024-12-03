//
//  SocialMonetizationExampleViewModel.swift
//  OpenWeb-SampleApp
//
//  Created by Anael on 26/11/2024.
//

import Foundation
import RxSwift
import OpenWebSDK

protocol SocialMonetizationExampleViewModelingInputs {}

protocol SocialMonetizationExampleViewModelingOutputs {
    var title: String { get }
    var loggerViewModel: UILoggerViewModeling { get }
    var showAdView: Observable<UIView> { get }
}

protocol SocialMonetizationExampleViewModeling {
    var inputs: SocialMonetizationExampleViewModelingInputs { get }
    var outputs: SocialMonetizationExampleViewModelingOutputs { get }
}

class SocialMonetizationExampleViewModel: SocialMonetizationExampleViewModeling, SocialMonetizationExampleViewModelingOutputs, SocialMonetizationExampleViewModelingInputs {
    var inputs: SocialMonetizationExampleViewModelingInputs { return self }
    var outputs: SocialMonetizationExampleViewModelingOutputs { return self }
    
    private let postId: OWPostId
    private let _showAdView = BehaviorSubject<UIView?>(value: nil)
    var showAdView: Observable<UIView> {
        return _showAdView
            .unwrap()
            .asObservable()
    }

    init(postId: OWPostId) {
        self.postId = postId
        setupObservers()
    }

    lazy var title: String = {
        return NSLocalizedString("SingleAdExample", comment: "")
    }()

    lazy var loggerViewModel: UILoggerViewModeling = {
        return UILoggerViewModel(title: "Social monetization logger")
    }()
}

private extension SocialMonetizationExampleViewModel {
    func setupObservers() {
        let adConfiguration = OWIAUAdConfiguration.server(remote: .tmsServer(index: 0))
        let adSettings: OWIAUAdSettingsProtocol = OWIAUAdSettings(configuration: adConfiguration)
        let viewEventCallbacks: OWIAUAdViewEventsCallbacks = { [weak self] eventType, _, _ in
            self?.loggerViewModel.inputs.log(text: eventType.description)
        }
        OpenWeb.manager.monetization.ui.ad(postId: postId,
                                           settings: adSettings,
                                           viewEventCallbacks: viewEventCallbacks,
                                           actionsCallbacks: nil,
                                           completion: { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let adView):
                _showAdView.onNext(adView)
            case .failure(let error):
                DLog("Social monetization example failed: \(error.localizedDescription)")
            }
        })
    }
}
