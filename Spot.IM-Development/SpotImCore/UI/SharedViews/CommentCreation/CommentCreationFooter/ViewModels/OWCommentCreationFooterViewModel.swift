//
//  OWCommentCreationFooterViewModel.swift
//  SpotImCore
//
//  Created by Alon Shprung on 18/06/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

protocol OWCommentCreationFooterViewModelingInputs {
    var tapCta: PublishSubject<Void> { get }
    var tapAction: PublishSubject<Void> { get }
    var ctaEnabled: BehaviorSubject<Bool> { get }
}

protocol OWCommentCreationFooterViewModelingOutputs {
    var ctaTitleText: Observable<String> { get }
    var ctaButtonEnabled: Observable<Bool> { get }
    var showAddImageButton: Observable<Bool> { get }
    var performCtaAction: Observable<Void> { get }
    var loginToPostClick: Observable<Void> { get }
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

    fileprivate let servicesProvider: OWSharedServicesProviding
    fileprivate let commentCreationType: OWCommentCreationTypeInternal

    var tapCta = PublishSubject<Void>()
    var tapAction = PublishSubject<Void>()

    fileprivate lazy var _shouldSignUpToPostComment: Observable<Bool> = {
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
            .flatMap { [weak self] _ -> Observable<Bool> in
                guard let self = self else { return .empty() }
                return self.servicesProvider.authenticationManager().ifNeededTriggerAuthenticationUI(for: .commenting)
            }
            .do(onNext: { [weak self] loginToPost in
                guard let self = self,
                      loginToPost == true else { return }
                self._loginToPostClick.onNext()
            })
            .filter { !$0 } // Do not continue if authentication needed
            .map { _ -> Void in () }
    }

    var ctaEnabled = BehaviorSubject<Bool>(value: false)

    var ctaTitleText: Observable<String> {
        _shouldSignUpToPostComment
            .map { [weak self] shouldSignUpToPost in
                guard let self = self, !shouldSignUpToPost else {
                    return OWLocalizationManager.shared.localizedString(key: "Sign Up to Post")
                }

                if case .edit = self.commentCreationType {
                    return OWLocalizationManager.shared.localizedString(key: "Edit")
                } else {
                    return OWLocalizationManager.shared.localizedString(key: "Post")
                }
            }
    }

    var ctaButtonEnabled: Observable<Bool> {
        return ctaEnabled
            .asObservable()
    }

    var showAddImageButton: Observable<Bool> {
        // TODO - Support adding an image
        return Observable.just(false)
    }

    init(commentCreationType: OWCommentCreationTypeInternal,
         servicesProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared) {
        self.servicesProvider = servicesProvider
        self.commentCreationType = commentCreationType

        setupObservers()
    }
}

fileprivate extension OWCommentCreationFooterViewModel {
    func setupObservers() {

    }
}
