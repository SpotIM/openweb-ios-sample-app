//
//  OWCommentCreationImagePreviewViewModel.swift
//  SpotImCore
//
//  Created by Alon Shprung on 20/08/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

protocol OWCommentCreationImagePreviewViewModelingInputs {
    var image: PublishSubject<UIImage> { get }
    var isUploadingImage: BehaviorSubject<Bool> { get }
    var removeButtonTap: PublishSubject<Void> { get }
}

protocol OWCommentCreationImagePreviewViewModelingOutputs {
    var imageOutput: Observable<UIImage> { get }
    var shouldShowView: Observable<Bool> { get }
    var isUploadingImageObservable: Observable<Bool> { get }
    var shouldShowLoadingState: Observable<Bool> { get }
    var removeButtonTapped: Observable<Void> { get }
}

protocol OWCommentCreationImagePreviewViewModeling {
    var inputs: OWCommentCreationImagePreviewViewModelingInputs { get }
    var outputs: OWCommentCreationImagePreviewViewModelingOutputs { get }
}

class OWCommentCreationImagePreviewViewModel: OWCommentCreationImagePreviewViewModeling,
                                              OWCommentCreationImagePreviewViewModelingInputs,
                                              OWCommentCreationImagePreviewViewModelingOutputs {

    var inputs: OWCommentCreationImagePreviewViewModelingInputs { return self }
    var outputs: OWCommentCreationImagePreviewViewModelingOutputs { return self }

    fileprivate let disposeBag = DisposeBag()
    fileprivate let servicesProvider: OWSharedServicesProviding

    var removeButtonTap: PublishSubject<Void> = PublishSubject()
    var isUploadingImage: BehaviorSubject<Bool> = BehaviorSubject(value: false)
    var image: PublishSubject<UIImage> = PublishSubject()
    var _image: BehaviorSubject<UIImage?> = BehaviorSubject(value: nil)

    var imageOutput: Observable<UIImage> {
        _image
            .unwrap()
            .asObservable()
    }

    var shouldShowView: Observable<Bool> {
        _image
            .map { $0 != nil }
    }

    var shouldShowLoadingState: Observable<Bool> {
        isUploadingImage
            .asObservable()
    }

    var isUploadingImageObservable: Observable<Bool> {
        isUploadingImage
            .asObservable()
    }

    var removeButtonTapped: Observable<Void> {
        removeButtonTap
            .asObservable()
    }

    init(servicesProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared) {
        self.servicesProvider = servicesProvider

        setupObservers()
    }
}

fileprivate extension OWCommentCreationImagePreviewViewModel {
    func setupObservers() {
        image
            .subscribe(onNext: { [weak self] image in
                guard let self = self else { return }
                self._image.onNext(image)
            })
            .disposed(by: disposeBag)

        removeButtonTap.subscribe(onNext: { [weak self] _ in
            guard let self = self else { return }
            self._image.onNext(nil)
        })
        .disposed(by: disposeBag)
    }
}

