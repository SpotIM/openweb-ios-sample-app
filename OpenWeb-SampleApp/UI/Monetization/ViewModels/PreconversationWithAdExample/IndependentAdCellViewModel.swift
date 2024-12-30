//
//  IndependentAdCellViewModel.swift
//  OpenWeb-SampleApp
//
//  Created by Anael on 24/12/2024.
//

import Foundation
import RxSwift
import OpenWebSDK

protocol IndependentAdCellViewModelingInput {}

protocol IndependentAdCellViewModelingOutput {
    var adView: Observable<UIView> { get }
    var adSizeChanged: Observable<Void> { get }
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
    private let _adView = BehaviorSubject<UIView?>(value: nil)
    var adView: Observable<UIView> {
        return _adView
            .unwrap()
            .asObservable()
    }

    private let _adSizeChanged = PublishSubject<Void>()
    var adSizeChanged: Observable<Void> {
        return _adSizeChanged
            .asObservable()
    }

    public init(postId: OWPostId) {
        self.postId = postId
        setupObservers()
    }
}

private extension IndependentAdCellViewModel {
    func setupObservers() {
        let adConfiguration = OWIAUAdConfiguration.server(remote: .tmsServer(index: 0))
        let adSettings: OWIAUAdSettingsProtocol = OWIAUAdSettings(configuration: adConfiguration)

        OpenWeb.manager.monetization.ui.ad(postId: postId,
                                           settings: adSettings,
                                           viewEventCallbacks: nil,
                                           actionsCallbacks: { [weak self] event, _, _ in
            switch event {
            case .adSizeChanged:
                self?._adSizeChanged.onNext()
            default:
                break
            }
        },
                                           completion: { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let adView):
                _adView.onNext(adView)
            case .failure(let error):
                DLog("Independent Ad Cell failed with error: \(error.localizedDescription)")
            }
        })
    }
}
