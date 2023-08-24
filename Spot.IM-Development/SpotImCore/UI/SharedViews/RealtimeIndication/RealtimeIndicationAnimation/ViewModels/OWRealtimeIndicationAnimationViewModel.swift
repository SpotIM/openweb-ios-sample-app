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
    func swiped()
}

protocol OWRealtimeIndicationAnimationViewModelingOutputs {
    var realtimeIndicationViewModel: OWRealtimeIndicationViewModeling { get }
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
    fileprivate let _isShown = BehaviorSubject<Bool>(value: false)
    lazy var isShown: Observable<Bool> = {
        return Observable.combineLatest(_isShown,
                                        _shouldShow) { isShown, shouldShow -> Bool in
            guard shouldShow else { return false }
            return isShown
        }
        .distinctUntilChanged()
        .asObservable()
        .share(replay: 1)
    }()

    func swiped() {
        _isShown.onNext(false)
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
                let isShown = type != .none
                self._isShown.onNext(isShown)
            })
            .disposed(by: disposeBag)

        realtimeUpdateService.state
            .subscribe(onNext: { [weak self] state in
                guard let self = self else { return }
                self._shouldShow.onNext(state == .enable)
                if state == .disable {
                    self.realtimeUpdateService.cleanCache()
                }
            })
            .disposed(by: disposeBag)

    }
}
