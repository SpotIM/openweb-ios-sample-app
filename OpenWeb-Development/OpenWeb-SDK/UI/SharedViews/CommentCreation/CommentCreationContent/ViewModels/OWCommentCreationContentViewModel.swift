//
//  OWCommentCreationContentViewModel.swift
//  OpenWebSDK
//
//  Created by Alon Shprung on 03/07/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

protocol OWCommentCreationContentViewModelingInputs {
    var becomeFirstResponder: PublishSubject<Void> { get }
    var resignFirstResponder: PublishSubject<Void> { get }
    var imagePicked: PublishSubject<UIImage> { get }
    var gifPicked: PublishSubject<OWCommentGif> { get }
}

protocol OWCommentCreationContentViewModelingOutputs {
    var commentImageOutput: Observable<OWCommentImage?> { get }
    var avatarViewVM: OWAvatarViewModeling { get }
    var imagePreviewVM: OWCommentCreationImagePreviewViewModeling { get }
    var gifPreviewVM: OWGifPreviewViewModeling { get }
    var commentContent: Observable<OWCommentCreationContent> { get }
    var isValidatedContent: Observable<Bool> { get }
    var isInitialContentEdited: Observable<Bool> { get }
    var textViewVM: OWTextViewViewModeling { get }
}

protocol OWCommentCreationContentViewModeling {
    var inputs: OWCommentCreationContentViewModelingInputs { get }
    var outputs: OWCommentCreationContentViewModelingOutputs { get }
}

class OWCommentCreationContentViewModel: OWCommentCreationContentViewModeling,
                                         OWCommentCreationContentViewModelingInputs,
                                         OWCommentCreationContentViewModelingOutputs {

    var inputs: OWCommentCreationContentViewModelingInputs { return self }
    var outputs: OWCommentCreationContentViewModelingOutputs { return self }

    private struct Metrics {
        static let delayAfterLoadingImage = 50
    }

    private let disposeBag = DisposeBag()
    private var uploadImageDisposeBag = DisposeBag()
    private let imageURLProvider: OWImageProviding
    private let servicesProvider: OWSharedServicesProviding
    private let commentCreationType: OWCommentCreationTypeInternal

    private lazy var postId = OWManager.manager.postId

    var imagePicked = PublishSubject<UIImage>()
    var gifPicked = PublishSubject<OWCommentGif>()

    private let _imageContent = BehaviorSubject<OWCommentImage?>(value: nil)

    var commentContent: Observable<OWCommentCreationContent> {
        Observable.combineLatest(textViewVM.outputs.textViewText, _imageContent.asObservable(), gifPreviewVM.outputs.gifDataOutput)
            .map { text, image, gif in
                OWCommentCreationContent(text: text, image: image, gif: gif)
            }
    }

    lazy var imagePreviewVM: OWCommentCreationImagePreviewViewModeling = {
        return OWCommentCreationImagePreviewViewModel(servicesProvider: servicesProvider)
    }()

    lazy var gifPreviewVM: OWGifPreviewViewModeling = {
        return OWGifPreviewViewModel(servicesProvider: servicesProvider)
    }()

    lazy var avatarViewVM: OWAvatarViewModeling = {
        OWAvatarViewModel(imageURLProvider: imageURLProvider)
    }()

    private lazy var _commentTextCharactersLimit: Observable<Int?> = {
        return servicesProvider.spotConfigurationService().config(spotId: OWManager.manager.spotId)
            .materialize()
            .map { event -> Int? in
                switch event {
                case .next(let config):
                    guard config.mobileSdk.shouldShowCommentCounter else { return nil }
                    return config.mobileSdk.commentCounterCharactersLimit
                case .error:
                    return nil
                default:
                    return nil
                }
            }
            .unwrap() // Required to prevent subscription ending after "complete" event
            .startWith(nil)
    }()

    var commentImageOutput: Observable<OWCommentImage?> {
        _imageContent
            .asObservable()
    }

    var becomeFirstResponder = PublishSubject<Void>()
    var resignFirstResponder = PublishSubject<Void>()

    var isInitialContentEdited: Observable<Bool> {
        Observable.combineLatest(
            commentContent,
            _imageContent,
            gifPreviewVM.inputs.gifData
        )
        .map { [weak self] commentContent, imageContent, gifContent -> Bool in
            guard let self else { return false }

            if case .edit(comment: let comment) = self.commentCreationType {
                if comment.text?.text != commentContent.text ||
                    comment.image?.imageId != imageContent?.imageId ||
                    comment.gif?.originalUrl != gifContent?.originalUrl {
                    return true
                }
            }
            return false
        }
    }

    var isValidatedContent: Observable<Bool> {
        return Observable.combineLatest(
            commentContent,
            imagePreviewVM.outputs.isUploadingImageObservable
        )
        .map { commentContent, isUploadingImage -> Bool in
            // Validate / invalidate according to content and uploading image state
            return commentContent.hasContent() && !isUploadingImage
        }
    }

    let textViewVM: OWTextViewViewModeling

    init(commentCreationType: OWCommentCreationTypeInternal,
         servicesProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared,
         imageURLProvider: OWImageProviding = OWCloudinaryImageProvider()) {
        self.servicesProvider = servicesProvider
        self.imageURLProvider = imageURLProvider
        self.commentCreationType = commentCreationType
        let currentOrientation = OWSharedServicesProvider.shared.orientationService().currentOrientation
        let placeholderText = {
            switch commentCreationType {
            case .replyToComment:
                return OWLocalizationManager.shared.localizedString(key: "TypeYourReply")
            default:
                return OWLocalizationManager.shared.localizedString(key: "WhatDoYouThink")
            }
        }()
        let textViewData = OWTextViewData(placeholderText: placeholderText,
                                          charectersLimitEnabled: false,
                                          showCharectersLimit: false,
                                          isEditable: true,
                                          isAutoExpandable: false,
                                          hasSuggestionsBar: currentOrientation == .portrait,
                                          isScrollEnabled: false,
                                          hasBorder: false)
        self.textViewVM = OWTextViewViewModel(textViewData: textViewData)
        self.setupInitialTextIfNeeded()
        self.setupInitialImageIfNeeded()
        self.setupInitialGifIfNeeded()

        setupObservers()
    }
}

