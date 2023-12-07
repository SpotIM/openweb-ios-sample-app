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
}

class OWOrientationService: OWOrientationServicing {

    lazy var orientation: Observable<OWOrientation> = {
        return _orientation
            .asObservable()
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .share(replay: 1)
    }()

    var currentOrientation: OWOrientation {
        return _currentOrientation
    }

    fileprivate var _orientation = BehaviorSubject<OWOrientation>(value: .portrait)
    fileprivate var _currentOrientation: OWOrientation = .portrait
    fileprivate var _enforcement: OWOrientationEnforcement = .enableAll
    fileprivate let disposeBag = DisposeBag()

    init() {
        startMonitoring()
    }

    func startMonitoring() {
        if let currentOrientation = getOrientation() {
            _orientation.onNext(currentOrientation)
        }

        NotificationCenter.default.rx.notification(UIDevice.orientationDidChangeNotification)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                if let orientation = self.getOrientation() {
                    self._orientation.onNext(orientation)
                }
            })
            .disposed(by: disposeBag)

        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
    }

    func stopMonitoring() {
        UIDevice.current.endGeneratingDeviceOrientationNotifications()
    }
}

fileprivate extension OWOrientationService {

    func setupObservers() {
        orientation
            .subscribe(onNext: { [weak self] themeStyle in
                self?._currentOrientation = themeStyle
            })
            .disposed(by: disposeBag)
    }

    func getOrientation() -> OWOrientation? {
        switch OWManager.manager.helpers.orientationEnforcement.interfaceOrientationMask {
        case .all:
            switch UIDevice.current.orientation {
                case .portrait:
                    return .portrait
                case .landscapeLeft, .landscapeRight, .portraitUpsideDown:
                    return .landscape
                default:
                    return nil // Or handle unknown orientations if needed
            }

        case .portrait:
            return .portrait

        case .landscape:
            return .landscape

        default:
            return nil
        }
    }
}
