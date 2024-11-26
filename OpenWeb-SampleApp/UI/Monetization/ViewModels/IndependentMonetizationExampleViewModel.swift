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
    var showAdView: Observable<UIView> { get }
}

protocol IndependentMonetizationExampleViewModeling {
    var inputs: IndependentMonetizationExampleViewModelingInputs { get }
    var outputs: IndependentMonetizationExampleViewModelingOutputs { get }
}

class IndependentMonetizationExampleViewModel: IndependentMonetizationExampleViewModeling, IndependentMonetizationExampleViewModelingOutputs, IndependentMonetizationExampleViewModelingInputs {
    var inputs: IndependentMonetizationExampleViewModelingInputs { return self }
    var outputs: IndependentMonetizationExampleViewModelingOutputs { return self }
    
    private var manager = OpenWebIAU.manager
    private let _showAdView = BehaviorSubject<UIView?>(value: nil)
    var showAdView: Observable<UIView> {
        return _showAdView
            .unwrap()
            .asObservable()
    }
   
    lazy var title: String = {
        return NSLocalizedString("Independent Example", comment: "")
    }()
    
    private let postId: OWPostId

    init(postId: OWPostId) {
        self.postId = postId
        setupObservers()
    }
}

private extension IndependentMonetizationExampleViewModel {
    func setupObservers() {
        let adConfiguration = OWIAUAdConfiguration.server(remote: .tmsServer(index: 0))
        let adSettings: OWIAUAdSettingsProtocol = OWIAUAdSettings(configuration: adConfiguration)
    
        manager.ui.ad(postId: postId,
                      settings: adSettings,
                      viewEventCallbacks: nil,
                      actionsCallbacks: nil,
                      completion: { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let adView):
                _showAdView.onNext(adView)
            case .failure(let error):
                print(error.localizedDescription)
            }
        })
    }
}
