//
//  OWRealtimeIndicationViewModel.swift
//  SpotImCore
//
//  Created by Revital Pisman on 02/08/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

protocol OWRealtimeIndicationViewModelingInputs {
    var tap: PublishSubject<Void> { get }
    var panHorisontalPositionDidChange: PublishSubject<CGFloat> { get }
    var panHorisontalPositionChangeDidEnd: PublishSubject<Void> { get }
}

protocol OWRealtimeIndicationViewModelingOutputs {
    var realtimeTypingViewModel: OWRealtimeTypingViewModeling { get }
    var realtimeNewCommentsViewModel: OWRealtimeNewCommentsViewModeling { get }
    var tapped: Observable<Void> { get }
    var shouldShowTypingLabel: Observable<Bool> { get }
    var shouldShowNewCommentsLabel: Observable<Bool> { get }
    var horisontalPositionDidChange: Observable<CGFloat> { get }
    var horisontalPositionChangeDidEnd: Observable<Void> { get }
}

protocol OWRealtimeIndicationViewModeling {
    var inputs: OWRealtimeIndicationViewModelingInputs { get }
    var outputs: OWRealtimeIndicationViewModelingOutputs { get }
}

class OWRealtimeIndicationViewModel: OWRealtimeIndicationViewModeling,
                                     OWRealtimeIndicationViewModelingInputs,
                                     OWRealtimeIndicationViewModelingOutputs {

    var inputs: OWRealtimeIndicationViewModelingInputs { return self }
    var outputs: OWRealtimeIndicationViewModelingOutputs { return self }

    var tap = PublishSubject<Void>()
    let panHorisontalPositionDidChange = PublishSubject<CGFloat>()
    let panHorisontalPositionChangeDidEnd = PublishSubject<Void>()

    var tapped: Observable<Void> {
        tap.asObservable()
    }

    var horisontalPositionDidChange: Observable<CGFloat> {
        panHorisontalPositionDidChange.asObservable()
    }

    var horisontalPositionChangeDidEnd: Observable<Void> {
        panHorisontalPositionChangeDidEnd.asObservable()
    }

    fileprivate let _shouldShowTypingLabel = BehaviorSubject<Bool>(value: false)
    var shouldShowTypingLabel: Observable<Bool> {
        return _shouldShowTypingLabel
            .distinctUntilChanged()
            .asObservable()
    }

    fileprivate let _shouldShowNewCommentsLabel = BehaviorSubject<Bool>(value: false)
    var shouldShowNewCommentsLabel: Observable<Bool> {
        return _shouldShowNewCommentsLabel
            .distinctUntilChanged()
            .asObservable()
    }

    lazy var realtimeTypingViewModel: OWRealtimeTypingViewModeling = {
        return OWRealtimeTypingViewModel()
    }()

    lazy var realtimeNewCommentsViewModel: OWRealtimeNewCommentsViewModeling = {
        return OWRealtimeNewCommentsViewModel()
    }()

    fileprivate var realtimeUpdateService: OWRealtimeUpdateServicing
    fileprivate let disposeBag = DisposeBag()

    init(realtimeUpdateService: OWRealtimeUpdateServicing = OWSharedServicesProvider.shared.realtimeUpdateService()) {
        self.realtimeUpdateService = realtimeUpdateService
        self.setupObservers()
    }
}

extension OWRealtimeIndicationViewModel {
    func setupObservers() {

        realtimeUpdateService.realtimeUpdateType
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] type in
                guard let self = self else { return }
                switch type {
                case .all(_, _):
                    self._shouldShowTypingLabel.onNext(true)
                    self._shouldShowNewCommentsLabel.onNext(true)

                case .newComments(_):
                    self._shouldShowTypingLabel.onNext(false)
                    self._shouldShowNewCommentsLabel.onNext(true)

                case .typing(_):
                    self._shouldShowTypingLabel.onNext(true)
                    self._shouldShowNewCommentsLabel.onNext(false)

                case .none:
                    self._shouldShowTypingLabel.onNext(false)
                    self._shouldShowNewCommentsLabel.onNext(false)
                }
            })
            .disposed(by: disposeBag)
    }
}
