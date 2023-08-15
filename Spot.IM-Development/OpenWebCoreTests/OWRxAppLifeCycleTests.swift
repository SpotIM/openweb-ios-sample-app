//
//  OWRxAppLifeCycleTests.swift
//  OpenWebCoreTests
//
//  Created by Alon Haiut on 08/08/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import XCTest
import RxSwift
import Quick
import Nimble
@testable import SpotImCore

class OWRxAppLifeCycleTests: QuickSpec {

    override func spec() {
        describe("app life cycle service") {

            // `sut` stands for `Subject Under Test`
            var sut: OWRxAppLifeCycle!
            var disposeBag: DisposeBag!
            var notificationsResults: [NSNotification.Name]!
            var notificationCenter: NotificationCenter!

            beforeEach {
                notificationCenter = NotificationCenter()
                sut = OWRxAppLifeCycle(
                    notificationCenter: notificationCenter,
                    queueScheduler: SerialDispatchQueueScheduler(qos: .userInteractive, internalSerialQueueName: "TestingQueue")
                )
                disposeBag = DisposeBag()
                notificationsResults = []

                let willTerminateObservable = sut.willTerminate.map { UIApplication.willTerminateNotification }
                let didBecomeActiveObservable = sut.didBecomeActive.map { UIApplication.didBecomeActiveNotification }
                let didEnterBackgroundObservable = sut.didEnterBackground.map { UIApplication.didEnterBackgroundNotification }
                let willEnterForegroundObservable = sut.willEnterForeground.map { UIApplication.willEnterForegroundNotification }
                let willResignActiveObservable = sut.willResignActive.map { UIApplication.willResignActiveNotification }
                let didChangeContentSizeCategoryObservable = sut.didChangeContentSizeCategory.map { UIContentSizeCategory.didChangeNotification }

                Observable.merge(willTerminateObservable,
                                 didBecomeActiveObservable,
                                 didEnterBackgroundObservable,
                                 willEnterForegroundObservable,
                                 willResignActiveObservable,
                                 didChangeContentSizeCategoryObservable)
                    .subscribe(onNext: { notification in
                        notificationsResults.append(notification)
                    })
                    .disposed(by: disposeBag)
            }

            afterEach {}

            context("1. when triggering a single notification") {
                it("only this notification should be received") {
                    notificationCenter.post(name: UIApplication.willTerminateNotification, object: nil)
                    expect(notificationsResults).toEventually(equal([UIApplication.willTerminateNotification]))
                }
            }

            context("2. triggering a single notification multiple times") {
                it("this notification should be received the same amount of times") {
                    notificationCenter.post(name: UIApplication.didBecomeActiveNotification, object: nil)
                    notificationCenter.post(name: UIApplication.didBecomeActiveNotification, object: nil)
                    notificationCenter.post(name: UIApplication.didBecomeActiveNotification, object: nil)
                    expect(notificationsResults).toEventually(equal([UIApplication.didBecomeActiveNotification,
                                                                     UIApplication.didBecomeActiveNotification,
                                                                     UIApplication.didBecomeActiveNotification]))
                }
            }

            context("3. triggering multiple notifications") {
                it("should receive all the notifications in the same order") {
                    notificationCenter.post(name: UIContentSizeCategory.didChangeNotification, object: nil)
                    notificationCenter.post(name: UIApplication.willTerminateNotification, object: nil)
                    notificationCenter.post(name: UIApplication.didBecomeActiveNotification, object: nil)
                    notificationCenter.post(name: UIApplication.didEnterBackgroundNotification, object: nil)
                    notificationCenter.post(name: UIApplication.willEnterForegroundNotification, object: nil)
                    notificationCenter.post(name: UIApplication.willResignActiveNotification, object: nil)
                    expect(notificationsResults).toEventually(equal([UIContentSizeCategory.didChangeNotification,
                                                                     UIApplication.willTerminateNotification,
                                                                     UIApplication.didBecomeActiveNotification,
                                                                     UIApplication.didEnterBackgroundNotification,
                                                                     UIApplication.willEnterForegroundNotification,
                                                                     UIApplication.willResignActiveNotification]))
                }
            }
        }
    }
}
