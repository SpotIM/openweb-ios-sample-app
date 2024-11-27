//
//  IndependentMonetizationExampleViewModel.swift
//  OpenWeb-SampleApp
//
//  Created by Anael on 26/11/2024.
//

import Foundation
import OpenWebIAUSDK
import RxSwift
import OpenWebSDK

protocol IndependentMonetizationExampleViewModelingInputs {}

protocol IndependentMonetizationExampleViewModelingOutputs {
    var title: String { get }
    var loggerViewModel: UILoggerViewModeling { get }
    var showAdView: Observable<UIView> { get }
}

protocol IndependentMonetizationExampleViewModeling {
    var inputs: IndependentMonetizationExampleViewModelingInputs { get }
    var outputs: IndependentMonetizationExampleViewModelingOutputs { get }
}

class IndependentMonetizationExampleViewModel: IndependentMonetizationExampleViewModeling, IndependentMonetizationExampleViewModelingOutputs, IndependentMonetizationExampleViewModelingInputs {
    var inputs: IndependentMonetizationExampleViewModelingInputs { return self }
    var outputs: IndependentMonetizationExampleViewModelingOutputs { return self }
    
    private let postId: OWPostId
    private var manager = OpenWebIAU.manager
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
        return NSLocalizedString("Independent Example", comment: "")
    }()
    
    lazy var loggerViewModel: UILoggerViewModeling = {
        return UILoggerViewModel(title: "Independent example logger")
    }()
}

private extension IndependentMonetizationExampleViewModel {
    func setupObservers() {
        let adConfiguration = OWIAUAdConfiguration.server(remote: .tmsServer(index: 0))
        let adSettings: OWIAUAdSettingsProtocol = OWIAUAdSettings(configuration: adConfiguration)
        let viewEventCallbacks: OWIAUAdViewEventsCallbacks = { [weak self] eventType, _, _ in
            self?.loggerViewModel.inputs.log(text: eventType.description)
        }
        
        manager.ui.ad(postId: postId,
                      settings: adSettings,
                      viewEventCallbacks: viewEventCallbacks,
                      actionsCallbacks: nil,
                      completion: { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let adView):
                _showAdView.onNext(adView)
            case .failure(let error):
                DLog("Independent monetization example failed: \(error.localizedDescription)")
            }
        })
    }
}
