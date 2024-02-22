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
    func showToast(presentData: OWToastNotificationPresentData, actionCompletion: PublishSubject<Void>?)
    var toastToShow: Observable<(OWToastNotificationPresentData, PublishSubject<Void>?)?> { get }
    func clearCurrentToast()
}

class OWToastNotificationService: OWToastNotificationServicing {
    fileprivate let queue = OWQueue<OWToastNotificationPresentData>()
    fileprivate unowned let servicesProvider: OWSharedServicesProviding
    fileprivate var mapToastToActionPublishSubject: [String: PublishSubject<Void>?] = [:]
    fileprivate var dismissAfterDurationBlock = DispatchWorkItem {}
    fileprivate var disposeBag: DisposeBag = DisposeBag()

    fileprivate var _toastToShow = BehaviorSubject<(OWToastNotificationPresentData, PublishSubject<Void>?)?>(value: nil)
    var toastToShow: Observable<(OWToastNotificationPresentData, PublishSubject<Void>?)?> {
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

    func showToast(presentData: OWToastNotificationPresentData, actionCompletion: PublishSubject<Void>?) {
        queue.insert(presentData)
        mapToastToActionPublishSubject[presentData.uuid] = actionCompletion
        newToast.onNext()
    }

    func clearCurrentToast() {
        dismissAfterDurationBlock.cancel()
        self.servicesProvider.blockerServicing().removeBlocker(perType: .toastNotification)
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
                let actionCompletion = self.mapToastToActionPublishSubject[toast.uuid] ?? nil
                self._toastToShow.onNext((toast, actionCompletion))
                // Dismiss toast after duration
                dismissAfterDurationBlock = DispatchWorkItem(block: { [weak self] in
                    if let _ = self?.mapToastToActionPublishSubject[toast.uuid] {
                        self?._toastToShow.onNext(nil)
                    }
                    self?.mapToastToActionPublishSubject.removeValue(forKey: toast.uuid)
                    // Wait for the exiting animation to complete before unblocking next toast
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + ToastMetrics.animationDuration) {
                        action.finish()
                    }
                })
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + toast.durationInSec, execute: dismissAfterDurationBlock)
            })
            .disposed(by: disposeBag)
    }
}
