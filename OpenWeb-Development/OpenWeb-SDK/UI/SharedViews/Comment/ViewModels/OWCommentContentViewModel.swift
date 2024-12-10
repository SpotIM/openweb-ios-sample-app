//
//  OWCommentContentViewModel.swift
//  OpenWebSDK
//
//  Created by Alon Shprung on 07/09/2022.
//  Copyright © 2022 OpenWeb. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import UIKit

protocol OWCommentContentViewModelingInputs {
    func update(comment: OWComment)
    var imageTapped: PublishSubject<UIImage> { get }
}

protocol OWCommentContentViewModelingOutputs {
    var gifUrl: Observable<String> { get }
    var image: Observable<OWImageType> { get }
    var mediaSize: Observable<CGSize> { get }
    var isEdited: Observable<Bool> { get }

    var collapsableLabelViewModel: OWCommentTextViewModeling { get }
}

protocol OWCommentContentViewModeling {
    var inputs: OWCommentContentViewModelingInputs { get }
    var outputs: OWCommentContentViewModelingOutputs { get }
}

class OWCommentContentViewModel: OWCommentContentViewModeling,
                                 OWCommentContentViewModelingInputs,
                                 OWCommentContentViewModelingOutputs {
    private struct Metrics {
        static let commentMediaMaxHeight: Float = 226.0
        static let depth0Offset: CGFloat = 0.0
        static let depth1Offset: CGFloat = 25.0
        static let depth2Offset: CGFloat = 40.0
        static let maxDepthOffset: CGFloat = 55.0
    }

    var inputs: OWCommentContentViewModelingInputs { return self }
    var outputs: OWCommentContentViewModelingOutputs { return self }

    private let _comment = BehaviorSubject<OWComment?>(value: nil)
    private let lineLimit: Int
    private let imageProvider: OWImageProviding

    var disposeBag = DisposeBag()

    var imageTapped = PublishSubject<UIImage>()
    var collapsableLabelViewModel: OWCommentTextViewModeling

    let viewableMode: OWViewableMode

    init(comment: OWComment, lineLimit: Int, imageProvider: OWImageProviding = OWCloudinaryImageProvider(), viewableMode: OWViewableMode) {
        self.lineLimit = lineLimit
        self.collapsableLabelViewModel = OWCommentTextViewModel(comment: comment, collapsableTextLineLimit: lineLimit)
        self.imageProvider = imageProvider
        self.viewableMode = viewableMode
        _comment.onNext(comment)
        setupObservers()
    }

    init(imageProvider: OWImageProviding = OWCloudinaryImageProvider(), viewableMode: OWViewableMode) {
        lineLimit = 0
        self.collapsableLabelViewModel = OWCommentTextViewModel(comment: OWComment(), collapsableTextLineLimit: lineLimit)
        self.imageProvider = imageProvider
        self.viewableMode = viewableMode
        setupObservers()
    }

    func update(comment: OWComment) {
        _comment.onNext(comment)
        collapsableLabelViewModel.inputs.update(comment: comment)
    }

    var gifUrl: Observable<String> {
        _comment
            .map { $0?.gif?.originalUrl }
            .unwrap()
            .asObservable()
    }

    var image: Observable<OWImageType> {
        _comment
            .flatMap { [weak self] comment -> Observable<URL?> in
                guard let self,
                      let imageId = comment?.image?.imageId
                else { return .empty() }

                return self.imageProvider.imageURL(with: imageId, size: nil)
            }
            .map { url in
                guard let url else { return .defaultImage }
                return .custom(url: url)
            }
            .asObservable()
    }

    var mediaSize: Observable<CGSize> {
        Observable.combineLatest(_commentMediaOriginalSize, _commentLeadingOffset) { [weak self] mediaOriginalSize, leadingOffset -> CGSize in
            guard let self else { return .zero }
            return self.getMediaSize(originalSize: mediaOriginalSize, leadingOffset: leadingOffset)
        }.asObservable()
    }

    var isEdited: Observable<Bool> {
        _comment
            .map { comment in
                guard let comment
                else { return false }

                return comment.edited
            }
            .asObservable()
    }

    private lazy var _commentMediaOriginalSize: Observable<CGSize> = {
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
    }()

    private lazy var _commentLeadingOffset: Observable<CGFloat> = {
        _comment
            .unwrap()
            .map { [weak self] comment in
                guard let self else { return 0 }
                return self.leadingOffset(perCommentDepth: comment.depth ?? 0)
            }
            .asObservable()
    }()
}

private extension OWCommentContentViewModel {
    func setupObservers() {
        imageTapped
            .subscribe(onNext: { [weak self] image in
                guard let self else { return }
                OWSharedServicesProvider.shared.presenterService().presentZoomableImage(with: image, viewableMode: self.viewableMode)
            })
            .disposed(by: disposeBag)
    }

    func leadingOffset(perCommentDepth depth: Int) -> CGFloat {
        switch depth {
        case 0: return Metrics.depth0Offset
        case 1: return Metrics.depth1Offset
        case 2: return Metrics.depth2Offset
        default: return Metrics.maxDepthOffset
        }
    }

    func getMediaSize(originalSize: CGSize, leadingOffset: CGFloat) -> CGSize {
        guard originalSize.height > 0 && originalSize.width > 0 else { return .zero }

        let appWidth: CGFloat
        if let appWindow = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) {
            appWidth = appWindow.bounds.width
        } else {
            appWidth = UIScreen.main.bounds.width
        }

        let maxWidth = appWidth - leadingOffset // TODO: comment leading+trailing offset ?

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
}
