//
//  OWColorPalette.swift
//  OpenWebSDK
//
//  Created by Alon Haiut on 03/11/2022.
//  Copyright © 2022 OpenWeb. All rights reserved.
//

import UIKit
import RxSwift

protocol OWColorPaletteProtocol {
    func color(type: OWColor.OWType, themeStyle: OWThemeStyle) -> UIColor
    var colorDriver: Observable<[OWColor.OWType: OWColor]> { get }
    func initiateColors()
}

protocol OWColorPaletteConfigurable {
    func setColor(_ color: UIColor, forType type: OWColor.OWType, forThemeStyle themeStyle: OWThemeStyle)
    func blockForOverride(color: OWColor.OWType)
}

class OWColorPalette: OWColorPaletteProtocol, OWColorPaletteConfigurable {
    private var colors = [OWColor.OWType: OWColor]()
    private var colorsMapper = BehaviorSubject<[OWColor.OWType: OWColor]>(value: [:])
    private var blockedForOverride: Set<OWColor.OWType> = Set()

    var colorDriver: Observable<[OWColor.OWType: OWColor]> {
        return colorsMapper
            .asObservable()
            .observe(on: MainScheduler.instance)
            .share(replay: 1)
    }

    static let shared: OWColorPaletteProtocol & OWColorPaletteConfigurable = OWColorPalette()

    // Multiple threads / queues access to this class
    // Avoiding "data race" by using a lock
    private let lock: OWLock = OWUnfairLock()

    private init() {
        initiateColors()
    }

    func initiateColors() {
        // Initialize default colors
        self.lock.lock()

        colors.removeAll()
        for type in OWColor.OWType.allCases {
            colors[type] = type.default
        }
        blockedForOverride.removeAll()
        let colorsRx = colors.filter { $0.key.shouldUpdateRxObservable }

        // We unlock here since straight after "colorsMapper.onNext(colorsRx)"
        // Subscribers to colorsMapper will call "func color(type: themeStyle:)"
        // And will cause a recursive lock and crash
        self.lock.unlock()
        colorsMapper.onNext(colorsRx)
    }

    func color(type: OWColor.OWType, themeStyle: OWThemeStyle) -> UIColor {
        // swiftlint:disable self_capture_in_blocks
        self.lock.lock(); defer { self.lock.unlock() }
        // swiftlint:enable self_capture_in_blocks

        guard let color = colors[type] else {
            // We should never get here. I chose to work with non-optional so as a default value we will return "clear"
            return .clear
        }

        return color.color(forThemeStyle: themeStyle)
    }

    func setColor(_ color: UIColor, forType type: OWColor.OWType, forThemeStyle themeStyle: OWThemeStyle) {
        self.lock.lock()
        guard var encapsulateColor = colors[type],
              !blockedForOverride.contains(type)
        else {
            self.lock.unlock()
            return
        }

        encapsulateColor.setColor(color, forThemeStyle: themeStyle)
        colors[type] = encapsulateColor // We are working with structs here, so we need to re set the encapsulated color for this key

        // We unlock here since straight after "colorsMapper.onNext(colorsRx)"
        // Subscribers to colorsMapper will call "func color(type: themeStyle:)"
        // And will cause a recursive lock and crash
        self.lock.unlock()

        if type.shouldUpdateRxObservable {
            let colorsRx = colors.filter { $0.key.shouldUpdateRxObservable }
            colorsMapper.onNext(colorsRx)
        }
    }

    func blockForOverride(color: OWColor.OWType) {
        // swiftlint:disable self_capture_in_blocks
        self.lock.lock(); defer { self.lock.unlock() }
        // swiftlint:enable self_capture_in_blocks

        self.blockedForOverride.insert(color)
    }
}
