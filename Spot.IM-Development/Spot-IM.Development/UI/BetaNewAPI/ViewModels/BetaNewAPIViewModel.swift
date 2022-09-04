//
//  BetaNewAPIViewModel.swift
//  Spot-IM.Development
//
//  Created by Alon Haiut on 31/08/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift
import SpotImCore

#if NEW_API

protocol BetaNewAPIViewModelingInputs {
    
}

protocol BetaNewAPIViewModelingOutputs {
    var title: String { get }
    var preFilledSpotId: Observable<String> { get }
    var preFilledPostId: Observable<String> { get }
}

protocol BetaNewAPIViewModeling {
    var inputs: BetaNewAPIViewModelingInputs { get }
    var outputs: BetaNewAPIViewModelingOutputs { get }
}

class BetaNewAPIViewModel: BetaNewAPIViewModeling, BetaNewAPIViewModelingInputs, BetaNewAPIViewModelingOutputs {
    var inputs: BetaNewAPIViewModelingInputs { return self }
    var outputs: BetaNewAPIViewModelingOutputs { return self }
    
    fileprivate struct Metrics {
        static let preFilledSpotId: String? = "sp_eCIlROSD"
        static let preFilledPostId: String? = "sdk1"
    }
    
    fileprivate let disposeBag = DisposeBag()
    
    fileprivate let _preFilledSpotId = BehaviorSubject<String?>(value: Metrics.preFilledSpotId)
    var preFilledSpotId: Observable<String> {
        return _preFilledSpotId
            .unwrap()
            .asObservable()
    }
    
    fileprivate let _preFilledPostId = BehaviorSubject<String?>(value: Metrics.preFilledPostId)
    var preFilledPostId: Observable<String> {
        return _preFilledPostId
            .unwrap()
            .asObservable()
    }
    
    lazy var title: String = {
        return NSLocalizedString("NewAPI", comment: "")
    }()
    
    init() {
        setupObservers()
    }
}

fileprivate extension BetaNewAPIViewModel {
    func setupObservers() {
//        var manager = OpenWeb.manager
//        manager.spotId = "sp_eCIlROSD"
    }
}

#endif
