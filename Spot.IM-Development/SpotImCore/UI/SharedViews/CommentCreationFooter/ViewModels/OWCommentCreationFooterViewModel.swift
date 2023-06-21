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

    var ctaEnabled = BehaviorSubject<Bool>(value: false)

    var ctaTitleText: Observable<String> {
        _shouldSignUpToPostComment
            .map { shouldSignUpToPost in
                return shouldSignUpToPost ? OWLocalizationManager.shared.localizedString(key: "Sign Up to Post") : OWLocalizationManager.shared.localizedString(key: "Post")
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

    init(servicesProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared) {
        self.servicesProvider = servicesProvider
    }
}
