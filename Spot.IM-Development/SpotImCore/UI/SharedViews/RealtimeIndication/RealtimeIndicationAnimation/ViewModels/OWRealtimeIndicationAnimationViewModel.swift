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
    var shouldShow: Observable<Bool> { get }
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
    lazy var shouldShow: Observable<Bool> = {
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

    fileprivate var realtimeIndicatorService: OWRealtimeIndicatorServicing
    fileprivate let disposeBag = DisposeBag()

    init(realtimeIndicatorService: OWRealtimeIndicatorServicing = OWSharedServicesProvider.shared.realtimeIndicatorService()) {
        self.realtimeIndicatorService = realtimeIndicatorService
        self.setupObservers()
    }
}

extension OWRealtimeIndicationAnimationViewModel {
    func setupObservers() {
        realtimeIndicatorService.realtimeIndicatorType
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] type in
                guard let self = self else { return }
                let isShown = type != .none
                self._isShown.onNext(isShown)
            })
            .disposed(by: disposeBag)

        realtimeIndicatorService.state
            .subscribe(onNext: { [weak self] state in
                guard let self = self else { return }
                self._shouldShow.onNext(state == .enable)
                if state == .disable {
                    self.realtimeIndicatorService.cleanCache()
                }
            })
            .disposed(by: disposeBag)

    }
}
