//
//  OWOrientationService.swift
//  OpenWebSDK
//
//  Created by Revital Pisman on 21/11/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

protocol OWOrientationServicing {
    var orientation: Observable<OWOrientation> { get }
    var currentOrientation: OWOrientation { get }
    var interfaceOrientationMask: UIInterfaceOrientationMask { get }
    func set(viewableMode: OWViewableMode)
}

class OWOrientationService: OWOrientationServicing {

    lazy var orientation: Observable<OWOrientation> = {
        return _orientation
            .unwrap()
            .asObservable()
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .share(replay: 1)
    }()

    var currentOrientation: OWOrientation {
        return _currentOrientation
    }

    var interfaceOrientationMask: UIInterfaceOrientationMask {
        return OWManager.manager.helpers.orientationEnforcement.interfaceOrientationMask
    }

    private var _viewableMode: OWViewableMode = .partOfFlow

    private var _orientation = BehaviorSubject<OWOrientation?>(value: nil)
    private var _currentOrientation: OWOrientation = .portrait
    private var _enforcement: OWOrientationEnforcement = .enableAll
    private let disposeBag = DisposeBag()

    private let notificationCenter: NotificationCenter
    private let uiDevice: UIDevice

    init(notificationCenter: NotificationCenter = NotificationCenter.default,
         uiDevice: UIDevice = UIDevice.current) {
        self.notificationCenter = notificationCenter
        self.uiDevice = uiDevice

        setupObservers()
    }

    func set(viewableMode: OWViewableMode) {
        self._viewableMode = viewableMode
        self.updateOrientation()
    }
}

private extension OWOrientationService {

    func setupObservers() {
        orientation
            .subscribe(onNext: { [weak self] currentOrientation in
                self?._currentOrientation = currentOrientation
            })
            .disposed(by: disposeBag)

        self.updateOrientation()

        notificationCenter.rx.notification(UIDevice.orientationDidChangeNotification)
            .subscribe(onNext: { [weak self] _ in
                guard let self else { return }
                self._orientation.onNext(self.dictateSDKOrientation(currentDevice: self.uiDevice))
            })
            .disposed(by: disposeBag)

        uiDevice.beginGeneratingDeviceOrientationNotifications()
    }

    func dictateSDKOrientation(currentDevice: UIDevice) -> OWOrientation {
        // At the moment in independent/iPad we decided to support only in portrait
        guard self._viewableMode != .independent,
              currentDevice.userInterfaceIdiom != .pad else { return .portrait }

        // Determine allowed orientations from the application's supported orientations
        let isPortraitAllowed = UIApplication.shared.isPortraitAllowed
        let isLandscapeAllowed = UIApplication.shared.isLandscapeAllowed
        guard isPortraitAllowed && isLandscapeAllowed else {
            return isPortraitAllowed ? .portrait : .landscape
        }

        let enforcedOrientation = self.interfaceOrientationMask
        let currentDeviceOrientation = currentDevice.orientation

        switch enforcedOrientation {
        case .all:
            switch currentDeviceOrientation {
            case .portrait:
                return .portrait
            case .landscapeLeft, .landscapeRight, .portraitUpsideDown:
                return .landscape
            default:
                return currentOrientation
            }
        case .portrait:
            return .portrait
        case .landscape:
            return .landscape
        default:
            return currentOrientation
        }
    }

    func updateOrientation() {
        _orientation.onNext(self.dictateSDKOrientation(currentDevice: self.uiDevice))
    }
}
