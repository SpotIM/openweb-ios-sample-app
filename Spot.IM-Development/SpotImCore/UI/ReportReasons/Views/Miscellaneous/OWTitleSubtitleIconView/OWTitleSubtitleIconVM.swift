//
//  OWTitleViewViewModel.swift
//  SpotImCore
//
//  Created by Refael Sommer on 29/06/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

protocol OWTitleSubtitleIconViewModelingInputs { }

protocol OWTitleSubtitleIconViewModelingOutputs {
    var iconName: String { get }
    var title: String { get }
    var subtitle: String { get }
    var accessibilityPrefixId: String { get }
}

protocol OWTitleSubtitleIconViewModeling {
    var inputs: OWTitleSubtitleIconViewModelingInputs { get }
    var outputs: OWTitleSubtitleIconViewModelingOutputs { get }
}

class OWTitleSubtitleIconViewModel: OWTitleSubtitleIconViewModeling, OWTitleSubtitleIconViewModelingOutputs, OWTitleSubtitleIconViewModelingInputs {
    var inputs: OWTitleSubtitleIconViewModelingInputs { return self }
    var outputs: OWTitleSubtitleIconViewModelingOutputs { return self }

    let iconName: String
    let title: String
    let subtitle: String
    let accessibilityPrefixId: String

    init(iconName: String, title: String, subtitle: String, accessibilityPrefixId: String) {
        self.iconName = iconName
        self.title = title
        self.subtitle = subtitle
        self.accessibilityPrefixId = accessibilityPrefixId
    }
}
