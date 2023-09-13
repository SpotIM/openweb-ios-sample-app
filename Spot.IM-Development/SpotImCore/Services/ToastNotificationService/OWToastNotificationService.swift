//
//  OWToastNotificationService.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 12/09/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

protocol OWToastNotificationServicing {
    func showToast(presentData: OWToastNotificationPresentData)
    func clearNotifications()

    var toastToShow: Observable<OWToastNotificationPresentData?> { get }
}

class OWToastNotificationService: OWToastNotificationServicing {
    fileprivate let queue = OWQueue<OWToastNotificationPresentData>()
    fileprivate var blockerService: OWBlockerServicing = OWSharedServicesProvider.shared.blockerServicing() // TODO: di
    fileprivate var disposeBag: DisposeBag = DisposeBag()

    fileprivate var _toastToShow = BehaviorSubject<OWToastNotificationPresentData?>(value: nil)
    var toastToShow: Observable<OWToastNotificationPresentData?> {
        return _toastToShow
            .asObservable()
    }

    fileprivate var newToast = PublishSubject<Void>()
    fileprivate var newToastObservable: Observable<Void> {
        newToast
            .asObservable()
            .share()
    }

    init() {
        setupObservers()
    }

    func showToast(presentData: OWToastNotificationPresentData) {
        queue.insert(presentData)
        newToast.onNext()
    }

    func clearNotifications() {
        // TODO: should add to OWQueue?
        // Should be called when post changes
    }
}

fileprivate extension OWToastNotificationService {
    func sendToastToShow() { // TODO: rename
        guard !queue.isEmpty() else { return }
        print("NOGAH: sendToastToShow")
        let action = OWDefaultBlockerAction(blockerType: .toastNotification)
        blockerService.add(blocker: action)
        let toast = queue.popFirst()
        _toastToShow.onNext(toast)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 5) { [weak self] in // TODO: handle properly
            self?._toastToShow.onNext(nil)
            print("NOGAH: toast finish")
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 5) { [weak self] in // TODO: handle properly
                action.finish()
                print("NOGAH: action.finish()")
            }
        }
    }

    func setupObservers() {
        newToastObservable
            .flatMap { [weak self] _ -> Observable<Void> in
                guard let self = self else { return .empty() }
                return self.blockerService.waitForNonBlocker(for: [.toastNotification])
            }
            .debug("NOGAH: newToastObservable")
            .subscribe(onNext: { [weak self] in
                self?.sendToastToShow()
            })
            .disposed(by: disposeBag)
    }
}

enum OWToastNotificationDismissStrategy: Codable, Equatable {
    case byUser
    case time(durationMs: Double) // TODO: double?
}

struct OWToastNotificationPresentData: Codable, Equatable {
    let dismissStrategy: OWToastNotificationDismissStrategy
    let data: OWToastRequiredData
    // Show on specific view? all views??
}
