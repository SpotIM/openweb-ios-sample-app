//
//  OWOrientationService.swift
//  SpotImCore
//
//  Created by Revital Pisman on 21/11/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
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

    lazy var interfaceOrientationMask: UIInterfaceOrientationMask = {
        return orientationEnforcement.interfaceOrientationMask
    }()

    fileprivate var _viewableMode: OWViewableMode = .partOfFlow

    fileprivate var _orientation = BehaviorSubject<OWOrientation?>(value: nil)
    fileprivate var _currentOrientation: OWOrientation = .portrait
    fileprivate var _enforcement: OWOrientationEnforcement = .enableAll
    fileprivate let disposeBag = DisposeBag()

    fileprivate let notificationCenter: NotificationCenter
    fileprivate let uiDevice: UIDevice
    fileprivate let orientationEnforcement: OWOrientationEnforcement

    init(notificationCenter: NotificationCenter = NotificationCenter.default,
         uiDevice: UIDevice = UIDevice.current,
         orientationEnforcement: OWOrientationEnforcement = OWManager.manager.helpers.orientationEnforcement) {
        self.notificationCenter = notificationCenter
        self.uiDevice = uiDevice
        self.orientationEnforcement = orientationEnforcement

        setupObservers()
    }

    func set(viewableMode: OWViewableMode) {
        self._viewableMode = viewableMode
        self.updateOrientation()
    }
}

fileprivate extension OWOrientationService {

    func setupObservers() {
        orientation
            .subscribe(onNext: { [weak self] currentOrientation in
                self?._currentOrientation = currentOrientation
            })
            .disposed(by: disposeBag)

        self.updateOrientation()

        notificationCenter.rx.notification(UIDevice.orientationDidChangeNotification)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self._orientation.onNext(self.dictateSDKOrientation(currentDeviceOrientation: self.uiDevice.orientation))
            })
            .disposed(by: disposeBag)

        uiDevice.beginGeneratingDeviceOrientationNotifications()
    }

    func dictateSDKOrientation(currentDeviceOrientation: UIDeviceOrientation) -> OWOrientation {
        // At the momment in independent we desided to support only in portrait
        guard self._viewableMode != .independent else { return .portrait }

        let enforcedOrientation = self.interfaceOrientationMask

        switch enforcedOrientation {
        case .all:
            switch currentDeviceOrientation {
            case .portrait, .faceUp, .faceDown:
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
        _orientation.onNext(self.dictateSDKOrientation(currentDeviceOrientation: self.uiDevice.orientation))
    }
}
