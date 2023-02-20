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
    func colorObservable(type: OWColor.OWType) -> Observable<UIColor>
}

protocol OWColorPaletteConfigurable {
    func setColor(_ color: UIColor, forType type: OWColor.OWType, forThemeStyle themeStyle: OWThemeStyle)
}

class OWColorPalette: OWColorPaletteProtocol, OWColorPaletteConfigurable {
    fileprivate var colors = [OWColor.OWType: OWColor]()
    fileprivate var colorsBehaviorSubject = [OWColor.OWType: BehaviorSubject<OWColor>]()
    fileprivate let servicesProvider: OWSharedServicesProviding
    
    static let shared: OWColorPaletteProtocol & OWColorPaletteConfigurable = OWColorPalette()
    
    private init(servicesProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared) {
        self.servicesProvider = servicesProvider
        // Initialize default colors
        for type in OWColor.OWType.allCases {
            colors[type] = type.default
            if type.shouldUpdateRxObservable {
                colorsBehaviorSubject[type] = BehaviorSubject<OWColor>(value: type.default)
            }
        }
    }

    func color(type: OWColor.OWType, themeStyle: OWThemeStyle) -> UIColor {
        guard let color = colors[type] else {
            // We should never get here. I chose to work with non-optional so as a default value we will return "clear"
            return .clear
        }

        return color.color(forThemeStyle: themeStyle)
    }
    
    func colorObservable(type: OWColor.OWType) -> Observable<UIColor> {
        guard let color = colorsBehaviorSubject[type] else {
            return .empty()
        }
        
        return Observable
            .combineLatest(color.asObserver(), servicesProvider.themeStyleService().style) { (color, style) in
                return color.color(forThemeStyle: style)
            }
            .asObservable()
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .share(replay: 1)
    }

    func setColor(_ color: UIColor, forType type: OWColor.OWType, forThemeStyle themeStyle: OWThemeStyle) {
        guard var encapsulateColor = colors[type] else { return }
        encapsulateColor.setColor(color, forThemeStyle: themeStyle)
        colors[type] = encapsulateColor // We are working with structs here, so we need to re set the encapsulated color for this key
        if type.shouldUpdateRxObservable {
            colorsBehaviorSubject[type]?.onNext(encapsulateColor)
        }
    }
}
