//
//  OWCommentCreationFooterViewModel.swift
//  OpenWebSDK
//
//  Created by Alon Shprung on 18/06/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

protocol OWCommentCreationFooterViewModelingInputs {
    var tapCta: PublishSubject<Void> { get }
    var tapAddImage: PublishSubject<Void> { get }
    var tapAddGif: PublishSubject<Void> { get }
    var ctaEnabled: BehaviorSubject<Bool> { get }
    var submitCommentInProgress: BehaviorSubject<Bool> { get }
    var triggerCustomizeSubmitButtonUI: PublishSubject<UIButton> { get }
}

protocol OWCommentCreationFooterViewModelingOutputs {
    var ctaTitleText: Observable<String> { get }
    var ctaButtonEnabled: Observable<Bool> { get }
    var ctaButtonLoading: Observable<Bool> { get }
    var showAddImageButton: Observable<Bool> { get }
    var showAddGifButton: Observable<Bool> { get }
    var performCtaAction: Observable<Void> { get }
    var addImageTapped: Observable<Void> { get }
    var addGifTapped: Observable<Void> { get }
    var loginToPostClick: Observable<Void> { get }
    var customizeSubmitButtonUI: Observable<UIButton> { get }
}

protocol OWCommentCreationFooterViewModeling {
    var inputs: OWCommentCreationFooterViewModelingInputs { get }
    var outputs: OWCommentCreationFooterViewModelingOutputs { get }
}

class OWCommentCreationFooterViewModel: OWCommentCreationFooterViewModeling,
                                        OWCommentCreationFooterViewModelingInputs,
                                        OWCommentCreationFooterViewModelingOutputs {

    var inputs: OWCommentCreationFooterViewModelingInputs { return self }
    var outputs: OWCommentCreationFooterViewModelingOutputs { return self }

    private let commentCreationFooterScheduler: SchedulerType = SerialDispatchQueueScheduler(qos: .userInteractive, internalSerialQueueName: "OpenWebSDKCommentCreationFooterQueue")

    private let servicesProvider: OWSharedServicesProviding
    private let disposeBag = DisposeBag()
    private let commentCreationType: OWCommentCreationTypeInternal

    var tapCta = PublishSubject<Void>()
    var tapAddImage = PublishSubject<Void>()
    var tapAddGif = PublishSubject<Void>()

    private let _triggerCustomizeSubmitButtonUI = BehaviorSubject<UIButton?>(value: nil)
    var triggerCustomizeSubmitButtonUI = PublishSubject<UIButton>()

    var customizeSubmitButtonUI: Observable<UIButton> {
        return _triggerCustomizeSubmitButtonUI
            .unwrap()
            .asObservable()
    }

    var addImageTapped: Observable<Void> {
        tapAddImage
            .asObservable()
    }

    var addGifTapped: Observable<Void> {
        tapAddGif
            .asObservable()
    }

    private lazy var _shouldSignUpToPostComment: Observable<Bool> = {
        return Observable.combineLatest(
            servicesProvider.authenticationManager().activeUserAvailability,
            servicesProvider.spotConfigurationService().config(spotId: OWManager.manager.spotId)
        ) { availability, config in
            guard let initializationConfig = config.initialization,
                  initializationConfig.policyForceRegister == true else {
                return false
            }
            switch availability {
            case .user(let user):
                return !user.registered
            default:
                return true
            }
        }
    }()

    var _loginToPostClick = PublishSubject<Void>()
    var loginToPostClick: Observable<Void> {
        _loginToPostClick
            .asObservable()
    }

    var performCtaAction: Observable<Void> {
        tapCta
            .asObservable()
            .map { [weak self] _ -> OWUserAction? in
                guard let self else { return nil }
                switch self.commentCreationType {
                case .comment:
                    return .commenting
                case .replyToComment:
                    return .replyingComment
                case .edit:
                    return .editingComment
                }
            }
            .unwrap()
            .observe(on: commentCreationFooterScheduler)
            .do(onNext: { [weak self] _ in
                // Disable post button while checking ifNeededTriggerAuthenticationUI to prevent multiple taps.
                // This prevents multiple authentication screens being opened after tapping a few times on the post button.
                self?.submitCommentInProgress.onNext(true)
            })
            .observe(on: MainScheduler.instance)
            .flatMap { [weak self] userAction -> Observable<Bool> in
                guard let self else { return .empty() }
                return self.servicesProvider.authenticationManager().ifNeededTriggerAuthenticationUI(for: userAction)
            }
            .do(onNext: { [weak self] _ in
                self?.submitCommentInProgress.onNext(false)
            })
            .do(onNext: { [weak self] loginToPost in
                guard let self,
                      loginToPost == true else { return }
                self._loginToPostClick.onNext()
            })
            .filter { !$0 } // Do not continue if authentication needed
            .map { _ in () }
    }

    var ctaEnabled = BehaviorSubject<Bool>(value: false)

    var ctaTitleText: Observable<String> {
        _shouldSignUpToPostComment
            .map { [weak self] shouldSignUpToPost in
                guard let self, !shouldSignUpToPost else {
                    return OWLocalize.string("SignUpToPost")
                }

                if case .edit = self.commentCreationType {
                    return OWLocalize.string("Update")
                } else {
                    return OWLocalize.string("Post")
                }
            }
    }

    var ctaButtonEnabled: Observable<Bool> {
        Observable.combineLatest(ctaEnabled, submitCommentInProgress) { ctaEnabled, submitCommentInProgress in
            return ctaEnabled && !submitCommentInProgress
        }
    }

    var submitCommentInProgress = BehaviorSubject<Bool>(value: false)
    var ctaButtonLoading: Observable<Bool> {
        submitCommentInProgress
            .asObservable()
    }

    var showAddImageButton: Observable<Bool> {
        guard self.servicesProvider.permissionsService().hasInfoPlistContainRequiredDescription(for: .camera) else {
            return Observable.just(false)
        }
        return self.servicesProvider.spotConfigurationService().config(spotId: OWManager.manager.spotId)
            .map {
                $0.conversation?.disableImageUploadButton != true
            }
    }

    var showAddGifButton: Observable<Bool> {
        return self.servicesProvider.spotConfigurationService().config(spotId: OWManager.manager.spotId)
            .map { [weak self] in
                guard let gifService = self?.servicesProvider.gifService(),
                      gifService.isGiphyAvailable else {
                    return false
                }

                return $0.mobileSdk.postGifEnabled
            }
    }

    init(commentCreationType: OWCommentCreationTypeInternal,
         servicesProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared) {
        self.servicesProvider = servicesProvider
        self.commentCreationType = commentCreationType

        setupObservers()
    }
}

private extension OWCommentCreationFooterViewModel {
    func setupObservers() {
        // UI customizations
        triggerCustomizeSubmitButtonUI
            .bind(to: _triggerCustomizeSubmitButtonUI)
            .disposed(by: disposeBag)
    }
}
