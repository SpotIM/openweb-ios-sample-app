//
//  IndependentAdCellViewModel.swift
//  OpenWeb-SampleApp
//
//  Created by Anael on 24/12/2024.
//

import UIKit
import Combine
import OpenWebSDK
#if ADS
import OpenWebIAUSDK
#endif

protocol IndependentAdCellViewModelingInput {}

protocol IndependentAdCellViewModelingOutput {
    var adView: AnyPublisher<UIView, Never> { get }
    var adSizeChanged: AnyPublisher<Void, Never> { get }
    var loggerEvents: AnyPublisher<String, Never> { get }
}

protocol IndependentAdCellViewModeling {
    var inputs: IndependentAdCellViewModelingInput { get }
    var outputs: IndependentAdCellViewModelingOutput { get }
}

public final class IndependentAdCellViewModel: IndependentAdCellViewModeling,
                                               IndependentAdCellViewModelingOutput,
                                               IndependentAdCellViewModelingInput {
    var inputs: IndependentAdCellViewModelingInput { self }
    var outputs: IndependentAdCellViewModelingOutput { self }

    private let postId: OWPostId
    private let _adView = CurrentValueSubject<UIView?, Never>(value: nil)
    var adView: AnyPublisher<UIView, Never> {
        return _adView
            .unwrap()
            .eraseToAnyPublisher()
    }

    private let _adSizeChanged = PassthroughSubject<Void, Never>()
    var adSizeChanged: AnyPublisher<Void, Never> {
        return _adSizeChanged
            .eraseToAnyPublisher()
    }

    private let _loggerEvents = PassthroughSubject<String, Never>()
    var loggerEvents: AnyPublisher<String, Never> {
        _loggerEvents.eraseToAnyPublisher()
    }

    public init(postId: OWPostId) {
        self.postId = postId
        setupObservers()
    }
}

private extension IndependentAdCellViewModel {
    func setupObservers() {
        #if ADS
        let adConfiguration = OWIAUAdConfiguration.server(remote: .tmsServer(index: 0))
        let adSettings: OWIAUAdSettingsProtocol = OWIAUAdSettings(configuration: adConfiguration)

        let viewEventCallbacks: OWIAUAdViewEventsCallbacks = { [weak self] eventType, _, _ in
            self?._loggerEvents.send("IndependentAd: \(eventType.description)\n")
        }

        OpenWebIAU.manager.ui.ad(
            postId: postId,
            settings: adSettings,
            viewEventCallbacks: viewEventCallbacks,
            actionsCallbacks: { [weak self] event, _, _ in
                switch event {
                case .adSizeChanged:
                    self?._adSizeChanged.send()
                default:
                    break
                }
            },
            completion: { [weak self] result in
                guard let self else { return }
                switch result {
                case .success(let adView):
                    _adView.send(adView)
                case .failure(let error):
                    DLog("Independent Ad Cell failed with error: \(error.localizedDescription)")
                }
            }
        )
        #endif
    }
}
