//
//  ColorsCustomizationViewModel.swift
//  Spot-IM.Development
//
//  Created by  Nogah Melamed on 01/01/2024.
//  Copyright © 2024 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift
import SpotImCore

protocol ColorsCustomizationViewModelingInputs { }

protocol ColorsCustomizationViewModelingOutputs {
    var title: String { get }
    var colorItems: [ThemeColorItem] { get }
}

protocol ColorsCustomizationViewModeling {
    var inputs: ColorsCustomizationViewModelingInputs { get }
    var outputs: ColorsCustomizationViewModelingOutputs { get }
}

class ColorsCustomizationViewModel: ColorsCustomizationViewModeling, ColorsCustomizationViewModelingInputs, ColorsCustomizationViewModelingOutputs {
    var inputs: ColorsCustomizationViewModelingInputs { return self }
    var outputs: ColorsCustomizationViewModelingOutputs { return self }

    lazy var title: String = {
        return NSLocalizedString("CustomColors", comment: "")
    }()

    lazy var colorItems: [ThemeColorItem] = {
        return [
            ThemeColorItem(title: "Skeleton", selectedColor: BehaviorSubject(value: colorTheme.skeletonColor)),
            ThemeColorItem(title: "Skeleton Shimmering", selectedColor: BehaviorSubject(value: colorTheme.skeletonShimmeringColor)),
            ThemeColorItem(title: "Primary Separator", selectedColor: BehaviorSubject(value: colorTheme.primarySeparatorColor)),
            ThemeColorItem(title: "Secondary Separator", selectedColor: BehaviorSubject(value: colorTheme.secondarySeparatorColor)),
            ThemeColorItem(title: "Tertiary Separator", selectedColor: BehaviorSubject(value: colorTheme.tertiaryTextColor)),
            ThemeColorItem(title: "Primary Text", selectedColor: BehaviorSubject(value: colorTheme.primaryTextColor)),
            ThemeColorItem(title: "Secondary Text", selectedColor: BehaviorSubject(value: colorTheme.secondaryTextColor)),
            ThemeColorItem(title: "Tertiary Text", selectedColor: BehaviorSubject(value: colorTheme.tertiaryTextColor)),
            ThemeColorItem(title: "Primary Background", selectedColor: BehaviorSubject(value: colorTheme.primaryBackgroundColor)),
            ThemeColorItem(title: "Secindary Background", selectedColor: BehaviorSubject(value: colorTheme.secondaryBackgroundColor)),
            ThemeColorItem(title: "Tertiary Background", selectedColor: BehaviorSubject(value: colorTheme.tertiaryBackgroundColor)),
            ThemeColorItem(title: "Primary Border", selectedColor: BehaviorSubject(value: colorTheme.primaryBorderColor)),
            ThemeColorItem(title: "Secondary Border", selectedColor: BehaviorSubject(value: colorTheme.secondaryBorderColor)),
            ThemeColorItem(title: "Loader", selectedColor: BehaviorSubject(value: colorTheme.loaderColor)),
            ThemeColorItem(title: "Brand Color", selectedColor: BehaviorSubject(value: colorTheme.brandColor))
        ]
    }()

    fileprivate var colorTheme: OWTheme

    init() {
        self.colorTheme = OpenWeb.manager.ui.customizations.customizedTheme
    }
}

struct ThemeColorItem {
    let title: String
    let selectedColor: BehaviorSubject<OWColor?>
}
