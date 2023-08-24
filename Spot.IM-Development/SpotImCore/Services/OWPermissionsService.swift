//
//  OWPermissionsService.swift
//  SpotImCore
//
//  Created by Alon Shprung on 15/08/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift
import UIKit
import AVFoundation

protocol OWPermissionsServicing {
    func requestPermission(for type: OWPermissionsService.PermissionType, viewableMode: OWViewableMode) -> Observable<Bool>
    func hasInfoPlistContainRequiredDescription(for type: OWPermissionsService.PermissionType) -> Bool
}

class OWPermissionsService: OWPermissionsServicing {
    enum PermissionType {
        case camera
    }

    fileprivate unowned let servicesProvider: OWSharedServicesProviding
    fileprivate let disposeBag = DisposeBag()

    init(servicesProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared) {
        self.servicesProvider = servicesProvider
    }

    func requestPermission(for type: PermissionType, viewableMode: OWViewableMode) -> Observable<Bool> {
        return Observable.create { observer in
            let onResult: (Bool) -> Void = { isAuthorezied in
                observer.onNext(isAuthorezied)
                observer.onCompleted()
            }

            switch type {
            case .camera:
                self.requestCameraPermission(result: onResult, viewableMode: viewableMode)
            }

            return Disposables.create()
        }
    }

    func hasInfoPlistContainRequiredDescription(for type: PermissionType) -> Bool {
        switch type {
        case .camera:
            let hasRequiredDescription = Bundle.main.hasCameraUsageDescription && Bundle.main.hasPhotoLibraryUsageDescription
            if (!hasRequiredDescription) {
                let message = "Can't show add image button, make sure you have set NSCameraUsageDescription and NSPhotoLibraryUsageDescription in your info.plist file"
                self.servicesProvider
                    .logger()
                    .log(level: .error, message)
            }
            return hasRequiredDescription
        }
    }
}

fileprivate extension OWPermissionsService {
    func openAppSettings() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(settingsUrl)
    }

    func handlePermissionDenied(for type: PermissionType, viewableMode: OWViewableMode) {
        let actions = [
            OWRxPresenterAction(title: OWLocalizationManager.shared.localizedString(key: "Cancel"), type: OWOpenSettingsAlert.cancel),
            OWRxPresenterAction(title: OWLocalizationManager.shared.localizedString(key: "Open settings"), type: OWOpenSettingsAlert.openSettings)
        ]

        self.servicesProvider
            .presenterService()
            .showAlert(
                title: "",
                message: getPermissionDeniedMessage(for: type),
                actions: actions,
                viewableMode: viewableMode
            )
            .subscribe(onNext: { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .completion:
                    break
                case .selected(action: let action):
                    if case OWOpenSettingsAlert.openSettings = action.type {
                        self.openAppSettings()
                    }
                }
            })
            .disposed(by: disposeBag)
    }

    func getPermissionDeniedMessage(for type: PermissionType) -> String {
        switch type {
        case .camera:
            return OWLocalizationManager.shared.localizedString(key: "CameraPermissionsAreNeeded")
        }
    }
}

// Camera
fileprivate extension OWPermissionsService {
    func requestCameraPermission(result: @escaping (Bool) -> Void, viewableMode: OWViewableMode) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            result(true)

        case .denied:
            handlePermissionDenied(for: .camera, viewableMode: viewableMode)
            result(false)

        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted { // access allowed
                    result(true)
                } else { // access denied
                    result(false)
                }
            }

        default:
            result(false)
            break
        }
    }
}
