//
//  SingleAdExampleViewModel.swift
//  OpenWeb-SampleApp
//
//  Created by Anael on 26/11/2024.
//

import Foundation
import RxSwift
import OpenWebCommon

#if ADS
import OpenWebIAUSDK
#endif

protocol SingleAdExampleViewModelingInputs {}

protocol SingleAdExampleViewModelingOutputs {
    var title: String { get }
    var loggerViewModel: UILoggerViewModeling { get }
    var adView: Observable<UIView> { get }
}

protocol SingleAdExampleViewModeling {
    var inputs: SingleAdExampleViewModelingInputs { get }
    var outputs: SingleAdExampleViewModelingOutputs { get }
}

class SingleAdExampleViewModel: SingleAdExampleViewModeling, SingleAdExampleViewModelingOutputs, SingleAdExampleViewModelingInputs {
    var inputs: SingleAdExampleViewModelingInputs { return self }
    var outputs: SingleAdExampleViewModelingOutputs { return self }

    private let postId: OWPostId
    private let _adView = BehaviorSubject<UIView?>(value: nil)
    var adView: Observable<UIView> {
        return _adView
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

private extension SingleAdExampleViewModel {
    func setupObservers() {
        #if ADS
        let adConfiguration = OWIAUAdConfiguration.server(remote: .tmsServer(index: 0, component: .independentAd))
        let adSettings: OWIAUAdSettingsProtocol = OWIAUAdSettings(configuration: adConfiguration)
        let viewEventCallbacks: OWIAUAdViewEventsCallbacks = { [weak self] eventType, _, _ in
            self?.loggerViewModel.inputs.log(text: eventType.description)
        }
        OpenWebIAU.manager.ui.ad(postId: postId,
                                           settings: adSettings,
                                           viewEventCallbacks: viewEventCallbacks,
                                           actionsCallbacks: nil,
                                           completion: { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let adView):
                _adView.onNext(adView)
            case .failure(let error):
                DLog("Social monetization example failed: \(error.localizedDescription)")
            }
        })
        #endif
    }
}
