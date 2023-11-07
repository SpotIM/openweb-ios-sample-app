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
    fileprivate unowned let servicesProvider: OWSharedServicesProviding

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

    init(servicesProvider: OWSharedServicesProviding) {
        self.servicesProvider = servicesProvider
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
    func setupObservers() {
        newToastObservable
            .flatMap { [weak self] _ -> Observable<Void> in
                guard let self = self else { return .empty() }
                return self.servicesProvider.blockerServicing().waitForNonBlocker(for: [.toastNotification])
            }
            .subscribe(onNext: { [weak self] in
                guard let self = self,
                      !self.queue.isEmpty() else { return }
                // Block before showing toast to prevent more toasts from showing
                let action = OWDefaultBlockerAction(blockerType: .toastNotification)
                self.servicesProvider.blockerServicing().add(blocker: action)
                // Show toast
                guard let toast = self.queue.popFirst() else {
                    action.finish()
                    return
                }
                self._toastToShow.onNext(toast)
                // Dismiss toast after duration
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + toast.durationInSec) { [weak self] in
                    self?._toastToShow.onNext(nil)
                    // Wait for the exiting animation to complete before unblocking next toast
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + ToastMetrics.animationDuration) {
                        action.finish()
                    }
                }
            })
            .disposed(by: disposeBag)
    }
}

struct OWToastNotificationPresentData: Codable, Equatable {
    let data: OWToastRequiredData
    var durationInSec: Double = 5
    // Show on specific view? all views??
}
