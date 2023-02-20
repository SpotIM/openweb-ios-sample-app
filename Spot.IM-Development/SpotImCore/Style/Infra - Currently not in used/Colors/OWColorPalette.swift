//
//  OWColorPalette.swift
//  SpotImCore
//
//  Created by Alon Haiut on 03/11/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import UIKit
import RxSwift

protocol OWColorPaletteProtocol {
    func color(type: OWColor.OWType, themeStyle: OWThemeStyle) -> UIColor
    var colorDriver: Observable<[OWColor.OWType: OWColor]> { get }
}

protocol OWColorPaletteConfigurable {
    func setColor(_ color: UIColor, forType type: OWColor.OWType, forThemeStyle themeStyle: OWThemeStyle)
}

class OWColorPalette: OWColorPaletteProtocol, OWColorPaletteConfigurable {
    fileprivate var colors = [OWColor.OWType: OWColor]()
    fileprivate var colorsMapper = BehaviorSubject<[OWColor.OWType: OWColor]>(value: [:])
    var colorDriver: Observable<[OWColor.OWType: OWColor]> {
        return colorsMapper
            .asObservable()
            .observe(on: MainScheduler.instance)
            .share(replay: 1)
    }

    static let shared: OWColorPaletteProtocol & OWColorPaletteConfigurable = OWColorPalette()

    private init() {
        // Initialize default colors
        for type in OWColor.OWType.allCases {
            colors[type] = type.default
        }
        let colorsRx = colors.filter { $0.key.shouldUpdateRxObservable }
        colorsMapper.onNext(colorsRx)
    }

    func color(type: OWColor.OWType, themeStyle: OWThemeStyle) -> UIColor {
        guard let color = colors[type] else {
            // We should never get here. I chose to work with non-optional so as a default value we will return "clear"
            return .clear
        }

        return color.color(forThemeStyle: themeStyle)
    }

    func setColor(_ color: UIColor, forType type: OWColor.OWType, forThemeStyle themeStyle: OWThemeStyle) {
        guard var encapsulateColor = colors[type] else { return }
        encapsulateColor.setColor(color, forThemeStyle: themeStyle)
        colors[type] = encapsulateColor // We are working with structs here, so we need to re set the encapsulated color for this key
        if (type.shouldUpdateRxObservable) {
            let colorsRx = colors.filter { $0.key.shouldUpdateRxObservable }
            colorsMapper.onNext(colorsRx)
        }
    }
}
