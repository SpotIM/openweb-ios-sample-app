//
//  OWRealtimeIndicationAnimationViewModel.swift
//  OpenWebSDK
//
//  Created by Revital Pisman on 22/08/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import Foundation
import RxSwift

protocol OWRealtimeIndicationAnimationViewModelingInputs {
    func swiped()
    var forceDisable: BehaviorSubject<Bool> { get }
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

    var forceDisable = BehaviorSubject<Bool>(value: false)
    lazy var forceDisabled: Observable<Bool> = {
        return forceDisable
            .asObservable()
    }()

    lazy var realtimeIndicationViewModel: OWRealtimeIndicationViewModeling = {
        return OWRealtimeIndicationViewModel()
    }()

    private let _isRealtimeIndicatorEnabled = BehaviorSubject<Bool>(value: false)
    private let _isThereAnyDataToShow = BehaviorSubject<Bool>(value: false)
    lazy var shouldShow: Observable<Bool> = {
        return Observable.combineLatest(forceDisabled,
                                        _isThereAnyDataToShow,
                                        _isRealtimeIndicatorEnabled) { forceDisabled, isThereAnyDataToShow, isRealtimeIndicatorEnabled -> Bool in
            guard !forceDisabled,
                  isRealtimeIndicatorEnabled else { return false }
            return isThereAnyDataToShow
        }
        .distinctUntilChanged()
        .asObservable()
        .share(replay: 1)
    }()

    func swiped() {
        _isThereAnyDataToShow.onNext(false)
        _isRealtimeIndicatorEnabled.onNext(false)
    }

    private var realtimeIndicatorService: OWRealtimeIndicatorServicing
    private let disposeBag = DisposeBag()

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
                guard let self else { return }
                let isShown = type != .none
                self._isThereAnyDataToShow.onNext(isShown)
            })
            .disposed(by: disposeBag)

        realtimeIndicatorService.state
            .subscribe(onNext: { [weak self] state in
                guard let self else { return }
                self._isRealtimeIndicatorEnabled.onNext(state == .enable)
                if state == .disable {
                    self.realtimeIndicatorService.cleanCache()
                }
            })
            .disposed(by: disposeBag)

    }
}
