//
//  OWCustomizationsService.swift
//  SpotImCore
//
//  Created by Alon Haiut on 18/04/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

protocol OWCustomizationsServicing {
    func trigger(customizableElement: OWCustomizableElement)
}

class OWCustomizationsService: OWCustomizationsServicing {

    fileprivate let servicesProvider: OWSharedServicesProviding
    fileprivate let viewSourceType: OWViewSourceType
    fileprivate let customizationsLayer: OWCustomizationsInternalProtocol

    // swiftlint:disable force_cast
    init(servicesProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared,
         customizationsLayer: OWCustomizationsInternalProtocol = OpenWeb.manager.ui.customizations as! OWCustomizationsInternalProtocol,
         viewSourceType: OWViewSourceType) {
        self.servicesProvider = servicesProvider
        self.customizationsLayer = customizationsLayer
        self.viewSourceType = viewSourceType
    }
    // swiftlint:enable force_cast

    func trigger(customizableElement: OWCustomizableElement) {
        customizationsLayer.triggerElementCallback(customizableElement, sourceType: viewSourceType)
    }
}
