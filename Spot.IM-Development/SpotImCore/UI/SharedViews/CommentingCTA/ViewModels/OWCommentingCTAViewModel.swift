//
//  OWCommentingCTAViewModel.swift
//  SpotImCore
//
//  Created by Revital Pisman on 07/05/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

protocol OWCommentingCTAViewModelingInputs {
    var isReadOnly: PublishSubject<Bool> { get }
}

protocol OWCommentingCTAViewModelingOutputs {
    var commentCreationEntryViewModel: OWCommentCreationEntryViewModeling { get }
    var shouldShowSkelaton: Observable<Bool> { get }
    var style: Observable<OWCommentingCTAStyle> { get }
    var shouldShowCommentCreationEntry: Observable<Bool> { get }
    var shouldShowCommentingReadOnly: Observable<Bool> { get }
    var openProfile: Observable<URL> { get }
    var commentCreationTapped: Observable<Void> { get }
    var openPublisherProfile: Observable<String> { get }
}

protocol OWCommentingCTAViewModeling {
    var inputs: OWCommentingCTAViewModelingInputs { get }
    var outputs: OWCommentingCTAViewModelingOutputs { get }
}

class OWCommentingCTAViewModel: OWCommentingCTAViewModeling,
                                OWCommentingCTAViewModelingInputs,
                                OWCommentingCTAViewModelingOutputs {

    var inputs: OWCommentingCTAViewModelingInputs { return self }
    var outputs: OWCommentingCTAViewModelingOutputs { return self }

    var isReadOnly = PublishSubject<Bool>()
    fileprivate let _style = BehaviorSubject<OWCommentingCTAStyle>(value: .skelaton)
    lazy var style: Observable<OWCommentingCTAStyle> = {
        return _style
            .skip(1)
            .asObservable()
    }()

    lazy var commentCreationEntryViewModel: OWCommentCreationEntryViewModeling = {
        return OWCommentCreationEntryViewModel(imageURLProvider: imageProvider)
    }()

    lazy var shouldShowSkelaton: Observable<Bool> = {
        style
            .map { type in
                if case .skelaton = type {
                    return false
                }
                return true
            }
            .asObservable()
    }()

    lazy var shouldShowCommentCreationEntry: Observable<Bool> = {
        style
            .map { type in
                if case .cta = type {
                    return true
                }
                return false
            }
            .asObservable()
    }()

    lazy var shouldShowCommentingReadOnly: Observable<Bool> = {
        style
            .map { type in
                if case .conversationEnded = type {
                    return true
                }
                return false
            }
            .asObservable()
    }()

    fileprivate let _openProfile = PublishSubject<URL>()
    var openProfile: Observable<URL> {
        _openProfile
            .asObserver()
    }

    fileprivate let _openPublisherProfile = PublishSubject<String>()
    var openPublisherProfile: Observable<String> {
        _openPublisherProfile
            .asObserver()
    }

    fileprivate let _commentCreationTap = PublishSubject<Void>()
    var commentCreationTapped: Observable<Void> {
        _commentCreationTap
            .asObserver()
    }

    fileprivate let imageProvider: OWImageProviding
    fileprivate let disposeBag = DisposeBag()

    init(imageProvider: OWImageProviding = OWCloudinaryImageProvider()) {
        self.imageProvider = imageProvider
        setupObservers()
    }
}

fileprivate extension OWCommentingCTAViewModel {
    func setupObservers() {
        isReadOnly
            .map { isReadOnly -> OWCommentingCTAStyle in
                return isReadOnly ? .conversationEnded : .cta
            }
            .subscribe(onNext: { [weak self] style in
                guard let self = self else { return }
                self._style.onNext(style)
            })
            .disposed(by: disposeBag)

        commentCreationEntryViewModel.outputs.tapped
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self._commentCreationTap.onNext()
            })
            .disposed(by: disposeBag)

        // Responding to comment creation entry avatar click
        commentCreationEntryViewModel
            .outputs
            .avatarViewVM
            .outputs
            .openProfile
            .subscribe(onNext: { [weak self] url in
                guard let self = self else { return }
                self._openProfile.onNext(url)
            })
            .disposed(by: disposeBag)

        // Responding to open publisher profile
        commentCreationEntryViewModel
            .outputs
            .avatarViewVM
            .outputs
            .openPublisherProfile
            .subscribe(onNext: { [weak self] id in
                guard let self = self else { return }
                self._openPublisherProfile.onNext(id)
            })
            .disposed(by: disposeBag)
    }
}
