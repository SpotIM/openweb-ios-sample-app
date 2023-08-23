//
//  OWRealtimeIndicationAnimationViewModel.swift
//  SpotImCore
//
//  Created by Revital Pisman on 22/08/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

protocol OWRealtimeIndicationAnimationViewModelingInputs {
    func update(shouldShow: Bool)
    func update(isShown: Bool)
}

protocol OWRealtimeIndicationAnimationViewModelingOutputs {
    var realtimeIndicationViewModel: OWRealtimeIndicationViewModeling { get }
    var shouldShow: Observable<Bool> { get }
    var isShown: Observable<Bool> { get }
}

protocol OWRealtimeIndicationAnimationViewModeling {
    var inputs: OWRealtimeIndicationAnimationViewModelingInputs { get }
    var outputs: OWRealtimeIndicationAnimationViewModelingOutputs { get }
}

class OWRealtimeIndicationAnimationViewModel: OWRealtimeIndicationAnimationViewModeling,
                                     OWRealtimeIndicationAnimationViewModelingInputs,
                                     OWRealtimeIndicationAnimationViewModelingOutputs {

    var inputs: OWRealtimeIndicationAnimationViewModelingInputs { return self }
    var outputs: OWRealtimeIndicationAnimationViewModelingOutputs { return self }

    lazy var realtimeIndicationViewModel: OWRealtimeIndicationViewModeling = {
        return OWRealtimeIndicationViewModel()
    }()

    fileprivate let _shouldShow = BehaviorSubject<Bool>(value: false)
    var shouldShow: Observable<Bool> {
        return _shouldShow
            .distinctUntilChanged()
            .asObservable()
    }

    fileprivate let _isShown = BehaviorSubject<Bool>(value: false)
    var isShown: Observable<Bool> {
        return _isShown
            .debug("RIVI1")
            .distinctUntilChanged()
            .asObservable()
    }

    func update(shouldShow: Bool) {
        _shouldShow.onNext(shouldShow)
    }

    func update(isShown: Bool) {
        _isShown.onNext(isShown)
    }

    fileprivate var realtimeUpdateService: OWRealtimeUpdateServicing
    fileprivate let disposeBag = DisposeBag()

    init(realtimeUpdateService: OWRealtimeUpdateServicing = OWSharedServicesProvider.shared.realtimeUpdateService()) {
        self.realtimeUpdateService = realtimeUpdateService
        self.setupObservers()
    }
}

extension OWRealtimeIndicationAnimationViewModel {
    func setupObservers() {
        realtimeUpdateService.realtimeUpdateType
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] type in
                guard let self = self else { return }
                switch type {
                case .none:
                    self.update(shouldShow: false)
                default:
                    break
                }
            })
            .disposed(by: disposeBag)
    }
}
