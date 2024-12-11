//
//  OWCommentTextViewModel.swift
//  OpenWebSDK
//
//  Created by  Nogah Melamed on 27/12/2022.
//  Copyright © 2022 OpenWeb. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import UIKit

typealias OWRangeURLsMapper = [NSRange: URL]

protocol OWCommentTextViewModelingInputs {
    func update(comment: OWComment)
    var width: BehaviorSubject<CGFloat> { get }
    var labelClickIndex: PublishSubject<Int> { get }
    func shouldTapBeHandeled(at index: Int) -> Bool
}

protocol OWCommentTextViewModelingOutputs {
    var attributedString: Observable<NSMutableAttributedString> { get }
    var urlClickedOutput: Observable<URL> { get }
    var height: Observable<CGFloat> { get }
    var readMoreTap: Observable<Void> { get }
}

protocol OWCommentTextViewModeling {
    var inputs: OWCommentTextViewModelingInputs { get }
    var outputs: OWCommentTextViewModelingOutputs { get }
}

class OWCommentTextViewModel: OWCommentTextViewModeling,
                                   OWCommentTextViewModelingInputs,
                                   OWCommentTextViewModelingOutputs {

    private struct Metrics {
        static let textOffset: CGFloat = OWCommentView.Metrics.horizontalOffset + OWCommentCell.ExternalMetrics.horizontalOffset * 2
        static let invalidURLSchemes: [String] = ["mailto"]
    }

    var inputs: OWCommentTextViewModelingInputs { return self }
    var outputs: OWCommentTextViewModelingOutputs { return self }

    private let collapsableTextLineLimit: Int
    private let disposeBag = DisposeBag()

    private var readMoreText: String = OWLocalizationManager.shared.localizedString(key: "SeeMore")

    var labelClickIndex = PublishSubject<Int>()

    private var userMentions: [OWUserMentionObject]
    private var readMoreRange: NSRange?
    private var availableUrlsRange: OWRangeURLsMapper = [:]
    private var serviceProvider: OWSharedServicesProviding

    init(serviceProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared,
         comment: OWComment,
         collapsableTextLineLimit: Int) {
        self.serviceProvider = serviceProvider
        self.collapsableTextLineLimit = collapsableTextLineLimit
        var comment = comment
        self.userMentions = OWUserMentionHelper.createUserMentions(from: &comment)
        _comment.onNext(comment)
        setupObservers()
    }

    func update(comment: OWComment) {
        var comment = comment
        userMentions.removeAll()
        userMentions.append(contentsOf: OWUserMentionHelper.createUserMentions(from: &comment))
        _comment.onNext(comment)
    }

    private lazy var _themeStyleObservable: Observable<OWThemeStyle> = {
        OWSharedServicesProvider.shared.themeStyleService().style
    }()

    private let _comment = BehaviorSubject<OWComment?>(value: nil)
    private var comment: Observable<OWComment> {
        _comment.unwrap()
    }

    private lazy var fullAttributedString: Observable<NSMutableAttributedString> = {
        Observable.combineLatest(_themeStyleObservable, _comment)
            .map { [weak self] style, comment in
                guard let messageText = comment?.text?.text else { return NSMutableAttributedString() }
                guard let self else { return nil }
                return NSMutableAttributedString(
                    string: messageText,
                    attributes: self.messageStringAttributes(with: style)
                )
            }
            .unwrap()
    }()

    var width = BehaviorSubject<CGFloat>(value: 0)
    private var widthObservable: Observable<CGFloat> {
        self.serviceProvider.conversationSizeService().conversationTableSize
            .distinctUntilChanged()
            .map { $0.width }
            .withLatestFrom(comment) { ($0, $1) }
            .map { [weak self] width, comment -> CGFloat? in
                guard let _ = self else { return nil }
                let depth = min(comment.depth ?? 0, OWCommentCell.ExternalMetrics.maxDepth)
                let adjustedWidth = width - Metrics.textOffset - CGFloat(depth) * OWCommentCell.ExternalMetrics.depthOffset
                return adjustedWidth
            }
            .unwrap()
            .asObservable()
    }

    private var _linesAndFullAttributedString: Observable<([CTLine], NSMutableAttributedString)> {
        Observable.combineLatest(fullAttributedString, widthObservable) { messageAttributedString, currentWidth in
            return (messageAttributedString.getLines(with: currentWidth), messageAttributedString)
        }
        .unwrap()
        .asObservable()
    }

    private var _textState = BehaviorSubject<OWTextState>(value: .collapsed)
    lazy var readMoreTap: Observable<Void> = {
        _textState
            .asObservable()
            .filter { $0 == .expanded }
            .voidify()
    }()

    lazy var attributedString: Observable<NSMutableAttributedString> = {
        Observable.combineLatest(_linesAndFullAttributedString, _textState, _themeStyleObservable)
            .map { [weak self] linesAndAttributedString, currentState, style -> (NSMutableAttributedString, OWThemeStyle)? in
                guard let self else { return nil }
                let lines = linesAndAttributedString.0
                let fullAttributedString = linesAndAttributedString.1
                let attString = self.appendReadMoreIfNeeded(fullAttributedString, lines: lines, currentState: currentState, style: style)
                return (attString, style)
            }
            .unwrap()
            .withLatestFrom(comment) { ($0.0, $0.1, $1) }
            .map { [weak self] attString, style, comment in
                guard let self,
                      var res = attString.mutableCopy() as? NSMutableAttributedString else { return attString }
                self.locateURLsInText(text: &res, style: style)
                self.availableUrlsRange = res.addUserMentions(style: style,
                                                              comment: comment,
                                                              userMentions: userMentions,
                                                              readMoreRange: readMoreRange,
                                                              serviceProvider: serviceProvider)
                return res
            }
            .distinctUntilChanged()
            .asObservable()
    }()

    var height: Observable<CGFloat> {
        Observable.combineLatest(attributedString, widthObservable) { attributedString, width in
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

private extension OWCommentTextViewModel {
    func setupObservers() {
        labelClickIndex
            .subscribe(onNext: { [weak self] index in
                guard let self else { return }

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
        let maybeActiveUrl = self.availableUrlsRange.first { $0.key.contains(index) }?.value
        if let activeUrl = maybeActiveUrl {
            return activeUrl
        }
        return nil
    }
}

private extension OWCommentTextViewModel {

    func messageStringAttributes(with style: OWThemeStyle) -> [NSAttributedString.Key: Any] {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.firstLineHeadIndent = 0
        paragraphStyle.lineSpacing = OWCommentContentView.Metrics.paragraphLineSpacing
        paragraphStyle.alignment = OWLocalizationManager.shared.textAlignment

        var attributes: [NSAttributedString.Key: Any]
        attributes = [
            .font: OWFontBook.shared.font(typography: .bodyText),
            .foregroundColor: OWColorPalette.shared.color(type: .textColor4, themeStyle: style),
            .paragraphStyle: paragraphStyle
        ]

        return attributes
    }

    func readMoreStringAttributes(with style: OWThemeStyle) -> [NSAttributedString.Key: Any] {
        var attributes: [NSAttributedString.Key: Any] = messageStringAttributes(with: style)
        attributes[.font] = OWFontBook.shared.font(typography: .bodyContext)

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
        if let detector = try? NSDataDetector(types: linkType.rawValue) {
            let rawText = text.string
            let matches = detector.matches(
                in: rawText,
                options: [],
                range: NSRange(rawText.startIndex..., in: rawText)
            )

            for match in matches {
                if let urlMatch = match.url, isUrlSchemeValid(for: urlMatch) {
                    text.addAttributes([
                        .foregroundColor: OWColorPalette.shared.color(type: .brandColor, themeStyle: style),
                        .underlineStyle: NSUnderlineStyle.single.rawValue], range: match.range)
                    availableUrlsRange[match.range] = urlMatch
                }
            }
        }
    }

    func isUrlSchemeValid(for url: URL) -> Bool {
        guard let urlScheme = url.scheme?.lowercased() else {
            return true
        }

        return !Metrics.invalidURLSchemes.contains(urlScheme)
    }
}
