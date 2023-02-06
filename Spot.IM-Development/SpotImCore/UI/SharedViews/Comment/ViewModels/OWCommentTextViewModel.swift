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
    var width: BehaviorSubject<CGFloat> { get }
    var readMoreTap: PublishSubject<Void> { get }
    var readLessTap: PublishSubject<Void> { get }
    var urlTap: PublishSubject<URL> { get }
}

protocol OWCommentTextViewModelingOutputs {
    var textHeightChange: Observable<Void> { get }
    var attributedString: Observable<NSMutableAttributedString?> { get }
    var readMoreText: String { get }
    var readLessText: String { get }
    var activeURLs: [NSRange: URL] { get }
    var urlClickedOutput: Observable<URL> { get }
    var height: Observable<CGFloat> { get }
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
    fileprivate var disposeBag = DisposeBag()
    
    var readMoreText: String = LocalizationManager.localizedString(key: "Read More")
    var readLessText: String = LocalizationManager.localizedString(key: "Read Less")
    var editedText: String = LocalizationManager.localizedString(key: "Edited")
    
    var readMoreTap = PublishSubject<Void>()
    var readLessTap = PublishSubject<Void>()
    var activeURLs: [NSRange: URL]
    
    init(comment: SPComment, lineLimit: Int) {
        self.lineLimit = lineLimit
        self.activeURLs = [:]
        _comment.onNext(comment)
        setupObservers()
    }
    
    fileprivate var _themeStyleObservable:  Observable<OWThemeStyle> = OWSharedServicesProvider.shared.themeStyleService().style
    
    fileprivate let _comment = BehaviorSubject<SPComment?>(value: nil)
    fileprivate var _commentUnwraped: Observable<SPComment> {
        _comment.unwrap()
    }
    
    fileprivate var fullAttributedString: Observable<NSMutableAttributedString> {
        _themeStyleObservable
            .withLatestFrom(_commentUnwraped) { style, comment -> (OWThemeStyle, String)? in
                guard let text = comment.text?.text else { return nil }
                return (style, text)
            }
            .unwrap()
            .map { [weak self] (style, messageText) in
                guard let self = self else { return nil }
                return NSMutableAttributedString(
                    string: messageText,
                    attributes: self.messageStringAttributes(with: style)
                )
            }
            .unwrap()
    }
    
    
    var width = BehaviorSubject<CGFloat>(value: 0)
    fileprivate var widthObservable: Observable<CGFloat> {
        width
            .distinctUntilChanged()
            .asObservable()
    }
    
//    fileprivate var _lines: Observable<[CTLine]> {
//        widthObservable
//            .withLatestFrom(fullAttributedString) { currentWidth, messageAttributedString in
//            print("NOGAH: width \(currentWidth)")
//            return messageAttributedString.getLines(with: currentWidth)
//        }
//        .asObservable()
//    }
    
    fileprivate var _lines: Observable<[CTLine]> {
        Observable.combineLatest(fullAttributedString, widthObservable) { messageAttributedString, currentWidth in
            return messageAttributedString.getLines(with: currentWidth)
        }
        .unwrap()
        .asObservable()
    }
//    fileprivate var _lines: Observable<[CTLine]> {
//        fullAttributedString.map { messageAttributedString in
//            let width = 361.0 // TODO: get real width
//            return messageAttributedString.getLines(with: width)
//        }
//        .asObservable()
//    }
    
    fileprivate var _textState = BehaviorSubject<TextState>(value: .collapsed)
    var attributedString: Observable<NSMutableAttributedString?> {
        Observable.combineLatest(_lines, _textState, fullAttributedString, _themeStyleObservable)
            .map { [weak self] lines, currentState, fullAttributedString, style -> (NSMutableAttributedString, OWThemeStyle)? in
                guard let self = self else { return nil }
                let attString = self.appendActionStringIfNeeded(fullAttributedString, lines: lines, currentState: currentState, style: style)
                return (attString, style)
            }
            .unwrap()
            .withLatestFrom(_commentUnwraped) { [weak self] res, comment -> (NSMutableAttributedString, OWThemeStyle) in
                let (attString, style) = res
                guard let self = self,
                      comment.edited == true
                else { return (attString, style) }
                
                attString.append(NSAttributedString(string: self.editedText, attributes: self.editedStringAttributes(with: style)))
                return (attString, style)
            }
            .map { [weak self] (attString, style) in
                guard var res = attString.mutableCopy() as? NSMutableAttributedString else { return attString }
                self?.locateURLsInText(text: &res, style: style)
                return res
            }
            .asObservable()
    }
    
    var textHeightChange: Observable<Void> {
        Observable.merge(self.heighChange)
    }
    
