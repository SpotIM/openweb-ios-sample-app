//
//  OWCustomizationsLayer.swift
//  SpotImCore
//
//  Created by Alon Haiut on 08/11/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation

protocol OWCustomizationsInternalProtocol {
    func triggerElementCallback(_ element: OWCustomizableElement, sourceType: OWViewSourceType)
    func clearCallbacks()
}

class OWCustomizationsLayer: OWCustomizations, OWCustomizationsInternalProtocol {

    fileprivate struct Metrics {
        static let maxCustomizableElementCallbacksNumber: Int = 10
    }

    fileprivate let sharedServicesProvider: OWSharedServicesProviding

    init(sharedServicesProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared) {
        self.sharedServicesProvider = sharedServicesProvider
    }

    // Prefer to expose computed property and internally work with filprivate vars
    var fontFamily: OWFontGroupFamily {
        get {
            return _fontFamily
        }
        set(newFamily) {
            _fontFamily = newFamily
            sendEvent(for: .configuredFontFamily(font: newFamily))
            OWFontBook.shared.configure(fontFamilyGroup: newFamily)
        }
    }

    var sorting: OWSortingCustomizations {
        return _sortingCustomizer
    }

    var themeEnforcement: OWThemeStyleEnforcement {
        get {
            return _themeEnforcement
        }
        set(newEnforcement) {
            _themeEnforcement = newEnforcement
            sendEvent(for: .configureThemeEnforcement(enforcement: newEnforcement))
            sharedServicesProvider.themeStyleService().setEnforcement(enforcement: _themeEnforcement)
        }
    }

    var statusBarEnforcement: OWStatusBarEnforcement {
        get {
            return _statusBarEnforcement
        }
        set(newEnforcement) {
            _statusBarEnforcement = newEnforcement
            sharedServicesProvider.statusBarStyleService().setEnforcement(enforcement: _statusBarEnforcement)
        }
    }

    var navigationBarEnforcement: OWNavigationBarEnforcement {
        get {
            return _navigationBarEnforcement
        }
        set(newEnforcement) {
            _navigationBarEnforcement = newEnforcement
        }
    }

    var customizedTheme: OWTheme {
        get {
            return _customizedTheme
        }
        set(newTheme) {
            _customizedTheme = newTheme
            setColorsAccordingToTheme(newTheme)
        }
    }

    func addElementCallback(_ callback: @escaping OWCustomizableElementCallback) {
        guard callbacks.count < Metrics.maxCustomizableElementCallbacksNumber else {
            let logger = sharedServicesProvider.logger()
            logger.log(level: .error,
                       "`addElementCallback` function can accept up to \(Metrics.maxCustomizableElementCallbacksNumber) different callbacks. This number was already reached.")
            return
        }

        let optionalCallback = OWOptionalEncapsulation(value: callback)
        callbacks.append(optionalCallback)
    }

    func triggerElementCallback(_ element: OWCustomizableElement, sourceType: OWViewSourceType) {
        let themeStyle = sharedServicesProvider.themeStyleService().currentStyle
        let postId = OWManager.manager.postId

        callbacks.forEach { optionalCallback in
            guard let actualCallback = optionalCallback.value() else { return }
            actualCallback(element, sourceType, themeStyle, postId)
        }
    }

    func clearCallbacks() {
        callbacks.removeAll()
    }

    fileprivate var _fontFamily: OWFontGroupFamily = .default
    fileprivate let _sortingCustomizer: OWSortingCustomizations = OWSortingCustomizer()
    fileprivate var _themeEnforcement: OWThemeStyleEnforcement = .none
    fileprivate var _statusBarEnforcement: OWStatusBarEnforcement = .matchTheme
    fileprivate var _navigationBarEnforcement: OWNavigationBarEnforcement = .style(.largeTitles)
    fileprivate var _customizedTheme: OWTheme = OWTheme()
    fileprivate var callbacks = [OWOptionalEncapsulation<OWCustomizableElementCallback>]()
}

fileprivate extension OWCustomizationsLayer {
    func event(for eventType: OWAnalyticEventType) -> OWAnalyticEvent {
        return sharedServicesProvider
            .analyticsEventCreatorService()
            .analyticsEvent(
                for: eventType,
                articleUrl: "",
                layoutStyle: .none,
                component: .none)
    }

    func sendEvent(for eventType: OWAnalyticEventType) {
        let event = event(for: eventType)
        sharedServicesProvider
            .analyticsService()
            .sendAnalyticEvents(events: [event])
    }

    func setColorsAccordingToTheme(_ theme: OWTheme) {
        setColor(color: theme.skeletonColor, type: .skeletonColor)
        setColor(color: theme.skeletonShimmeringColor, type: .skeletonShimmeringColor)
        setColor(color: theme.primarySeparatorColor, type: .separatorColor3)
        setColor(color: theme.secondarySeparatorColor, type: .separatorColor2)
        setColor(color: theme.tertiarySeparatorColor, type: .separatorColor1)
        setColor(color: theme.primaryTextColor, type: .textColor4)
        setColor(color: theme.secondaryTextColor, type: .textColor3)
        setColor(color: theme.tertiaryTextColor, type: .textColor2)
        setColor(color: theme.primaryBackgroundColor, type: .backgroundColor2)
        setColor(color: theme.secondaryBackgroundColor, type: .backgroundColor4)
        setColor(color: theme.tertiaryBackgroundColor, type: .backgroundColor5)
        setColor(color: theme.primaryBorderColor, type: .borderColor2)
        setColor(color: theme.secondaryBorderColor, type: .borderColor1)
        setColor(color: theme.loaderColor, type: .loaderColor)
        if let brandColor = theme.brandColor {
            setColor(color: theme.brandColor, type: .brandColor)
            OWColorPalette.shared.blockForOverride(color: .brandColor)
        }
    }

    func setColor(color: OWColor?, type: OWColor.OWType) {
        guard let color = color else { return }
        OWColorPalette.shared.setColor(color.lightColor, forType: type, forThemeStyle: .light)
        OWColorPalette.shared.setColor(color.darkColor, forType: type, forThemeStyle: .dark)
    }
}
