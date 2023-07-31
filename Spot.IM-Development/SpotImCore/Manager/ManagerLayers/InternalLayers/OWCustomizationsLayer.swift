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
            switch (newEnforcement) {
            case .none:
                sendEvent(for: .configureThemeEnforcement(theme: nil))
            case let .theme(theme):
                sendEvent(for: .configureThemeEnforcement(theme: theme))
            }
            OWSharedServicesProvider.shared.themeStyleService().setEnforcement(enforcement: _themeEnforcement)
        }
    }

    func addElementCallback(_ callback: @escaping OWCustomizableElementCallback) {
        guard callbacks.count < Metrics.maxCustomizableElementCallbacksNumber else {
            let logger = OWSharedServicesProvider.shared.logger()
            logger.log(level: .error,
                       "`addElementCallback` function can accept up to \(Metrics.maxCustomizableElementCallbacksNumber) different callbacks. This number was already reached.")
            return
        }

        let optionalCallback = OWOptionalEncapsulation(value: callback)
        callbacks.append(optionalCallback)
    }

    func triggerElementCallback(_ element: OWCustomizableElement, sourceType: OWViewSourceType) {
        let themeStyle = OWSharedServicesProvider.shared.themeStyleService().currentStyle
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
    fileprivate var callbacks = [OWOptionalEncapsulation<OWCustomizableElementCallback>]()
}

fileprivate extension OWCustomizationsLayer {
    func event(for eventType: OWAnalyticEventType) -> OWAnalyticEvent {
        return OWSharedServicesProvider.shared
            .analyticsEventCreatorService()
            .analyticsEvent(
                for: eventType,
                articleUrl: "", // ??
                layoutStyle: .view, // TODO: !!??
                component: .none)
    }

    func sendEvent(for eventType: OWAnalyticEventType) {
        let event = event(for: eventType)
        OWSharedServicesProvider.shared
            .analyticsService()
            .sendAnalyticEvents(events: [event])
    }
}
