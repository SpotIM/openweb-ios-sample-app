//
//  OWTextViewVM.swift
//  SpotImCore
//
//  Created by Refael Sommer on 30/04/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

protocol OWTextViewViewModelingInputs {
    // becomeFirstResponderCall has bool for delaying the keyboard
    var becomeFirstResponderCall: PublishSubject<Int> { get }
    var resignFirstResponderCall: PublishSubject<Void> { get }
    var textViewTap: PublishSubject<Void> { get }
    var placeholderTextChange: BehaviorSubject<String> { get }
    var textViewTextChange: BehaviorSubject<String> { get }
    var textViewCharectersCount: BehaviorSubject<Int> { get }
    var textViewMaxCharectersChange: PublishSubject<Int> { get }
    var charectarsLimitEnabledChange: PublishSubject<Bool> { get }
}

protocol OWTextViewViewModelingOutputs {
    var becomeFirstResponderCalled: Observable<Void> { get }
    var resignFirstResponderCalled: Observable<Void> { get }
    var textViewTapped: Observable<Void> { get }
    var textViewMaxCharecters: Int { get }
    var isEditable: Bool { get }
    var placeholderText: Observable<String> { get }
    var textViewTextCount: Observable<Int> { get }
    var hidePlaceholder: Observable<Bool> { get }
    var textViewText: Observable<String> { get }
    var charectersLimitEnabled: Bool { get }
    var isAutoExpandable: Bool { get }
    var hasSuggestionsBar: Bool { get }
}

protocol OWTextViewViewModeling {
    var inputs: OWTextViewViewModelingInputs { get }
    var outputs: OWTextViewViewModelingOutputs { get }
}

class OWTextViewViewModel: OWTextViewViewModelingInputs, OWTextViewViewModelingOutputs, OWTextViewViewModeling {
    var inputs: OWTextViewViewModelingInputs { return self }
    var outputs: OWTextViewViewModelingOutputs { return self }
    fileprivate let disposeBag = DisposeBag()

    let isEditable: Bool
    let isAutoExpandable: Bool
    let hasSuggestionsBar: Bool
    var textViewMaxCharecters: Int
    var textViewMaxCharectersChange = PublishSubject<Int>()

    var charectersLimitEnabled = true
    var charectarsLimitEnabledChange = PublishSubject<Bool>()

    // becomeFirstResponderCall has bool for delaying the keyboard
    var becomeFirstResponderCall = PublishSubject<Int>()
    var becomeFirstResponderCalled: Observable<Void> {
        return becomeFirstResponderCall
            .flatMap { delayDuration -> Observable<Void> in
                return Observable.just(())
                    .delay(.milliseconds(delayDuration),
                           scheduler: MainScheduler.instance)
            }
            .asObservable()
    }

    var resignFirstResponderCall = PublishSubject<Void>()
    var resignFirstResponderCalled: Observable<Void> {
        return resignFirstResponderCall
            .asObservable()
    }

    var textViewTap = PublishSubject<Void>()
    var textViewTapped: Observable<Void> {
        return textViewTap.asObservable()
    }

    var textViewCharectersCount = BehaviorSubject<Int>(value: 0)
    var textViewTextCount: Observable<Int> {
        return textViewCharectersCount
                .asObservable()
    }

    var placeholderTextChange: BehaviorSubject<String>
    var placeholderText: Observable<String> {
        return placeholderTextChange
                .asObservable()
    }

    var textViewTextChange: BehaviorSubject<String>
    var textViewText: Observable<String> {
        return textViewTextChange
                .asObservable()
    }

    var hidePlaceholder: Observable<Bool> {
        return textViewCharectersCount
            .map { $0 > 0 }
    }

    init(textViewData: OWTextViewData) {
        self.textViewMaxCharecters = textViewData.textViewMaxCharecters
        self.placeholderTextChange = BehaviorSubject(value: textViewData.placeholderText)
        self.textViewTextChange = BehaviorSubject(value: textViewData.textViewText)
        self.isEditable = textViewData.isEditable
        self.charectersLimitEnabled = textViewData.charectersLimitEnabled
        self.isAutoExpandable = textViewData.isAutoExpandable
        self.hasSuggestionsBar = textViewData.hasSuggestionsBar
        self.setupObservers()
    }
}

fileprivate extension OWTextViewViewModel {
    func setupObservers() {
        textViewMaxCharectersChange
            .subscribe(onNext: { [weak self] limit in
                guard let self = self else { return }
                self.textViewMaxCharecters = limit
            })
            .disposed(by: disposeBag)

        charectarsLimitEnabledChange
            .subscribe(onNext: { [weak self] show in
                guard let self = self else { return }
                self.charectersLimitEnabled = show && self.isEditable
            })
            .disposed(by: disposeBag)
    }
}
