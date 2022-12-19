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
    
    init(comment: SPComment) {
        _comment.onNext(comment)
    }
    
    var text: Observable<String?> {
        _comment
            .map {$0?.text?.text}
            .asObservable()
    }
    
    var attributedString: Observable<NSMutableAttributedString?> {
        _comment
            .map { $0?.text?.text }
            .unwrap()
            .map {
                NSMutableAttributedString(string: $0, attributes: [
                    :
                ]) // TODO: build with read more/less, links, edited etc
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
        _commentMediaOriginalSize
            .withLatestFrom(_commentLeadingOffset) { [weak self] mediaOriginalSize, leadingOffset -> CGSize? in
                guard let self = self else { return .zero }
                return self.getMediaSize(originalSize: mediaOriginalSize, leadingOffset: leadingOffset)
            }
            .asObservable()
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
}
