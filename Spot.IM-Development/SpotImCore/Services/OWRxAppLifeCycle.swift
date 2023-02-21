//
//  OWRxAppLifeCycle.swift
//  SpotImCore
//
//  Created by Alon Haiut on 01/05/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import UIKit
import RxSwift

protocol OWRxAppLifeCycleProtocol {
    var willTerminate: Observable<Void> { get }
    var didBecomeActive: Observable<Void> { get }
    var didEnterBackground: Observable<Void> { get }
    var willEnterForeground: Observable<Void> { get }
    var willResignActive: Observable<Void> { get }
}

class OWRxAppLifeCycle: OWRxAppLifeCycleProtocol {

    fileprivate let notificationCenter: NotificationCenter
    fileprivate let app: UIApplication
    fileprivate let queueScheduler: SerialDispatchQueueScheduler
    fileprivate let disposeBag = DisposeBag()

    init(notificationCenter: NotificationCenter = NotificationCenter.default,
         app: UIApplication = UIApplication.shared,
         queueScheduler: SerialDispatchQueueScheduler = SerialDispatchQueueScheduler(qos: .userInteractive, internalSerialQueueName: "OpenWebSDKAppLifeCycleQueue")) {
        self.notificationCenter = notificationCenter
        self.app = app
        self.queueScheduler = queueScheduler

        setupObservers()
    }

    fileprivate let _willTerminate = PublishSubject<Void>()
    var willTerminate: Observable<Void> {
        return _willTerminate
            .asObservable()
            .share(replay: 0) // Zero to emitt new subscriber only new events
    }

    fileprivate let _didBecomeActive = PublishSubject<Void>()
    var didBecomeActive: Observable<Void> {
        return _didBecomeActive
            .asObservable()
            .share(replay: 0) // Zero to emitt new subscriber only new events
    }

    fileprivate let _didEnterBackground = PublishSubject<Void>()
    var didEnterBackground: Observable<Void> {
        return _didEnterBackground
            .asObservable()
            .share(replay: 0) // Zero to emitt new subscriber only new events
    }

    fileprivate let _willEnterForeground = PublishSubject<Void>()
    var willEnterForeground: Observable<Void> {
        return _willEnterForeground
            .asObservable()
            .share(replay: 0) // Zero to emitt new subscriber only new events
    }

    fileprivate let _willResignActive = PublishSubject<Void>()
    var willResignActive: Observable<Void> {
        return _willResignActive
            .asObservable()
            .share(replay: 0) // Zero to emitt new subscriber only new events
    }
}

fileprivate extension OWRxAppLifeCycle {
    func setupObservers() {
        notificationCenter.rx.notification(UIApplication.willTerminateNotification)
            .observe(on: queueScheduler)
            .voidify()
            .bind(to: _willTerminate)
            .disposed(by: disposeBag)

        notificationCenter.rx.notification(UIApplication.didBecomeActiveNotification)
            .observe(on: queueScheduler)
            .voidify()
            .bind(to: _didBecomeActive)
            .disposed(by: disposeBag)

        notificationCenter.rx.notification(UIApplication.didEnterBackgroundNotification)
            .observe(on: queueScheduler)
            .voidify()
            .bind(to: _didEnterBackground)
            .disposed(by: disposeBag)

        notificationCenter.rx.notification(UIApplication.willEnterForegroundNotification)
            .observe(on: queueScheduler)
            .voidify()
            .bind(to: _willEnterForeground)
            .disposed(by: disposeBag)

        notificationCenter.rx.notification(UIApplication.willResignActiveNotification)
            .observe(on: queueScheduler)
            .voidify()
            .bind(to: _willResignActive)
            .disposed(by: disposeBag)
    }
}
