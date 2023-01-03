//
//  OWCollapsableLabelViewModel.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 27/12/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import UIKit

protocol OWCollapsableLabelViewModelingInputs {
    var width: PublishSubject<CGFloat> { get }
}

protocol OWCollapsableLabelViewModelingOutputs {
//    var collapsedNumberOfLines: Observable<Int> { get }
    var attributedString: Observable<NSMutableAttributedString?> { get }
    var text: Observable<String> { get }
}

protocol OWCollapsableLabelViewModeling {
    var inputs: OWCollapsableLabelViewModelingInputs { get }
    var outputs: OWCollapsableLabelViewModelingOutputs { get }
}

class OWCollapsableLabelViewModel: OWCollapsableLabelViewModeling,
                                   OWCollapsableLabelViewModelingInputs,
                                   OWCollapsableLabelViewModelingOutputs {
    
    var inputs: OWCollapsableLabelViewModelingInputs { return self }
    var outputs: OWCollapsableLabelViewModelingOutputs { return self }
    
    fileprivate let _lineLimit = BehaviorSubject<Int>(value: 0)
    var collapsedNumberOfLines: Observable<Int> {
        _lineLimit
            .map {$0}
    }
    fileprivate var lineLimit: Int = 0
    
    fileprivate let _fullText = BehaviorSubject<String?>(value: nil)
    var text: Observable<String> {
        _fullText
            .unwrap()
            .map {$0}
    }
    
    var width = PublishSubject<CGFloat>()
    
    init(text: String, lineLimit: Int) {
//        _lineLimit.onNext(lineLimit)
        self.lineLimit = lineLimit
        _fullText.onNext(text)
    }
    
    fileprivate var textState: TextState = .notInitialized // TODO: ?
    var attributedString: Observable<NSMutableAttributedString?> {
        text
            .map { [weak self] messageText in
                let width = 200.0 // TODO: get real width
                guard let self = self else { return nil }
                var messageAttributedString: NSMutableAttributedString = NSMutableAttributedString(
                    string: messageText,
                    attributes: self.messageStringAttributes()
                )
                let lines = messageAttributedString.getLines(with: width)
                self.setTextState(lines: lines.count)
                self.appendActionStringIfNeeded(messageAttributedString, lines: lines)
                return messageAttributedString
//                return NSMutableAttributedString(string: messageText, attributes: [
//                    :
//                ]) // TODO: build with read more/less, links, edited etc
            }
            .asObservable()
    }
}

fileprivate extension OWCollapsableLabelViewModel {
    
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
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.firstLineHeadIndent = 0
        paragraphStyle.lineSpacing = 3.5

        var attributes: [NSAttributedString.Key: Any] = messageStringAttributes()
        attributes[.foregroundColor] = UIColor.clearBlue // TODO: color

        return attributes
    }
    
    func setTextState(lines: Int) {
        // this function is only for the first init
        guard self.textState == .notInitialized else { return }
        
        textState = lines > self.lineLimit ? .collapsed : .fullyShown
    }
    
    func appendActionStringIfNeeded(_ attString: NSMutableAttributedString, lines: [CTLine]) {
        switch self.textState {
        case .collapsed:
            let visibleLines = lines[0...lineLimit - 1]
            let ellipsis = NSAttributedString(
                string: " ... ",
                attributes: messageStringAttributes())
            let readMore = NSMutableAttributedString(
                string: LocalizationManager.localizedString(key: "Read More"),
                attributes: actionStringAttributes())
            attString.append(ellipsis)
            attString.append(readMore)
            break
        case .expanded:
            break
        default:
            break
        }
    }
}
    
fileprivate enum TextState {
    case notInitialized
    case fullyShown
    case collapsed
    case expanded
}
