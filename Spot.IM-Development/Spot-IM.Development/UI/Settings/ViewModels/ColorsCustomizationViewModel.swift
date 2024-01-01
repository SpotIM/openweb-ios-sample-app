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
            ThemeColorItem(title: "Skeleton", selectedColor: PublishSubject())
        ]
    }()
}

struct ThemeColorItem {
    let title: String
    let selectedColor: PublishSubject<UIColor?>
}
