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
    var textViewTap: PublishSubject<(String, String)> { get }
    var placeholderTextChange: BehaviorSubject<String> { get }
    var textViewTextChange: BehaviorSubject<String> { get }
    var textViewCharectersCount: BehaviorSubject<Int> { get }
}

protocol OWTextViewViewModelingOutputs {
    var becomeFirstResponderCalled: Observable<Void> { get }
    var textViewTapped: Observable<(String, String)> { get }
    var textViewMaxCharecters: Int { get }
    var isEditable: Bool { get }
    var placeholderText: Observable<String> { get }
    var textViewTextCount: Observable<Int> { get }
    var hidePlaceholder: Observable<Bool> { get }
    var textViewText: Observable<String> { get }
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
    let textViewMaxCharecters: Int

    var becomeFirstResponderCall = PublishSubject<Void>()
    var becomeFirstResponderCalled: Observable<Void> {
        return becomeFirstResponderCall.asObservable()
    }

    var textViewTap = PublishSubject<(String, String)>()
    var textViewTapped: Observable<(String, String)> {
        return textViewTap.asObservable()
    }

    var textViewCharectersCount = BehaviorSubject<Int>(value: 0)
    var textViewTextCount: Observable<Int> {
        return textViewCharectersCount.asObservable()
    }

    var placeholderTextChange: BehaviorSubject<String>
    var placeholderText: Observable<String> {
        return placeholderTextChange
                .asObserver()
    }

    var textViewTextChange: BehaviorSubject<String>
    var textViewText: Observable<String> {
        return textViewTextChange
                .asObserver()
    }

    var hidePlaceholder: Observable<Bool> {
        return textViewCharectersCount
            .map { $0 > 0 }
    }

    init(textViewMaxCharecters: Int, placeholderText: String, textViewText: String = "", isEditable: Bool) {
        self.textViewMaxCharecters = textViewMaxCharecters
        self.placeholderTextChange = BehaviorSubject(value: placeholderText)
        self.textViewTextChange = BehaviorSubject(value: textViewText)
        self.isEditable = isEditable
    }
}
