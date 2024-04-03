//
//  OWTextViewVM.swift
//  SpotImCore
//
//  Created by Refael Sommer on 30/04/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

protocol OWTextViewViewModelingInputs {
    // becomeFirstResponderCallWithDelay has int milliseconds for delaying the keyboard
    var becomeFirstResponderCallWithDelay: PublishSubject<Int> { get }
    var resignFirstResponderCall: PublishSubject<Void> { get }
    var textViewTap: PublishSubject<Void> { get }
    var placeholderTextChange: BehaviorSubject<String> { get }
    var textExternalChange: PublishSubject<String> { get }
    var textInternalChange: PublishSubject<String> { get }
    var textViewCharectersCount: BehaviorSubject<Int> { get }
    var textViewMaxCharectersChange: PublishSubject<Int> { get }
    var charectarsLimitEnabledChange: PublishSubject<Bool> { get }
    var hasSuggestionsBarChange: BehaviorSubject<Bool> { get }
    var cursorRangeExternalChange: PublishSubject<Range<String.Index>?> { get }
    var cursorRangeInternalChange: PublishSubject<Range<String.Index>?> { get }
    var replacedData: BehaviorSubject<OWTextViewReplaceData?> { get }
    var internalReplacedData: BehaviorSubject<OWTextViewReplaceData?> { get }
    var attributedTextChange: BehaviorSubject<NSAttributedString?> { get }
    var maxLinesChange: PublishSubject<Int> { get }
}

protocol OWTextViewViewModelingOutputs {
    var becomeFirstResponderCalledWithDelay: Observable<Void> { get }
    var resignFirstResponderCalled: Observable<Void> { get }
    var textViewTapped: Observable<Void> { get }
    var textViewMaxCharecters: Int { get }
    var isEditable: Bool { get }
    var placeholderText: Observable<String> { get }
    var textViewTextCount: Observable<String> { get }
    var hidePlaceholder: Observable<Bool> { get }
    var textViewText: Observable<String> { get }
    var charectersLimitEnabled: Bool { get }
    var showCharectersLimit: Bool { get }
    var isAutoExpandable: Bool { get }
    var cursorRange: Observable<Range<String.Index>> { get }
    var replaceData: Observable<OWTextViewReplaceData> { get }
    var internalReplaceData: Observable<OWTextViewReplaceData> { get }
    var attributedTextChanged: Observable<NSAttributedString> { get }
    var cursorRangeExternalChanged: Observable<Range<String.Index>> { get }
    var hasSuggestionsBarChanged: Observable<Bool> { get }
    var scrollEnabled: Bool { get }
    var hasBorder: Bool { get }
    var maxLines: Int { get }
    var maxLinesChanged: Observable<Void> { get }
}

protocol OWTextViewViewModeling {
    var inputs: OWTextViewViewModelingInputs { get }
    var outputs: OWTextViewViewModelingOutputs { get }
}

class OWTextViewViewModel: OWTextViewViewModelingInputs, OWTextViewViewModelingOutputs, OWTextViewViewModeling {
    var inputs: OWTextViewViewModelingInputs { return self }
    var outputs: OWTextViewViewModelingOutputs { return self }

    struct ExternalMetrics {
        static let maxNumberOfLines = 5
    }

    fileprivate let disposeBag = DisposeBag()

    let hasBorder: Bool
    let isEditable: Bool
    let isAutoExpandable: Bool
    let scrollEnabled: Bool
    var textViewMaxCharecters: Int
    var textViewMaxCharectersChange = PublishSubject<Int>()

    var hasSuggestionsBarChange = BehaviorSubject<Bool>(value: false)
    var hasSuggestionsBarChanged: Observable<Bool> {
        return hasSuggestionsBarChange
            .asObservable()
    }

    var maxLinesChange = PublishSubject<Int>()
    var maxLinesChanged: Observable<Void> {
        return maxLinesChange
            .voidify()
            .asObservable()
    }
    var maxLines: Int = ExternalMetrics.maxNumberOfLines

    var charectersLimitEnabled: Bool
    let showCharectersLimit: Bool
    var charectarsLimitEnabledChange = PublishSubject<Bool>()

