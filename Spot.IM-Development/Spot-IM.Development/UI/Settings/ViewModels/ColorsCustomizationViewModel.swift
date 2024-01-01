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

@available(iOS 14.0, *)
protocol ColorsCustomizationViewModelingOutputs {
    var title: String { get }
    var colorItemsVM: [ColorSelectionItemViewModeling] { get }
    var openPicker: Observable<UIColorPickerViewController> { get }
}

@available(iOS 14.0, *)
protocol ColorsCustomizationViewModeling {
    var inputs: ColorsCustomizationViewModelingInputs { get }
    var outputs: ColorsCustomizationViewModelingOutputs { get }
}

@available(iOS 14.0, *)
class ColorsCustomizationViewModel: ColorsCustomizationViewModeling, ColorsCustomizationViewModelingInputs, ColorsCustomizationViewModelingOutputs {
    var inputs: ColorsCustomizationViewModelingInputs { return self }
    var outputs: ColorsCustomizationViewModelingOutputs { return self }

    lazy var title: String = {
        return NSLocalizedString("CustomColors", comment: "")
    }()

    lazy var colorItems: [ThemeColorItem] = {
        return [
            ThemeColorItem(title: "Skeleton", initialColor: colorTheme.skeletonColor),
            ThemeColorItem(title: "Skeleton Shimmering", initialColor: colorTheme.skeletonShimmeringColor),
            ThemeColorItem(title: "Primary Separator", initialColor: colorTheme.primarySeparatorColor),
            ThemeColorItem(title: "Secondary Separator", initialColor: colorTheme.secondarySeparatorColor),
            ThemeColorItem(title: "Tertiary Separator", initialColor: colorTheme.tertiaryTextColor),
            ThemeColorItem(title: "Primary Text", initialColor: colorTheme.primaryTextColor),
            ThemeColorItem(title: "Secondary Text", initialColor: colorTheme.secondaryTextColor),
            ThemeColorItem(title: "Tertiary Text", initialColor: colorTheme.tertiaryTextColor),
            ThemeColorItem(title: "Primary Background", initialColor: colorTheme.primaryBackgroundColor),
            ThemeColorItem(title: "Secindary Background", initialColor: colorTheme.secondaryBackgroundColor),
            ThemeColorItem(title: "Tertiary Background", initialColor: colorTheme.tertiaryBackgroundColor),
            ThemeColorItem(title: "Primary Border", initialColor: colorTheme.primaryBorderColor),
            ThemeColorItem(title: "Secondary Border", initialColor: colorTheme.secondaryBorderColor),
            ThemeColorItem(title: "Loader", initialColor: colorTheme.loaderColor),
            ThemeColorItem(title: "Brand Color", initialColor: colorTheme.brandColor)
        ]
    }()

    lazy var colorItemsVM: [ColorSelectionItemViewModeling] = {
        return colorItems.map { item in
            return ColorSelectionItemViewModel(item: item)
        }
    }()

    lazy var openPicker: Observable<UIColorPickerViewController> = {
        return Observable.merge(
            colorItemsVM
                .map { vm in
                    vm.outputs.displayPickerObservable
                }
        )
    }()

    fileprivate var colorTheme: OWTheme

    init() {
        self.colorTheme = OpenWeb.manager.ui.customizations.customizedTheme

        setupObservers()
    }
}

@available(iOS 14.0, *)
fileprivate extension ColorsCustomizationViewModel {
    func setupObservers() {
    }
}

struct ThemeColorItem {
    let title: String
    let initialColor: OWColor?
}
