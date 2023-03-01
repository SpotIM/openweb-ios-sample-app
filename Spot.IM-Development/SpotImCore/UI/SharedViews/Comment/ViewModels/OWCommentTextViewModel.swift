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

typealias OWRangeURLsMapper = [NSRange: URL]

protocol OWCommentTextViewModelingInputs {
    var width: BehaviorSubject<CGFloat> { get }
    var labelClickIndex: PublishSubject<Int> { get }
}

protocol OWCommentTextViewModelingOutputs {
    var attributedString: Observable<NSMutableAttributedString> { get }
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

    fileprivate let collapsableTextLineLimit: Int
    fileprivate let disposeBag = DisposeBag()

    fileprivate var readMoreText: String = LocalizationManager.localizedString(key: "Read More")
    fileprivate var editedText: String = LocalizationManager.localizedString(key: "Edited")

    var labelClickIndex = PublishSubject<Int>()

    fileprivate var readMoreRange: NSRange? = nil
    fileprivate var availableUrlsRange: [NSRange: URL]

    init(comment: SPComment, collapsableTextLineLimit: Int) {
        self.collapsableTextLineLimit = collapsableTextLineLimit
        self.availableUrlsRange = [:]
        _comment.onNext(comment)
        setupObservers()
    }

    fileprivate lazy var _themeStyleObservable: Observable<OWThemeStyle> = {
        OWSharedServicesProvider.shared.themeStyleService().style
    }()

    fileprivate let _comment = BehaviorSubject<SPComment?>(value: nil)
    fileprivate var comment: Observable<SPComment> {
        _comment.unwrap()
    }

    fileprivate lazy var fullAttributedString: Observable<NSMutableAttributedString> = {
        _themeStyleObservable
            .withLatestFrom(comment) { style, comment -> (OWThemeStyle, String)? in
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
    }()

    var width = BehaviorSubject<CGFloat>(value: 0)
    fileprivate var widthObservable: Observable<CGFloat> {
        width
            .distinctUntilChanged()
            .asObservable()
    }

    fileprivate var _lines: Observable<[CTLine]> {
        Observable.combineLatest(fullAttributedString, widthObservable) { messageAttributedString, currentWidth in
            return messageAttributedString.getLines(with: currentWidth)
        }
        .unwrap()
        .asObservable()
    }

    fileprivate var _textState = BehaviorSubject<OWTextState>(value: .collapsed)
    lazy var attributedString: Observable<NSMutableAttributedString> = {
        Observable.combineLatest(_lines, _textState, fullAttributedString, _themeStyleObservable)
            .map { [weak self] lines, currentState, fullAttributedString, style -> (NSMutableAttributedString, OWThemeStyle)? in
                guard let self = self else { return nil }
                let attString = self.appendActionStringIfNeeded(fullAttributedString, lines: lines, currentState: currentState, style: style)
                return (attString, style)
            }
            .unwrap()
            .withLatestFrom(comment) { [weak self] res, comment -> (NSMutableAttributedString, OWThemeStyle) in
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
    }()

    var height: Observable<CGFloat> {
        attributedString
            .withLatestFrom(widthObservable) { attributedString, width in
                let newHeight = attributedString.height(withConstrainedWidth: width)
                return newHeight
        }
        .unwrap()
        .distinctUntilChanged()
        .asObservable()
    }

    var urlTap = PublishSubject<URL>()
    var urlClickedOutput: Observable<URL> {
        urlTap
            .asObservable()
    }
}

fileprivate extension OWCommentTextViewModel {
    func setupObservers() {
        labelClickIndex
            .subscribe(onNext: { [weak self] index in
                guard let self = self,
                      let range = self.readMoreRange else { return }

                if range.contains(index) {
                    self._textState.onNext(.expanded)
                } else {
                    let url = self.availableUrlsRange.first { $0.key.contains(index) }?.value

                    guard let activeUrl = url else { return }
                    self.urlTap.onNext(activeUrl)
                }
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
            .font: OWFontBook.shared.font(style: .regular, size: OWCommentContentView.Metrics.fontSize),
            .foregroundColor: OWColorPalette.shared.color(type: .foreground1Color, themeStyle: style),
            .paragraphStyle: paragraphStyle
        ]

        return attributes
    }

    func readMoreStringAttributes(with style: OWThemeStyle) -> [NSAttributedString.Key: Any] {
        var attributes: [NSAttributedString.Key: Any] = messageStringAttributes(with: style)
        attributes[.font] = OWFontBook.shared.font(style: .bold, size: OWCommentContentView.Metrics.fontSize)

        return attributes
    }

    func editedStringAttributes(with style: OWThemeStyle) -> [NSAttributedString.Key: Any] {
        var attributes: [NSAttributedString.Key: Any] = messageStringAttributes(with: style)
        attributes[.foregroundColor] = UIColor.gray
        attributes[.font] = OWFontBook.shared.font(style: .italic, size: OWCommentContentView.Metrics.editedFontSize)

        return attributes
    }

    func appendActionStringIfNeeded(_ attString: NSAttributedString, lines: [CTLine], currentState: OWTextState, style: OWThemeStyle) -> NSMutableAttributedString {
        // In case short message - add nothing here
        guard lines.count > self.collapsableTextLineLimit else {
            self.readMoreRange = nil
            return NSMutableAttributedString(attributedString: attString)
        }
        switch currentState {
        case .collapsed:
            let visibleLines = lines[0...collapsableTextLineLimit - 1]
            let ellipsis = NSAttributedString(
                string: "... ",
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
                attributes: readMoreStringAttributes(with: style))
            let trimmedRes = res.attributedStringByTrimming(charSet: .whitespacesAndNewlines)
            res = trimmedRes.mutableCopy() as? NSMutableAttributedString ?? res
            res.append(ellipsis)
            self.readMoreRange = NSRange(location: res.length, length: readMore.length)
            res.append(readMore)
            return res
        case .expanded:
            self.readMoreRange = nil
            return NSMutableAttributedString(attributedString: attString)
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
        self.availableUrlsRange = activeURLs
    }

    func isUrlSchemeValid(for url: URL) -> Bool {
        return url.scheme?.lowercased() != "mailto"
    }
}
