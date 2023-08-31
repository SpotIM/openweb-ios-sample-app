//
//  OWCommentCreationContentViewModel.swift
//  SpotImCore
//
//  Created by Alon Shprung on 03/07/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

protocol OWCommentCreationContentViewModelingInputs {
    var commentText: BehaviorSubject<String> { get }
    var becomeFirstResponder: PublishSubject<Void> { get }
    var resignFirstResponder: PublishSubject<Void> { get }
    var imagePicked: PublishSubject<UIImage> { get }
}

protocol OWCommentCreationContentViewModelingOutputs {
    var commentTextOutput: Observable<String> { get }
    var showPlaceholder: Observable<Bool> { get }
    var avatarViewVM: OWAvatarViewModeling { get }
    var placeholderText: Observable<String> { get }
    var becomeFirstResponderCalled: Observable<Void> { get }
    var resignFirstResponderCalled: Observable<Void> { get }
    var imagePreviewVM: OWCommentCreationImagePreviewViewModeling { get }
    var commentContent: Observable<OWCommentCreationContent> { get }
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

    fileprivate let disposeBag = DisposeBag()
    fileprivate var uploadImageDisposeBag = DisposeBag()
    fileprivate let imageURLProvider: OWImageProviding
    fileprivate let servicesProvider: OWSharedServicesProviding
    fileprivate let commentCreationType: OWCommentCreationTypeInternal

    fileprivate lazy var postId = OWManager.manager.postId

    var commentText = BehaviorSubject<String>(value: "")
    var imagePicked = PublishSubject<UIImage>()

    fileprivate let _imageContent = BehaviorSubject<OWCommentImage?>(value: nil)

    var commentContent: Observable<OWCommentCreationContent> {
        Observable.combineLatest(commentTextOutput, _imageContent.asObservable())
            .map { text, image in
                OWCommentCreationContent(text: text, image: image)
            }
    }

    lazy var imagePreviewVM: OWCommentCreationImagePreviewViewModeling = {
        return OWCommentCreationImagePreviewViewModel(servicesProvider: servicesProvider)
    }()

    lazy var avatarViewVM: OWAvatarViewModeling = {
        OWAvatarViewModel(imageURLProvider: imageURLProvider)
    }()

    fileprivate lazy var _commentTextCharactersLimit: Observable<Int?> = {
        return servicesProvider.spotConfigurationService().config(spotId: OWManager.manager.spotId)
            .map { config -> Int? in
                guard config.mobileSdk.shouldShowCommentCounter else { return nil }
                return config.mobileSdk.commentCounterCharactersLimit
            }
    }()

    var commentTextOutput: Observable<String> {
        commentText
            .asObservable()
            .withLatestFrom(_commentTextCharactersLimit) { ($0, $1) }
            .scan(("", nil)) { [weak self] previous, newTuple -> (String, Int?) in
                // Handle characters limit for comment text
                guard let self = self else { return previous }
                guard let limiter = newTuple.1 else { return newTuple }
                let previousText = previous.0
                let newText = newTuple.0

                let adjustedText = self.textValidatorTransformer(previousText: previousText, newText: newText, charactersLimiter: limiter)
                return (adjustedText, limiter)
            }
            .map { $0.0 }
    }

    var showPlaceholder: Observable<Bool> {
        commentTextOutput
            .map { $0.count == 0 }
    }

    var placeholderText: Observable<String> {
        switch commentCreationType {
        case .replyToComment:
            return Observable.just(OWLocalizationManager.shared.localizedString(key: "Type your reply…"))
        default:
            return Observable.just(OWLocalizationManager.shared.localizedString(key: "WhatDoYouThink"))
        }
    }

    var becomeFirstResponder = PublishSubject<Void>()
    var becomeFirstResponderCalled: Observable<Void> {
        return becomeFirstResponder
            .asObservable()
    }

    var resignFirstResponder = PublishSubject<Void>()
    var resignFirstResponderCalled: Observable<Void> {
        return resignFirstResponder
            .asObservable()
    }

    init(commentCreationType: OWCommentCreationTypeInternal,
         servicesProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared,
         imageURLProvider: OWImageProviding = OWCloudinaryImageProvider()) {
        self.servicesProvider = servicesProvider
        self.imageURLProvider = imageURLProvider
        self.commentCreationType = commentCreationType

        self.setupInitialTextIfNeeded()
        self.setupInitialImageIfNeeded()

        setupObservers()
    }
}

