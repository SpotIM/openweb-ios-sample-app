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
            ThemeColorItem(title: "Skeleton", selectedColor: PublishSubject()),
            ThemeColorItem(title: "Skeleton Shimmering", selectedColor: PublishSubject()),
            ThemeColorItem(title: "Primary Separator", selectedColor: PublishSubject()),
            ThemeColorItem(title: "Secondary Separator", selectedColor: PublishSubject()),
            ThemeColorItem(title: "Tertiary Separator", selectedColor: PublishSubject()),
            ThemeColorItem(title: "Primary Text", selectedColor: PublishSubject()),
            ThemeColorItem(title: "Secondary Text", selectedColor: PublishSubject()),
            ThemeColorItem(title: "Tertiary Text", selectedColor: PublishSubject()),
            ThemeColorItem(title: "Primary Background", selectedColor: PublishSubject()),
            ThemeColorItem(title: "Secindary Background", selectedColor: PublishSubject()),
            ThemeColorItem(title: "Tertiary Background", selectedColor: PublishSubject()),
            ThemeColorItem(title: "Primary Border", selectedColor: PublishSubject()),
            ThemeColorItem(title: "Secondary Border", selectedColor: PublishSubject()),
            ThemeColorItem(title: "Tertiary Border", selectedColor: PublishSubject()),
            ThemeColorItem(title: "Loader", selectedColor: PublishSubject()),
            ThemeColorItem(title: "Brand Color", selectedColor: PublishSubject())
        ]
    }()
}

struct ThemeColorItem {
    let title: String
    let selectedColor: PublishSubject<UIColor?>
}
