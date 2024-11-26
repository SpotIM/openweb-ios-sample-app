//
//  SocialMonetizationExampleViewModel.swift
//  OpenWeb-SampleApp
//
//  Created by Anael on 26/11/2024.
//

import Foundation
import RxSwift

protocol SocialMonetizationExampleViewModelingInputs {}

protocol SocialMonetizationExampleViewModelingOutputs {
    var title: String { get }
    var showAdView: Observable<UIView> { get }
}

protocol SocialMonetizationExampleViewModeling {
    var inputs: SocialMonetizationExampleViewModelingInputs { get }
    var outputs: SocialMonetizationExampleViewModelingOutputs { get }
}

class SocialMonetizationExampleViewModel: SocialMonetizationExampleViewModeling, SocialMonetizationExampleViewModelingOutputs, SocialMonetizationExampleViewModelingInputs {
    var inputs: SocialMonetizationExampleViewModelingInputs { return self }
    var outputs: SocialMonetizationExampleViewModelingOutputs { return self }
    
    private let _showAdView = BehaviorSubject<UIView?>(value: nil)
    var showAdView: Observable<UIView> {
        return _showAdView
            .unwrap()
            .asObservable()
    }
   
    lazy var title: String = {
        return NSLocalizedString("Social Example", comment: "")
    }()
    
    init() {
        setupObservers()
    }
}

private extension SocialMonetizationExampleViewModel {
    func setupObservers() {}
}