fileprivate extension OWCommentCreationContentViewModel {
    func setupInitialTextIfNeeded() {
        let commentsCacheService = self.servicesProvider.commentsInMemoryCacheService()
        var initialText: String? = nil
        switch commentCreationType {
        case .comment:
            guard let postId = self.postId else { return }
            initialText = commentsCacheService[.comment(postId: postId)]
        case .replyToComment(originComment: let originComment):
            guard let postId = self.postId,
                  let originCommentId = originComment.id
            else { return }
            initialText = commentsCacheService[.reply(postId: postId, commentId: originCommentId)]
        case .edit(comment: let comment):
            if let commentText = comment.text?.text {
                initialText = commentText
            }
        }

        if let text = initialText {
            self.inputs.commentText.onNext(text)
        }
    }

    func setupInitialImageIfNeeded() {
        if case let .edit(comment) = commentCreationType,
           let imageContent = comment.image {
            Observable.just(())
                .do(onNext: { [weak self] _ in
                    // Set a placeholder
                    guard let self = self else { return }
                    if let placeholder = UIImage(spNamed: "imageMediaPlaceholder", supportDarkMode: false) {
                        self.imagePreviewVM.inputs.image.onNext(placeholder)
                    }
                })
                .flatMap { [weak self] _ -> Observable<URL?> in
                    guard let self = self else { return .empty() }
                    return self.imageURLProvider.imageURL(with: imageContent.imageId, size: nil)
                }
                .unwrap()
                .observe(on: MainScheduler.instance)
                .flatMap { imageUrl -> Observable<UIImage> in
                    return UIImage.load(with: imageUrl)
                }
                // we added delay to fix a case we showed empty image
                .delay(.milliseconds(50), scheduler: ConcurrentDispatchQueueScheduler(qos: .userInteractive))
                .subscribe(onNext: { [weak self] image in
                    guard let self = self else { return }
                    self.imagePreviewVM.inputs.image.onNext(image)
                    self._imageContent.onNext(imageContent)
                })
                .disposed(by: disposeBag)
        }
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
                guard let self = self else { return }
                switch (availability) {
                case .notAvailable:
                    self.avatarViewVM.inputs.userInput.onNext(nil)
                case .user(let user):
                    self.avatarViewVM.inputs.userInput.onNext(user)
                }
            })
            .disposed(by: disposeBag)

        self.imagePreviewVM.outputs.removeButtonTapped
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.uploadImageDisposeBag = DisposeBag()
                self.setupImageObserver()
                self._imageContent.onNext(nil)
            })
            .disposed(by: disposeBag)
    }

    func setupImageObserver() {
        let imageWithCloudinarySignatureObservable = imagePicked
            .do(onNext: { [weak self] image in
                guard let self = self else { return }
                self._imageContent.onNext(nil)
                self.imagePreviewVM.inputs.image.onNext(image)
                self.imagePreviewVM.inputs.isUploadingImage.onNext(true)
            })
            .flatMapLatest { [weak self] image -> Observable<(Event<SPSignResponse>, UIImage, String, String)> in
                guard let self = self else { return .empty() }
                let imageId = UUID().uuidString
                let timestamp = String(format: "%.3f", NSDate().timeIntervalSince1970)
                return self.servicesProvider
                    .netwokAPI()
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
                case .error(_):
                    return nil
                default:
                    return nil
                }
            }
            .unwrap()

        let imageContentObservable = imageWithCloudinarySignatureObservable
            .flatMapLatest { [weak self] cloudinarySignature, image, imageId, timestamp -> Observable<(Event<OWUploadImageResponse>, String)> in
                guard let self = self,
                      let imageData = image.jpegData(compressionQuality: 1.0)?.base64EncodedString()
                else { return .empty() }
                return self.servicesProvider
                    .netwokAPI()
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
                case .error(_):
                    return nil
                default:
                    return nil
                }
            }
            .do(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.imagePreviewVM.inputs.isUploadingImage.onNext(false)
            })
            .unwrap()

        imageContentObservable
            .subscribe(onNext: { [weak self] imageContent in
                guard let self = self else { return }
                self._imageContent.onNext(imageContent)
            })
            .disposed(by: uploadImageDisposeBag)
    }
}

