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
    var becomeFirstResponderCall: PublishSubject<Void> { get }
    var textViewTap: PublishSubject<Void> { get }
    var placeholderTextChange: BehaviorSubject<String> { get }
    var textViewTextChange: BehaviorSubject<String> { get }
    var textViewCharectersCount: BehaviorSubject<Int> { get }
    var textViewMaxCharectersChange: PublishSubject<Int> { get }
    var charectarsLimitEnabledChange: PublishSubject<Bool> { get }
}

protocol OWTextViewViewModelingOutputs {
    var becomeFirstResponderCalled: Observable<Void> { get }
    var textViewTapped: Observable<Void> { get }
    var textViewMaxCharecters: Int { get }
    var isEditable: Bool { get }
    var placeholderText: Observable<String> { get }
    var textViewTextCount: Observable<Int> { get }
    var hidePlaceholder: Observable<Bool> { get }
    var textViewText: Observable<String> { get }
    var charectersLimitEnabled: Bool { get }
}

protocol OWTextViewViewModeling {
    var inputs: OWTextViewViewModelingInputs { get }
    var outputs: OWTextViewViewModelingOutputs { get }
}

class OWTextViewViewModel: OWTextViewViewModelingInputs, OWTextViewViewModelingOutputs, OWTextViewViewModeling {
    fileprivate struct Metrics {
        static let becomeFirstResponderDelay = 550
    }
    var inputs: OWTextViewViewModelingInputs { return self }
    var outputs: OWTextViewViewModelingOutputs { return self }
    fileprivate let disposeBag = DisposeBag()

    let isEditable: Bool
    var textViewMaxCharecters: Int
    var textViewMaxCharectersChange = PublishSubject<Int>()

    var charectersLimitEnabled = true
    var charectarsLimitEnabledChange = PublishSubject<Bool>()

    var becomeFirstResponderCall = PublishSubject<Void>()
    var becomeFirstResponderCalled: Observable<Void> {
        return becomeFirstResponderCall
            .delay(.milliseconds(Metrics.becomeFirstResponderDelay), scheduler: MainScheduler.instance)
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

    init(textViewMaxCharecters: Int,
         placeholderText: String,
         textViewText: String = "",
         charectersLimitEnabled: Bool,
         isEditable: Bool) {
        self.textViewMaxCharecters = textViewMaxCharecters
        self.placeholderTextChange = BehaviorSubject(value: placeholderText)
        self.textViewTextChange = BehaviorSubject(value: textViewText)
        self.isEditable = isEditable
        self.charectersLimitEnabled = charectersLimitEnabled
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
