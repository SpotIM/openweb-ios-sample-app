//
//  IndependentMonetizationExampleViewModel.swift
//  OpenWeb-SampleApp
//
//  Created by Anael on 26/11/2024.
//

import Foundation
import OpenWebIAUSDK
import RxSwift

protocol IndependentMonetizationExampleViewModelingInputs {
   
}

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
    
    init() {
        setupObservers()
    }
}

private extension IndependentMonetizationExampleViewModel {
    func setupObservers() {
        // TODO: Remove this code to app delegate when the iau handle switching spot
        // Init IAU sdk
        let exampleStoreURL = "https://apps.apple.com/us/app/spotim-demo/id1234567"
        var manager = OpenWebIAU.manager
        manager.spotId = "sp_PPSI75uf"
        var settingsBuilder = OWIAUSettingsBuilder()
        settingsBuilder.storeURL(exampleStoreURL)
        manager.settings = settingsBuilder.build()
        
        let adConfiguration = OWIAUAdConfiguration.server(remote: .tmsServer(index: 0))
        let adSettings: OWIAUAdSettingsProtocol = OWIAUAdSettings(configuration: adConfiguration)
    
        manager.ui.ad(postId: "", //TODO: Send postid
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
