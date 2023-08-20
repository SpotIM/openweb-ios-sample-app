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
    var tapAddImage: PublishSubject<Void> { get }
    var ctaEnabled: BehaviorSubject<Bool> { get }
}

protocol OWCommentCreationFooterViewModelingOutputs {
    var ctaTitleText: Observable<String> { get }
    var ctaButtonEnabled: Observable<Bool> { get }
    var showAddImageButton: Observable<Bool> { get }
    var performCtaAction: Observable<Void> { get }
    var imagePicked: Observable<UIImage> { get }
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
    fileprivate let disposeBag = DisposeBag()
    fileprivate let viewableMode: OWViewableMode
    fileprivate let commentCreationType: OWCommentCreationTypeInternal

    var tapCta = PublishSubject<Void>()
    var tapAddImage = PublishSubject<Void>()

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

    var performCtaAction: Observable<Void> {
        tapCta
            .asObservable()
            .flatMap { [weak self] _ -> Observable<Bool> in
                guard let self = self else { return .empty() }
                return self.servicesProvider.authenticationManager().ifNeededTriggerAuthenticationUI(for: .commenting)
            }
            .filter { !$0 } // Do not continue if needed to authenticate
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
        guard self.servicesProvider.permissionsService().hasRequiredFieldsInInfoPlist(for: .camera) else {
            return Observable.just(false)
        }
        return self.servicesProvider.spotConfigurationService().config(spotId: OWManager.manager.spotId)
            .map {
                $0.conversation?.disableImageUploadButton != true
            }
    }

    var imagePicked: Observable<UIImage> {
        tapAddImage
            .flatMap { [weak self] _ -> Observable<Bool> in
                guard let self = self else { return Observable.just(false) }
                return self.servicesProvider
                    .permissionsService()
                    .requestPermission(for: .camera, viewableMode: self.viewableMode)
            }
            .filter { $0 == true }
            .voidify()
            .flatMap { [weak self] _ -> Observable<OWRxPresenterResponseType> in
                guard let self = self else { return .empty() }

                let actions = [
                    OWRxPresenterAction(title: OWLocalizationManager.shared.localizedString(key: "Take a Photo"), type: OWPickImageActionSheet.takePhoto),
                    OWRxPresenterAction(title: OWLocalizationManager.shared.localizedString(key: "Choose from Gallery"), type: OWPickImageActionSheet.chooseFromGallery),
                    OWRxPresenterAction(title: OWLocalizationManager.shared.localizedString(key: "Cancel"), type: OWPickImageActionSheet.cancel, style: .cancel)
                ]
                return self.servicesProvider
                    .presenterService()
                    .showAlert(
                        title: nil,
                        message: nil,
                        actions: actions,
                        preferredStyle: .actionSheet,
                        viewableMode: viewableMode
                    )
            }
            .map { response -> UIImagePickerController.SourceType? in
                switch response {
                case .completion:
                    return nil
                case .selected(let action):
                    switch action.type {
                    case OWPickImageActionSheet.takePhoto:
                        return .camera
                    case OWPickImageActionSheet.chooseFromGallery:
                        return .photoLibrary
                    default:
                        return nil
                    }
                }
            }
            .unwrap()
            .flatMap { [weak self] sourceType -> Observable<OWImagePickerPresenterResponseType> in
                guard let self = self else { return .empty() }
                return self.servicesProvider
                    .presenterService()
                    .showImagePicker(mediaTypes: ["public.image"], sourceType: sourceType, viewableMode: viewableMode)
            }
            .map { response -> UIImage? in
                switch response {
                case .cancled:
                    return nil
                case .mediaInfo(let dictionary):
                    guard let image = dictionary[.originalImage] as? UIImage else {
                        return nil
                    }
                    return image
                }
            }
            .unwrap()
    }

    init(commentCreationType: OWCommentCreationTypeInternal,
         servicesProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared,
         viewableMode: OWViewableMode) {
        self.servicesProvider = servicesProvider
        self.commentCreationType = commentCreationType
        self.viewableMode = viewableMode

        setupObservers()
    }
}

fileprivate extension OWCommentCreationFooterViewModel {
    func setupObservers() {
    }
}
