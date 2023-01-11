//
//  OWCommentTextViewModel.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 27/12/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import UIKit

protocol OWCommentTextViewModelingInputs {
    var width: PublishSubject<CGFloat> { get }
    var readMoreTap: PublishSubject<Void> { get }
    var readLessTap: PublishSubject<Void> { get }
}

protocol OWCommentTextViewModelingOutputs {
    var textHeightChange: Observable<Void> { get }
    var attributedString: Observable<NSMutableAttributedString?> { get }
    var readMoreText: String { get }
    var readLessText: String { get }
    var height: Observable<Double> { get }
}

protocol OWCommentTextViewModeling {
    var inputs: OWCommentTextViewModelingInputs { get }
    var outputs: OWCommentTextViewModelingOutputs { get }
}

class OWCommentTextViewModel: OWCommentTextViewModeling,
                                   OWCommentTextViewModelingInputs,
                                   OWCommentTextViewModelingOutputs {
    
    var inputs: OWCommentTextViewModelingInputs { return self }
    var outputs: OWCommentTextViewModelingOutputs { return self }
    
    fileprivate var lineLimit: Int = 0
    fileprivate let suffix: NSAttributedString
    fileprivate var disposeBag = DisposeBag()
    
    var readMoreText: String = LocalizationManager.localizedString(key: "Read More")
    var readLessText: String = LocalizationManager.localizedString(key: "Read Less")
    
    var width = PublishSubject<CGFloat>() // TODO: should get it in constructor ?
    var readMoreTap = PublishSubject<Void>()
    var readLessTap = PublishSubject<Void>()
    
    init(text: String, lineLimit: Int, suffix: NSAttributedString) {
        self.lineLimit = lineLimit
        self.suffix = suffix
        _fullText.onNext(text)
        setupObservers()
    }
    
    fileprivate let _fullText = BehaviorSubject<String?>(value: nil)
    fileprivate var fullAttributedString: Observable<NSMutableAttributedString> {
        _fullText
            .unwrap()
            .map { [weak self] messageText in
                guard let self = self else { return nil }
                return NSMutableAttributedString(
                    string: messageText,
                    attributes: self.messageStringAttributes()
                )
            }
            .unwrap()
    }
    
    fileprivate var _lines: Observable<[CTLine]> {
        fullAttributedString.map { messageAttributedString in
            let width = 358.0 // TODO: get real width
            return messageAttributedString.getLines(with: width)
        }
        .unwrap()
        .asObservable()
    }
    
    fileprivate var _textState = BehaviorSubject<TextState>(value: .collapsed)
    var attributedString: Observable<NSMutableAttributedString?> {
        Observable.combineLatest(_lines, _textState, fullAttributedString)
            .map { lines, currentState, fullAttributedString in
                return self.appendActionStringIfNeeded(fullAttributedString, lines: lines, currentState: currentState)
            }
            .map { [weak self] attString in
                guard let self = self else { return attString }
                attString.append(self.suffix)
                return attString
            }
            .asObservable()
    }
    
    var textHeightChange: Observable<Void> {
        Observable.merge(self.readMoreTap, self.readMoreTap)
    }
    
    var height: Observable<Double> {
        attributedString
            .unwrap()
            .map { string in
                return string.height(withConstrainedWidth: 358) // TODO: real width
            }
            .asObservable()
    }
}

fileprivate extension OWCommentTextViewModel {
    func setupObservers() {
        readMoreTap
            .bind(onNext: { [weak self] in
                self?._textState.onNext(.expanded)
            })
            .disposed(by: disposeBag)
        
        readLessTap
            .bind(onNext: { [weak self] in
                self?._textState.onNext(.collapsed)
            })
            .disposed(by: disposeBag)
    }
}

fileprivate extension OWCommentTextViewModel {
    
    func messageStringAttributes() -> [NSAttributedString.Key: Any] {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.firstLineHeadIndent = 0
        paragraphStyle.lineSpacing = 3.5

        var attributes: [NSAttributedString.Key: Any]
        // TODO: color
        attributes = [
            .font: UIFont.preferred(style: .regular, of: OWCommentContentView.Metrics.fontSize),
            .paragraphStyle: paragraphStyle
        ]

        return attributes
    }
    
    func actionStringAttributes() -> [NSAttributedString.Key: Any] {
        var attributes: [NSAttributedString.Key: Any] = messageStringAttributes()
        attributes[.foregroundColor] = UIColor.clearBlue // TODO: color

        return attributes
    }
    
    func appendActionStringIfNeeded(_ attString: NSMutableAttributedString, lines: [CTLine], currentState: TextState) -> NSMutableAttributedString {
        // In case short message - add nothing here
        guard lines.count > self.lineLimit else { return attString }
        switch currentState {
        case .collapsed:
            let visibleLines = lines[0...lineLimit - 1]
            let ellipsis = NSAttributedString(
                string: " ... ",
                attributes: messageStringAttributes())
            var visibleString = ""
            for line in visibleLines {
                let lineRange = CTLineGetStringRange(line)
                let range = NSRange(location: lineRange.location, length: lineRange.length)
                let lineString = (attString.string as NSString).substring(with: range)
                visibleString.append(lineString)
            }
            let attString2 = NSMutableAttributedString(string: visibleString, attributes: messageStringAttributes())
            let readMore = NSMutableAttributedString(
                string: self.readMoreText,
                attributes: actionStringAttributes())
            attString2.append(ellipsis)
            attString2.append(readMore)
            return attString2
        case .expanded:
            let readLess = NSMutableAttributedString(
                string: self.readLessText,
                attributes: actionStringAttributes())
            let aa = NSMutableAttributedString(attributedString: attString)
            aa.append(readLess)
            return aa
        }
    }
}
    
fileprivate enum TextState {
    case collapsed
    case expanded
}