private extension OWCommentCreationContentViewModel {
    func setupInitialTextIfNeeded() {
        let commentsCacheService = self.servicesProvider.commentsInMemoryCacheService()
        var initialText: String?
        switch commentCreationType {
        case .comment:
            guard let postId = self.postId,
                  let commentCreationCache = commentsCacheService[.comment(postId: postId)] else { return }
            initialText = OWUserMentionHelper.addUserMentionDisplayNames(to: commentCreationCache.commentContent.text, mentions: commentCreationCache.commentUserMentions)
        case .replyToComment(originComment: let originComment):
            guard let postId = self.postId,
                  let originCommentId = originComment.id,
                  let commentCreationCache = commentsCacheService[.reply(postId: postId, commentId: originCommentId)] else { return }
            initialText = OWUserMentionHelper.addUserMentionDisplayNames(to: commentCreationCache.commentContent.text, mentions: commentCreationCache.commentUserMentions)
        case .edit(comment: let comment):
            if let commentText = comment.text?.text {
                initialText = commentText
            }
            if let postId,
               let commentId = comment.id,
               let commentCreationCache = commentsCacheService[.edit(postId: postId, commentId: commentId)] {
                initialText = OWUserMentionHelper.addUserMentionDisplayNames(to: commentCreationCache.commentContent.text, mentions: commentCreationCache.commentUserMentions)
            }
        }

        if let text = initialText {
            textViewVM.inputs.textExternalChange.onNext(text)
        }
    }