    var height: Observable<CGFloat> {
        attributedString
            .withLatestFrom(widthObservable) { attributedString, width in
                let newHeight = attributedString?.height(withConstrainedWidth: width)
                return newHeight
        }
        .unwrap()
        .distinctUntilChanged()
        .asObservable()
    }
    var heighChange = PublishSubject<Void>()
    
    var urlTap = PublishSubject<URL>()
    var urlClickedOutput: Observable<URL> {
        urlTap
            .asObservable()
    }
}

fileprivate extension OWCommentTextViewModel {
    func setupObservers() {
        readMoreTap
            .subscribe(onNext: { [weak self] in
                self?._textState.onNext(.expanded)
            })
            .disposed(by: disposeBag)
        
        readLessTap
            .subscribe(onNext: { [weak self] in
                self?._textState.onNext(.collapsed)
            })
            .disposed(by: disposeBag)
        
        height
            .subscribe(onNext: { newHeight in
                print("NOGAH: update text height change: \(newHeight)")
                self.heighChange.onNext()
            })
            .disposed(by: disposeBag)
    }
}

fileprivate extension OWCommentTextViewModel {
    
    func messageStringAttributes(with style: OWThemeStyle) -> [NSAttributedString.Key: Any] {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.firstLineHeadIndent = 0
        paragraphStyle.lineSpacing = 3.5

        var attributes: [NSAttributedString.Key: Any]
        attributes = [
            .font: UIFont.preferred(style: .regular, of: OWCommentContentView.Metrics.fontSize),
            .foregroundColor: OWColorPalette.shared.color(type: .foreground1Color, themeStyle: style),
            .paragraphStyle: paragraphStyle
        ]

        return attributes
    }
    
    func actionStringAttributes(with style: OWThemeStyle) -> [NSAttributedString.Key: Any] {
        var attributes: [NSAttributedString.Key: Any] = messageStringAttributes(with: style)
        attributes[.foregroundColor] = OWColorPalette.shared.color(type: .buttonTextColor, themeStyle: style)

        return attributes
    }
    
    func editedStringAttributes(with style: OWThemeStyle) -> [NSAttributedString.Key: Any] {
        var attributes: [NSAttributedString.Key: Any] = messageStringAttributes(with: style)
        attributes[.foregroundColor] = UIColor.gray
        attributes[.font] = UIFont.preferred(style: .italic, of: OWCommentContentView.Metrics.fontSize)

        return attributes
    }
    
    func appendActionStringIfNeeded(_ attString: NSAttributedString, lines: [CTLine], currentState: TextState, style: OWThemeStyle) -> NSMutableAttributedString {
        // In case short message - add nothing here
        guard lines.count > self.lineLimit else { return NSMutableAttributedString(attributedString: attString) }
        switch currentState {
        case .collapsed:
            let visibleLines = lines[0...lineLimit - 1]
            let ellipsis = NSAttributedString(
                string: " ... ",
                attributes: messageStringAttributes(with: style))
            var visibleString = ""
            for line in visibleLines {
                let lineRange = CTLineGetStringRange(line)
                let range = NSRange(location: lineRange.location, length: lineRange.length)
                let lineString = (attString.string as NSString).substring(with: range)
                visibleString.append(lineString)
            }
            var res = NSMutableAttributedString(string: visibleString, attributes: messageStringAttributes(with: style))
            let readMore = NSMutableAttributedString(
                string: self.readMoreText,
                attributes: actionStringAttributes(with: style))
            let trimmedRes = res.attributedStringByTrimming(charSet: .whitespacesAndNewlines)
            res = trimmedRes.mutableCopy() as? NSMutableAttributedString ?? res
            res.append(ellipsis)
            res.append(readMore)
            return res
        case .expanded:
            let readLess = NSMutableAttributedString(
                string: self.readLessText,
                attributes: actionStringAttributes(with: style))
            let res = NSMutableAttributedString(attributedString: attString)
            res.append(readLess)
            return res
        }
    }
    
    func locateURLsInText(text: inout NSMutableAttributedString, style: OWThemeStyle) {
        let linkType: NSTextCheckingResult.CheckingType = [.link]
        var activeURLs: [NSRange: URL] = [:]
        if let detector = try? NSDataDetector(types: linkType.rawValue) {
            let rawText = text.string
            let matches = detector.matches(
                in: rawText,
                options: [],
                range: NSRange(location: 0, length: rawText.count)
            )
            
            for match in matches {
                if let urlMatch = match.url, isUrlSchemeValid(for: urlMatch) {
                    text.addAttributes([.foregroundColor: OWColorPalette.shared.color(type: .linkColor, themeStyle: style)], range: match.range)
                        activeURLs[match.range] = urlMatch
                }
            }
        }
        self.activeURLs = activeURLs
    }
    
    func isUrlSchemeValid(for url: URL) -> Bool {
        return url.scheme?.lowercased() != "mailto"
    }
}
    
fileprivate enum TextState {
    case collapsed
    case expanded
}
