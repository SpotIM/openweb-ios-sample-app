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
}

class OWCustomizationsLayer: OWCustomizations, OWCustomizationsInternalProtocol {

    fileprivate struct Metrics {
        static let maxCustomizableElementCallbacksNumber: Int = 10
    }

    // Prefer to expose computed property and internally work with filprivate vars
    var fontFamily: String? {
        get {
            return _fontFamily
        }
        set(newFamily) {
            _fontFamily = newFamily
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

    fileprivate var _fontFamily: String? = nil
    fileprivate let _sortingCustomizer: OWSortingCustomizations = OWSortingCustomizer()
    fileprivate var _themeEnforcement: OWThemeStyleEnforcement = .none
    fileprivate var callbacks = [OWOptionalEncapsulation<OWCustomizableElementCallback>]()
}