    func setupInitialImageIfNeeded() {
        let initialImage: OWCommentImage?
        let commentsCacheService = self.servicesProvider.commentsInMemoryCacheService()

        switch commentCreationType {
        case .comment:
            guard let postId else { return }
            initialImage = commentsCacheService[.comment(postId: postId)]?.commentContent.image
        case .replyToComment(originComment: let originComment):
            guard let postId = self.postId,
                  let originCommentId = originComment.id
            else { return }
            initialImage = commentsCacheService[.reply(postId: postId, commentId: originCommentId)]?.commentContent.image
        case .edit(let comment):
            initialImage = comment.image
        }

        guard let imageContent = initialImage else { return }

        Observable.just(())
            .do(onNext: { [weak self] _ in
                // Set a placeholder
                guard let self else { return }
                if let placeholder = UIImage(spNamed: "imageMediaPlaceholder", supportDarkMode: false) {
                    self.imagePreviewVM.inputs.image.onNext(placeholder)
                }
            })
            .flatMap { [weak self] _ -> Observable<URL?> in
                guard let self else { return .empty() }
                return self.imageURLProvider.imageURL(with: imageContent.imageId, size: nil)
            }
            .unwrap()
            .observe(on: MainScheduler.instance)
            .flatMap { imageUrl -> Observable<UIImage> in
                return UIImage.load(with: imageUrl)
            }
        // we added delay to fix a case we showed empty image
            .delay(.milliseconds(Metrics.delayAfterLoadingImage), scheduler: ConcurrentDispatchQueueScheduler(qos: .userInteractive))
            .subscribe(onNext: { [weak self] image in
                guard let self else { return }
                self.imagePreviewVM.inputs.image.onNext(image)
                self._imageContent.onNext(imageContent)
            })
            .disposed(by: disposeBag)
    }

    func setupInitialGifIfNeeded() {
        let initialGif: OWCommentGif?
        let commentsCacheService = self.servicesProvider.commentsInMemoryCacheService()

        switch commentCreationType {
        case .comment:
            guard let postId else { return }
            initialGif = commentsCacheService[.comment(postId: postId)]?.commentContent.gif
        case .replyToComment(originComment: let originComment):
            guard let postId = self.postId,
                  let originCommentId = originComment.id
            else { return }
            initialGif = commentsCacheService[.reply(postId: postId, commentId: originCommentId)]?.commentContent.gif
        case .edit(let comment):
            initialGif = comment.gif
        }

        guard let initialGif else { return }

        gifPreviewVM.inputs.gifData.onNext(initialGif)
    }

    func textValidatorTransformer(previousText: String, newText: String, charactersLimiter: Int) -> String {
        // Handle a state in which a user is trying to edit a text which is longer than the limiter
        if previousText.isEmpty && newText.count > charactersLimiter {
            return String(newText.prefix(charactersLimiter))
        } else if newText.count > charactersLimiter {
            // Intentionally block copy paste of longer than limiter or further characters the user is trying to add
            return previousText
        } else { // All good and valid, return new text
            return newText
        }
    }

