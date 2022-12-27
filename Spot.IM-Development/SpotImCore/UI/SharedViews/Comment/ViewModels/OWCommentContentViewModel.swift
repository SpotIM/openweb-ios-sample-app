//
//  OWCommentContentViewModel.swift
//  SpotImCore
//
//  Created by Alon Shprung on 07/09/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import UIKit

fileprivate struct Metrics {
    static let commentMediaMaxHeight: Float = 226.0
}

protocol OWCommentContentViewModelingInputs {
//    var commentTextLabelWidth: PublishSubject<CGFloat> { get }
}

protocol OWCommentContentViewModelingOutputs {
    var text: Observable<String?> { get }
    var attributedString: Observable<NSMutableAttributedString?> { get }
    var gifUrl: Observable<String?> { get }
    var imageUrl: Observable<URL?> { get }
    var mediaSize: Observable<CGSize?> { get }
}

protocol OWCommentContentViewModeling {
    var inputs: OWCommentContentViewModelingInputs { get }
    var outputs: OWCommentContentViewModelingOutputs { get }
}

class OWCommentContentViewModel: OWCommentContentViewModeling,
                                 OWCommentContentViewModelingInputs,
                                 OWCommentContentViewModelingOutputs {
    
    var inputs: OWCommentContentViewModelingInputs { return self }
    var outputs: OWCommentContentViewModelingOutputs { return self }
    
    fileprivate let _comment = BehaviorSubject<SPComment?>(value: nil)
    fileprivate let lineLimit: Int
    
    init(comment: SPComment, lineLimit: Int = 4) { // TODO: pass line limit
        self.lineLimit = lineLimit
        _comment.onNext(comment)
    }
    init() {
        lineLimit = 0
    }
    
//    var commentTextLabelWidth = PublishSubject<CGFloat>()
//    var _commentTextLabelWidth: Observable<CGFloat> {
//        commentTextLabelWidth
//            .map {$0}
//            .asObservable()
//    }

    
    var text: Observable<String?> {
        _comment
            .map {$0?.text?.text}
            .asObservable()
    }
    
    fileprivate var textState: TextState = .notInitialized // TODO: ?
    var attributedString: Observable<NSMutableAttributedString?> {
        text
            .map { [weak self] messageText in
                let width = 200.0 // TODO: get real width
                guard let self = self, let messageText = messageText else { return nil }
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
    
    var gifUrl: Observable<String?> {
        _comment
            .map { $0?.gif?.originalUrl }
            .asObservable()
    }
    
    var imageUrl: Observable<URL?> {
        _comment
            .map { [weak self] comment in
                return self?.imageURL(with: comment?.image?.imageId, size: nil)
            }
            .asObservable()
    }
    
    var mediaSize: Observable<CGSize?> {
        Observable.combineLatest(_commentMediaOriginalSize, _commentLeadingOffset) { [weak self] mediaOriginalSize, leadingOffset -> CGSize in
            guard let self = self else { return .zero }
            return self.getMediaSize(originalSize: mediaOriginalSize, leadingOffset: leadingOffset)
        }.asObservable()
    }
}

fileprivate extension OWCommentContentViewModel {
    var _commentMediaOriginalSize: Observable<CGSize> {
        _comment
            .map { comment in
                if let gif = comment?.gif {
                    return CGSize(width: gif.originalWidth, height: gif.originalHeight)
                } else if let image = comment?.image {
                    return CGSize(width: image.originalWidth, height: image.originalHeight)
                } else {
                    return .zero
                }
            }
            .asObservable()
    }
    
    var _commentLeadingOffset: Observable<CGFloat> {
        _comment
            .unwrap()
            .map { [weak self] comment in
                guard let self = self else { return 0 }
                return self.depthOffset(depth: comment.depth ?? 0)
            }
            .asObservable()
    }
    
    func depthOffset(depth: Int) -> CGFloat {
        switch depth {
        case 0: return 0
        case 1: return 25.0
        case 2: return 40.0
        default: return 55.0
        }
    }
    
    func getMediaSize(originalSize: CGSize, leadingOffset: CGFloat) -> CGSize {
        guard originalSize.height > 0 && originalSize.width > 0 else { return .zero }
        let maxWidth = SPUIWindow.frame.width - leadingOffset // TODO: comment leading+trailing offset ?

        // calculate media width according to height ratio
        var height = Metrics.commentMediaMaxHeight
        var ratio: Float = Float(height / Float(originalSize.height))
        var width = ratio * Float(originalSize.width)
        // if width > cell - recalculate size
        if width > Float(maxWidth) {
            width = (Float)(maxWidth)
            ratio = Float(width / Float(originalSize.width))
            height = (ratio * Float(originalSize.height))
        }

        return CGSize(width: CGFloat(width), height: CGFloat(height))
    }
    
    // TODO: should be in some imageprovider
    func imageURL(with id: String?, size: CGSize? = nil) -> URL? {
        guard var id = id else { return nil }
        
        if id.hasPrefix(SPImageRequestConstants.placeholderImagePrefix) {
            id.removeFirst(SPImageRequestConstants.placeholderImagePrefix.count)
            id = SPImageRequestConstants.avatarPathComponent.appending(id)
        }
        return URL(string: cloudinaryURLString(size).appending(id))
    }
    private func cloudinaryURLString(_ imageSize: CGSize? = nil) -> String {
        var result = APIConstants.fetchImageBaseURL.appending(SPImageRequestConstants.cloudinaryImageParamString)
        
        if let imageSize = imageSize {
            result.append("\(SPImageRequestConstants.cloudinaryWidthPrefix)" +
                "\(Int(imageSize.width))" +
                "\(SPImageRequestConstants.cloudinaryHeightPrefix)" +
                "\(Int(imageSize.height))"
            )
        }
        
        return result.appending("/")
    }
    
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
    
//    private func readMoreAppended(with index: Int, _ lines: [CTLine], _ width: CGFloat) -> NSAttributedString {
//
//        let slice = lines[0...index - 1]
//        var lastLineLength = 0
//        var totalLength = slice.reduce(into: 0) { (tempCount, line) in
//            lastLineLength = CTLineGetGlyphCount(line)
//            tempCount += lastLineLength
//        }
//
//        var attribs = self.attributes(at: totalLength - 1, effectiveRange: nil)
//
//        let ellipsis = NSAttributedString(
//            string: " ... ",
//            attributes: attribs)
//
//        attribs[.foregroundColor] = UIColor.clearBlue
//
//        let readMore = NSMutableAttributedString(
//            string: LocalizationManager.localizedString(key: "Read More"),
//            attributes: attribs)
//
//        readMore.insert(ellipsis, at: 0)
//
//        let readMoreWidth = readMore.width(withConstrainedHeight: .greatestFiniteMagnitude)
//
//        // check wether additional last line clipping is needed
//        let lastLineRange = NSRange(location: totalLength - lastLineLength, length: lastLineLength)
//        let lastLine = attributedSubstring(from: lastLineRange)
//        let lastLineWidth = lastLine.width(withConstrainedHeight: .greatestFiniteMagnitude)
//
//        if lastLineWidth + readMoreWidth > width {
//            totalLength -= lastLineLength / 2
//        }
//
//        let clippedSelf = attributedSubstring(from: NSRange(location: 0, length: totalLength))
//        let trimmedSelf = clippedSelf.attributedStringByTrimming(charSet: .whitespacesAndNewlines)
//        let mutableSelf = trimmedSelf.mutableCopy() as? NSMutableAttributedString
//        mutableSelf?.append(readMore)
//
//        return mutableSelf ?? self
//    }
}

fileprivate enum TextState {
    case notInitialized
    case fullyShown
    case collapsed
    case expanded
}
