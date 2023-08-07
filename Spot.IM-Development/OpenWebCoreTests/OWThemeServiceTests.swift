//
//  OWThemeServiceTests.swift
//  OpenWebCoreTests
//
//  Created by Philip Kluz on 2023-08-01.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import XCTest
import RxSwift
import RxTest
import RxBlocking
import Quick
import Nimble

@testable import SpotImCore

final class OWThemeServiceTests: QuickSpec {
    
    override func spec() {
        var disposeBag: DisposeBag!

        beforeEach {
            disposeBag = DisposeBag()
        }

        afterEach {
            disposeBag = nil
        }

        describe("OWThemeService") {
            it("should have an initial style") {
                let scheduler = TestScheduler(initialClock: 0)
                let observer = scheduler.createObserver(OWThemeStyle.self)

                let themeStyleService = OWThemeStyleService()
                themeStyleService.style.subscribe(observer).disposed(by: disposeBag)

                scheduler.start()

                expect(observer.events).to(equal([.next(0, .light)]))
            }

            it("should allow for styles to be set") {
                let scheduler = TestScheduler(initialClock: 0)
                let observer = scheduler.createObserver(OWThemeStyle.self)

                let themeStyleService = OWThemeStyleService()
                themeStyleService.style.subscribe(observer).disposed(by: disposeBag)

                scheduler.scheduleAt(10) {
                    themeStyleService.setStyle(style: .dark)
                }

                scheduler.scheduleAt(20) {
                    themeStyleService.setStyle(style: .light)
                }

                scheduler.start()

                let expectedEvents: [Recorded<Event<OWThemeStyle>>] = [
                    .next(0, .light),
                    .next(10, .dark),
                    .next(20, .light)
                ]

                expect(observer.events).to(equal(expectedEvents))
            }

            it("should enforce a style if applicable regardless of what is set") {
                let scheduler = TestScheduler(initialClock: 0)
                let observer = scheduler.createObserver(OWThemeStyle.self)

                let themeStyleService = OWThemeStyleService()
                themeStyleService.style.subscribe(observer).disposed(by: disposeBag)

                scheduler.scheduleAt(10) {
                    themeStyleService.setEnforcement(enforcement: .theme(.dark))
                }

                scheduler.scheduleAt(20) {
                    themeStyleService.setStyle(style: .light)
                }

                scheduler.scheduleAt(30) {
                    observer.onCompleted()
                }

                scheduler.start()

                let expectedEvents: [Recorded<Event<OWThemeStyle>>] = [
                    .next(0, .light),
                    .next(10, .dark),
                    // .next(20, .light) is NOT expected here due to enforcement of dark before.
                    .completed(30)
                ]

                expect(observer.events).to(equal(expectedEvents))
            }
        }
    }
}