    func setupObservers() {
        setupImageObserver()

        servicesProvider.authenticationManager()
            .activeUserAvailability
            .subscribe(onNext: { [weak self] availability in
                guard let self else { return }
                switch availability {
                case .notAvailable:
                    self.avatarViewVM.inputs.userInput.onNext(nil)
                case .user(let user):
                    self.avatarViewVM.inputs.userInput.onNext(user)
                }
            })
            .disposed(by: disposeBag)

        self.imagePreviewVM.outputs.removeButtonTapped
            .subscribe(onNext: { [weak self] _ in
                guard let self else { return }
                self.uploadImageDisposeBag = DisposeBag()
                self.setupImageObserver()
                self._imageContent.onNext(nil)
                self.imagePreviewVM.inputs.isUploadingImage.onNext(false)
            })
            .disposed(by: disposeBag)

        _commentTextCharactersLimit
            .subscribe(onNext: { [weak self] limit in
                guard let self else { return }
                let limit = limit ?? 0
                self.textViewVM.inputs.textViewMaxCharectersChange.onNext(limit)
                self.textViewVM.inputs.charectarsLimitEnabledChange.onNext(limit > 0)
            })
            .disposed(by: disposeBag)

        becomeFirstResponder
            .map { 0 }
            .bind(to: textViewVM.inputs.becomeFirstResponderCallWithDelay)
            .disposed(by: disposeBag)

        resignFirstResponder
            .bind(to: textViewVM.inputs.resignFirstResponderCall)
            .disposed(by: disposeBag)

        OWSharedServicesProvider.shared.orientationService().orientation
            .subscribe(onNext: { [weak self] currentOrientation in
                guard let self else { return }
                let isSuggestionBarEnabled = (currentOrientation == .portrait)
                self.textViewVM.inputs.hasSuggestionsBarChange.onNext(isSuggestionBarEnabled)
            })
            .disposed(by: disposeBag)
    }

    func setupImageObserver() {
        let imageWithCloudinarySignatureObservable = imagePicked
            .do(onNext: { [weak self] image in
                guard let self else { return }
                // Clean selected gif
                self.gifPreviewVM.inputs.removeButtonTap.onNext()
                self._imageContent.onNext(nil)
                self.imagePreviewVM.inputs.image.onNext(image)
                self.imagePreviewVM.inputs.isUploadingImage.onNext(true)
            })
            .flatMapLatest { [weak self] image -> Observable<(Event<SPSignResponse>, UIImage, String, String)> in
                guard let self else { return .empty() }
                let imageId = UUID().uuidString
                let timestamp = String(format: "%.3f", NSDate().timeIntervalSince1970)
                return self.servicesProvider
                    .networkAPI()
                    .images
                    .login(publicId: imageId, timestamp: timestamp)
                    .response
                    .materialize()
                    .map { ($0, image, imageId, timestamp) }
            }
            .map { event, image, imageId, timestamp -> (String, UIImage, String, String)? in
                switch event {
                case .next(let signResponse):
                    return (signResponse.signature, image, imageId, timestamp)
                case .error:
                    return nil
                default:
                    return nil
                }
            }
            .unwrap()

        let imageContentObservable = imageWithCloudinarySignatureObservable
            .flatMapLatest { [weak self] cloudinarySignature, image, imageId, timestamp -> Observable<(Event<OWUploadImageResponse>, String)> in
                guard let self,
                      let imageData = image.jpegData(compressionQuality: 1.0)?.base64EncodedString()
                else { return .empty() }
                return self.servicesProvider
                    .networkAPI()
                    .images
                    .upload(
                        signature: cloudinarySignature,
                        publicId: imageId,
                        timestamp: timestamp,
                        imageData: imageData
                    )
                    .response
                    .materialize()
                    .map { ($0, imageId) }
            }
            .map { event, imageId -> OWCommentImage? in
                switch event {
                case .next(let uploadResponse):
                    return OWCommentImage(
                        originalWidth: uploadResponse.width,
                        originalHeight: uploadResponse.height,
                        imageId: imageId
                    )
                case .error:
                    return nil
                default:
                    return nil
                }
            }
            .do(onNext: { [weak self] _ in
                guard let self else { return }
                self.imagePreviewVM.inputs.isUploadingImage.onNext(false)
            })
            .unwrap()

        imageContentObservable
            .subscribe(onNext: { [weak self] imageContent in
                guard let self else { return }
                self._imageContent.onNext(imageContent)
            })
            .disposed(by: uploadImageDisposeBag)

        gifPicked
            .do(onNext: { [weak self] _ in
                // Clean selected image
                self?.imagePreviewVM.inputs.removeButtonTap.onNext()
            })
            .bind(to: gifPreviewVM.inputs.gifData)
            .disposed(by: disposeBag)
    }
}
