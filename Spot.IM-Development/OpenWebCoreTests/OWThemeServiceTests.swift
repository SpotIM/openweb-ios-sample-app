//
//  OWThemeServiceTests.swift
//  OpenWebCoreTests
//
//  Created by Philip Kluz on 2023-08-01.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import XCTest
import RxSwift
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
                let themeStyleService = OWThemeStyleService()
                var observedStyle: OWThemeStyle?

                themeStyleService.style.subscribe(onNext: { style in
                    observedStyle = style
                }).disposed(by: disposeBag)

                expect(observedStyle).toEventually(equal(.light))
            }

            it("should allow for styles to be set") {
                let themeStyleService = OWThemeStyleService()
                var observedStyles: [OWThemeStyle] = []

                themeStyleService.style.subscribe(onNext: { style in
                    observedStyles.append(style)
                }).disposed(by: disposeBag)

                themeStyleService.setStyle(style: .dark)
                expect(observedStyles).toEventually(contain([.light, .dark]), timeout: .seconds(1))

                themeStyleService.setStyle(style: .light)
                expect(observedStyles).toEventually(equal([.light, .dark, .light]), timeout: .seconds(1))
            }

            it("should enforce a style if applicable regardless of what is set") {
                let themeStyleService = OWThemeStyleService()
                var observedStyles: [OWThemeStyle] = []

                themeStyleService.style.subscribe(onNext: { style in
                    observedStyles.append(style)
                }).disposed(by: disposeBag)

                themeStyleService.setEnforcement(enforcement: .theme(.dark))
                expect(observedStyles).toEventually(contain([.light, .dark]), timeout: .seconds(1))

                themeStyleService.setStyle(style: .light)
                expect(observedStyles).toEventually(equal([.light, .dark]), timeout: .seconds(1))
            }
        }
    }
}
