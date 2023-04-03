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
    func shouldTapBeHandeled(at index: Int) -> Bool // TODO: input
}

protocol OWCommentTextViewModeling {
    var inputs: OWCommentTextViewModelingInputs { get }
    var outputs: OWCommentTextViewModelingOutputs { get }
}

class OWCommentTextViewModel: OWCommentTextViewModeling,
                                   OWCommentTextViewModelingInputs,
                                   OWCommentTextViewModelingOutputs {

    fileprivate struct Metrics {
        static let invalidURLSchemes: [String] = ["mailto"]
    }

    var inputs: OWCommentTextViewModelingInputs { return self }
    var outputs: OWCommentTextViewModelingOutputs { return self }

    fileprivate let collapsableTextLineLimit: Int
    fileprivate let disposeBag = DisposeBag()

    fileprivate var readMoreText: String = OWLocalizationManager.shared.localizedString(key: "Read More")

    var labelClickIndex = PublishSubject<Int>()

    fileprivate var readMoreRange: NSRange? = nil
    fileprivate var availableUrlsRange: OWRangeURLsMapper

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
                let attString = self.appendReadMoreIfNeeded(fullAttributedString, lines: lines, currentState: currentState, style: style)
                return (attString, style)
            }
            .unwrap()
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

    func shouldTapBeHandeled(at index: Int) -> Bool {
        if isReadMoreTap(at: index) || getActiveUrl(at: index) != nil {
            return true
        }
        return false
    }
}

fileprivate extension OWCommentTextViewModel {
    func setupObservers() {
        labelClickIndex
            .subscribe(onNext: { [weak self] index in
                guard let self = self else { return }

                if self.isReadMoreTap(at: index) {
                    self._textState.onNext(.expanded)
                } else if let activeUrl = self.getActiveUrl(at: index) {
                    self.urlTap.onNext(activeUrl)
                }
            })
            .disposed(by: disposeBag)
    }

    func isReadMoreTap(at index: Int) -> Bool {
        if let range = self.readMoreRange, range.contains(index) {
            return true
        }
        return false
    }

    func getActiveUrl(at index: Int) -> URL? {
        if let activeUrl = self.availableUrlsRange.first { $0.key.contains(index) }?.value {
            return activeUrl
        }
        return nil
    }
}

fileprivate extension OWCommentTextViewModel {

    func messageStringAttributes(with style: OWThemeStyle) -> [NSAttributedString.Key: Any] {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.firstLineHeadIndent = 0
        paragraphStyle.lineSpacing = OWCommentContentView.Metrics.paragraphLineSpacing

        var attributes: [NSAttributedString.Key: Any]
        attributes = [
            .font: OWFontBook.shared.font(style: .regular, size: OWCommentContentView.Metrics.fontSize),
            .foregroundColor: OWColorPalette.shared.color(type: .textColor4, themeStyle: style),
            .paragraphStyle: paragraphStyle
        ]

        return attributes
    }

    func readMoreStringAttributes(with style: OWThemeStyle) -> [NSAttributedString.Key: Any] {
        var attributes: [NSAttributedString.Key: Any] = messageStringAttributes(with: style)
        attributes[.font] = OWFontBook.shared.font(style: .bold, size: OWCommentContentView.Metrics.fontSize)

        return attributes
    }

    func appendReadMoreIfNeeded(_ attString: NSAttributedString, lines: [CTLine], currentState: OWTextState, style: OWThemeStyle) -> NSMutableAttributedString {
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
        var activeURLs: OWRangeURLsMapper = [:]
        if let detector = try? NSDataDetector(types: linkType.rawValue) {
            let rawText = text.string
            let matches = detector.matches(
                in: rawText,
                options: [],
                range: NSRange(location: 0, length: rawText.count)
            )

            for match in matches {
                if let urlMatch = match.url, isUrlSchemeValid(for: urlMatch) {
                    text.addAttributes([
                        .foregroundColor: OWColorPalette.shared.color(type: .brandColor, themeStyle: style),
                        .underlineStyle: NSUnderlineStyle.single.rawValue], range: match.range)
                        activeURLs[match.range] = urlMatch
                }
            }
        }
        self.availableUrlsRange = activeURLs
    }

    func isUrlSchemeValid(for url: URL) -> Bool {
        guard let urlScheme = url.scheme?.lowercased() else {
            return true
        }

        return !Metrics.invalidURLSchemes.contains(urlScheme)
    }
}
