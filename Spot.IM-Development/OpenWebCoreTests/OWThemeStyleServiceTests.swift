//
//  OWThemeStyleServiceTests.swift
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

class OWThemeStyleServiceTests: QuickSpec {

    override func spec() {
        describe("theme style service") {

            // `sut` stands for `Subject Under Test`
            var sut: OWThemeStyleService!
            var disposeBag: DisposeBag!
            var stylesResults: [OWThemeStyle]!

            beforeEach {
                sut = OWThemeStyleService()
                disposeBag = DisposeBag()
                stylesResults = []

                sut.style
                    .subscribe(onNext: { style in
                        stylesResults.append(style)
                    })
                    .disposed(by: disposeBag)
            }

            afterEach {}

            context("1. when initially interacting with the service without `enforcment` changes") {
                it("should have a `light` style") {
                    expect(sut.currentStyle).to(equal(.light))
                    expect(stylesResults).toEventually(equal([.light]))
                }

                it("changing the `style` should affect the returned style") {
                    sut.setStyle(style: .dark)
                    expect(sut.currentStyle).to(equal(.dark))
                    expect(stylesResults).toEventually(equal([.light, .dark]))
                }

                it("re-setting the same `style` multiple times should NOT triggering the eturned observable style") {
                    sut.setStyle(style: .light)
                    sut.setStyle(style: .light)
                    sut.setStyle(style: .light)
                    sut.setStyle(style: .light)
                    expect(sut.currentStyle).to(equal(.light))
                    // Expected array with one value only
                    expect(stylesResults).toEventually(equal([.light]))
                }

                it("should allow styles changes") {
                    sut.setStyle(style: .dark)
                    sut.setStyle(style: .light)
                    sut.setStyle(style: .light)
                    sut.setStyle(style: .dark)
                    sut.setStyle(style: .dark)
                    // Expected latest style
                    expect(sut.currentStyle).to(equal(.dark))
                    // Expected array with only the "changes"
                    expect(stylesResults).toEventually(equal([.light, .dark, .light, .dark]))
                }
            }

            context("2. when interacting with the service after `enforcment` changes") {
                it("should keep enforcment regardless of style changes") {
                    sut.setEnforcement(enforcement: .theme(.dark))
                    sut.setStyle(style: .light)
                    expect(sut.currentStyle).to(equal(.dark))
                    expect(stylesResults).toEventually(equal([.light, .dark]))
                }

                it("should respect different enforcment during runtime and allow or disallow style changes accordingly") {
                    sut.setEnforcement(enforcement: .theme(.light))
                    sut.setStyle(style: .dark)
                    expect(sut.currentStyle).to(equal(.light))
                    expect(stylesResults).toEventually(equal([.light]))

                    sut.setEnforcement(enforcement: .theme(.dark))
                    sut.setStyle(style: .light)
                    expect(sut.currentStyle).to(equal(.dark))
                    expect(stylesResults).toEventually(equal([.light, .dark]))

                    sut.setEnforcement(enforcement: .none)
                    sut.setStyle(style: .light)
                    sut.setStyle(style: .dark)
                    expect(sut.currentStyle).to(equal(.dark))
                    expect(stylesResults).toEventually(equal([.light, .dark, .light, .dark]))
                }
            }
        }
    }
}
