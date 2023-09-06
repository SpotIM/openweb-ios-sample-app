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
    var commentingReadOnlyViewModel: OWCommentingReadOnlyViewModeling { get }
    var shouldShowSkelaton: Observable<Bool> { get }
    var style: Observable<OWCommentingCTAStyle> { get }
    var shouldShowCommentCreationEntry: Observable<Bool> { get }
    var shouldShowCommentingReadOnly: Observable<Bool> { get }
    var openProfile: Observable<OWOpenProfileData> { get }
    var commentCreationTapped: Observable<Void> { get }
    var shouldShowView: Observable<Bool> { get }
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

    lazy var commentingReadOnlyViewModel: OWCommentingReadOnlyViewModeling = {
        return OWCommentingReadOnlyViewModel()
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

    var _shouldShowView = BehaviorSubject<Bool?>(value: nil)
    var shouldShowView: Observable<Bool> {
        _shouldShowView
            .unwrap()
            .asObservable()
            .share(replay: 0)
    }

    fileprivate let _openProfile = PublishSubject<OWOpenProfileData>()
    var openProfile: Observable<OWOpenProfileData> {
        _openProfile
            .asObservable()
    }

    fileprivate let _commentCreationTap = PublishSubject<Void>()
    var commentCreationTapped: Observable<Void> {
        _commentCreationTap
            .asObserver()
    }

    fileprivate let imageProvider: OWImageProviding
    fileprivate let servicesProvider: OWSharedServicesProviding
    fileprivate let disposeBag = DisposeBag()

    init(imageProvider: OWImageProviding = OWCloudinaryImageProvider(),
         servicesProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared) {
        self.imageProvider = imageProvider
        self.servicesProvider = servicesProvider
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
                self._shouldShowView.onNext(true)
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
            .bind(to: _openProfile)
            .disposed(by: disposeBag)
    }
}