    // becomeFirstResponderCall has int milliseconds for delaying the keyboard
    var becomeFirstResponderCallWithDelay = PublishSubject<Int>()
    var becomeFirstResponderCalledWithDelay: Observable<Void> {
        return becomeFirstResponderCallWithDelay
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

    var internalReplacedData = BehaviorSubject<OWTextViewReplaceData?>(value: nil)
    var internalReplaceData: Observable<OWTextViewReplaceData> {
        return internalReplacedData
            .asObservable()
            .unwrap()
    }

    var replacedData = BehaviorSubject<OWTextViewReplaceData?>(value: nil)
    var replaceData: Observable<OWTextViewReplaceData> {
        return replacedData
            .asObservable()
            .unwrap()
    }

    var textViewTap = PublishSubject<Void>()
    var textViewTapped: Observable<Void> {
        return textViewTap
            .asObservable()
    }

    var textViewCharectersCount = BehaviorSubject<Int>(value: 0)
    var textViewTextCount: Observable<String> {
        return textViewCharectersCount
            .map { [weak self] count in
                guard let self = self else { return "" }
                return "\(count)/" + "\(self.textViewMaxCharecters)"
            }
    }

    var placeholderTextChange: BehaviorSubject<String>
    var placeholderText: Observable<String> {
        return placeholderTextChange
                .asObservable()
    }

    var cursorRangeExternalChange = PublishSubject<Range<String.Index>?>()
    var cursorRangeExternalChanged: Observable<Range<String.Index>> {
        return cursorRangeExternalChange
            // Prevent first cursor change that comes from the textView itself
            .skip(1)
            .unwrap()
            .asObservable()
    }
    var cursorRangeInternalChange = PublishSubject<Range<String.Index>?>()

    var _cursorRange = BehaviorSubject<Range<String.Index>?>(value: Range(NSRange(location: 0, length: 0), in: ""))
    var cursorRange: Observable<Range<String.Index>> {
        return _cursorRange
            .unwrap()
            .asObservable()
    }

    var textExternalChange = PublishSubject<String>()
    var textInternalChange = PublishSubject<String>()

    var _textViewText: BehaviorSubject<String>
    var textViewText: Observable<String> {
        return _textViewText
            .asObservable()
    }

    var hidePlaceholder: Observable<Bool> {
        return textViewCharectersCount
            .map { $0 > 0 }
    }

    lazy var attributedTextChange = BehaviorSubject<NSAttributedString?>(value: nil)
    lazy var attributedTextChanged: Observable<NSAttributedString> = {
        return attributedTextChange
            .unwrap()
            .asObservable()
    }()

    init(textViewData: OWTextViewData) {
        self.textViewMaxCharecters = textViewData.textViewMaxCharecters
        self.placeholderTextChange = BehaviorSubject(value: textViewData.placeholderText)
        self._textViewText = BehaviorSubject(value: textViewData.textViewText)
        self.isEditable = textViewData.isEditable
        self.charectersLimitEnabled = textViewData.charectersLimitEnabled
        self.showCharectersLimit = textViewData.showCharectersLimit
        self.isAutoExpandable = textViewData.isAutoExpandable
        self.hasSuggestionsBarChange.onNext(textViewData.hasSuggestionsBar)
        self.scrollEnabled = textViewData.isScrollEnabled
        self.hasBorder = textViewData.hasBorder
        self.setupObservers()
    }
}

fileprivate extension OWTextViewViewModel {
    func setupObservers() {
        maxLinesChange
            .subscribe(onNext: { [weak self] maxLines in
                self?.maxLines = maxLines
            })
            .disposed(by: disposeBag)

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

        textViewText
            .map { $0.count }
            .bind(to: textViewCharectersCount)
            .disposed(by: disposeBag)

        let textInternalChangeObservable = textInternalChange
            .flatMap { [weak self] internalText -> Observable<String> in
                guard let self = self else { return .empty() }
                return self.textViewText
                    .take(1)
                    .filter { internalText != $0 }
                    .map { _ -> String in
                        return internalText
                    }
            }

        Observable.merge(textInternalChangeObservable, textExternalChange)
            .map { [weak self] text -> String in
                // Length validation
                guard let self = self else { return text }
                if self.charectersLimitEnabled {
                    return String(text.prefix(self.textViewMaxCharecters))
                }
                return text
            }
            .bind(to: _textViewText)
            .disposed(by: disposeBag)

        let cursorRangeInternalChangeObservable = cursorRangeInternalChange
            .unwrap()
            .flatMap { [weak self] internalRange -> Observable<Range<String.Index>?> in
                guard let self = self else { return .empty() }
                return self.cursorRange
                    .take(1)
                    .filter { internalRange != $0 }
                    .map { _ -> Range<String.Index>? in
                        return internalRange
                    }
            }

        cursorRangeInternalChangeObservable
            .unwrap()
            .bind(to: _cursorRange)
            .disposed(by: disposeBag)
    }
}
