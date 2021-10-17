//
//  SPPermissionsProvider.swift
//  SpotImCore
//
//  Created by Alon Shprung on 05/10/2021.
//  Copyright © 2021 Spot.IM. All rights reserved.
//

import AVKit

enum SPPermissionType {
    case camera
}

protocol SPPermissionsProviderDelegate: AnyObject {
    func presentAlert(_ alert: UIAlertController)
}

internal final class SPPermissionsProvider {
    
    internal weak static var delegate: SPPermissionsProviderDelegate?
    
    static func requestPermission(type: SPPermissionType, onAuthorized: @escaping () -> Void) {
        switch type {
        case .camera:
            return requestCameraPermission(onAuthorized: onAuthorized)
        }
    }
    
    private static func openAppSettings() {
        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
    }
    
    private static func getPermissionDeniedMessage(type: SPPermissionType) -> String {
        switch type {
        case .camera:
            return LocalizationManager.localizedString(key: "Camera permissions are needed")
        }
    }
    
    private static func handlePermissionDenied(type: SPPermissionType) {
        let alert = UIAlertController(title: nil, message: getPermissionDeniedMessage(type: type), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: LocalizationManager.localizedString(key: "Cancel"), style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: LocalizationManager.localizedString(key: "Open settings"), style: .default, handler: { _ in
            openAppSettings()
        }))
        
        delegate?.presentAlert(alert)
    }
    
    private static func requestCameraPermission(onAuthorized: @escaping () -> Void) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            onAuthorized()
            break
        case .denied:
            handlePermissionDenied(type: .camera)
            break
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { (granted: Bool) in
                if granted { //access allowed
                    onAuthorized()
                } else { //access denied
                    // TODO - Do something?
                }
            })
            break
        default:
            break
        }
    }
}
