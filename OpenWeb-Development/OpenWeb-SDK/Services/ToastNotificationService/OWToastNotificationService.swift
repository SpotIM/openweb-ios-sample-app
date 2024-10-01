//
//  OWToastNotificationService.swift
//  OpenWebSDK
//
//  Created by  Nogah Melamed on 12/09/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import Foundation
import RxSwift

protocol OWToastNotificationServicing {
    func showToast(data: OWToastNotificationCombinedData)
    var toastToShow: Observable<OWToastNotificationCombinedData?> { get }
    var clearCurrentToast: PublishSubject<Void> { get }
}

class OWToastNotificationService: OWToastNotificationServicing {
    private let queue = OWQueue<OWToastNotificationPresentData>()
    private unowned let servicesProvider: OWSharedServicesProviding
    private var mapToastToActionPublishSubject: [String: PublishSubject<Void>?] = [:]
    private var disposeBag: DisposeBag = DisposeBag()
    private var newToastDisposeBag: DisposeBag = DisposeBag()
    private var _toastToShow = BehaviorSubject<OWToastNotificationCombinedData?>(value: nil)
    var toastToShow: Observable<OWToastNotificationCombinedData?> {
        return _toastToShow
            .asObservable()
    }

    private var triggerWaitNextToastInQueue = PublishSubject<Void>()
    private var presentToastFromQueue = PublishSubject<Void>()

    var clearCurrentToast = PublishSubject<Void>()

    init(servicesProvider: OWSharedServicesProviding) {
        self.servicesProvider = servicesProvider
        setupObservers()
        setupNewToastObservable()
    }

    func showToast(data: OWToastNotificationCombinedData) {
        queue.insert(data.presentData)
        mapToastToActionPublishSubject[data.presentData.uuid] = data.actionCompletion
        triggerWaitNextToastInQueue.onNext()
    }
}

private extension OWToastNotificationService {
    func setupObservers() {
        clearCurrentToast
            .withLatestFrom(toastToShow)
            .unwrap()
            .subscribe(onNext: { [weak self] currentToast in
                guard let self else { return }
                self.newToastDisposeBag = DisposeBag()
                self.setupNewToastObservable()
                self._toastToShow.onNext(nil)
                self.mapToastToActionPublishSubject.removeValue(forKey: currentToast.presentData.uuid)
                let action = OWDefaultBlockerAction(blockerType: .toastNotification)
                action.finish()
            })
            .disposed(by: disposeBag)

        triggerWaitNextToastInQueue
            .flatMap { [weak self] _ -> Observable<Void> in
                guard let self else { return .empty() }
                return self.servicesProvider.blockerServicing().waitForNonBlocker(for: [.toastNotification])
            }
            .bind(to: presentToastFromQueue)
            .disposed(by: disposeBag)
    }

    func setupNewToastObservable() {
        presentToastFromQueue
            .map { [weak self] _ -> OWToastNotificationPresentData? in
                guard let self,
                      !self.queue.isEmpty(),
                      let toastPresentData = self.queue.popFirst() else { return nil }
                return toastPresentData
            }
            .unwrap()
            .do(onNext: { [weak self] toastPresentData in
                guard let self else { return }
                // Block before showing toast to prevent more toasts from showing
                let action = OWDefaultBlockerAction(blockerType: .toastNotification)
                self.servicesProvider.blockerServicing().add(blocker: action)

                let actionCompletion = self.mapToastToActionPublishSubject[toastPresentData.uuid] ?? nil
                let toastCombinedData = OWToastNotificationCombinedData(presentData: toastPresentData, actionCompletion: actionCompletion)
                self._toastToShow.onNext(toastCombinedData)
            })
            .flatMapLatest { toastPresentData -> Observable<OWToastNotificationPresentData> in
                return Observable.just(toastPresentData)
                    .delay(.seconds(toastPresentData.durationInSec), scheduler: MainScheduler.instance)
            }
            .do(onNext: { [weak self] toastPresentData in
                guard let self else { return }
                if let _ = self.mapToastToActionPublishSubject[toastPresentData.uuid] {
                    self._toastToShow.onNext(nil)
                }
                self.mapToastToActionPublishSubject.removeValue(forKey: toastPresentData.uuid)
            })
            // Wait for the exiting animation to complete before unblocking next toast
            .delay(.milliseconds(ToastMetrics.animationDurationInt), scheduler: MainScheduler.instance)
            .subscribe(onNext: { _ in
                let action = OWDefaultBlockerAction(blockerType: .toastNotification)
                action.finish()
            })
            .disposed(by: newToastDisposeBag)
    }
}
