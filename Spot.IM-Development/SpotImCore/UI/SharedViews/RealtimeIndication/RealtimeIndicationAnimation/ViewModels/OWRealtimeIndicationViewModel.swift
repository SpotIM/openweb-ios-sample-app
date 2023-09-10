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

    fileprivate let _tapped = PublishSubject<Void>()
    var tapped: Observable<Void> {
        _tapped
            .asObservable()
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

    fileprivate var realtimeIndicatorService: OWRealtimeIndicatorServicing
    fileprivate let disposeBag = DisposeBag()

    init(realtimeIndicatorService: OWRealtimeIndicatorServicing = OWSharedServicesProvider.shared.realtimeIndicatorService()) {
        self.realtimeIndicatorService = realtimeIndicatorService
        self.setupObservers()
    }
}

extension OWRealtimeIndicationViewModel {
    func setupObservers() {
        realtimeIndicatorService.realtimeIndicatorType
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] type in
                guard let self = self else { return }
                let (shouldShowTyping, shouldShowNewComments) = self.displaySettings(for: type)

                self._shouldShowTypingLabel.onNext(shouldShowTyping)
                self._shouldShowNewCommentsLabel.onNext(shouldShowNewComments)
            })
            .disposed(by: disposeBag)

        tap
            .withLatestFrom(realtimeIndicatorService.newComments) { _, newComments in
                return newComments.count
            }
            .subscribe(onNext: { [weak self] newCommentsCount in
                guard newCommentsCount > 0,
                      let self = self else { return }
                self._tapped.onNext()
            })
            .disposed(by: disposeBag)
    }

    private func displaySettings(for type: OWRealtimeIndicatorType) -> (Bool, Bool) {
        switch type {
        case .all:
            return (true, true)
        case .newComments:
            return (false, true)
        case .typing:
            return (true, false)
        case .none:
            return (false, false)
        }
    }
}
