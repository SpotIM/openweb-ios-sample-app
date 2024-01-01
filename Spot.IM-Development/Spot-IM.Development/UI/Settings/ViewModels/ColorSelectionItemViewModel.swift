//
//  ColorSelectionItemViewModel.swift
//  Spot-IM.Development
//
//  Created by  Nogah Melamed on 01/01/2024.
//  Copyright © 2024 Spot.IM. All rights reserved.
//

import RxSwift
import SpotImCore

@available(iOS 14.0, *)
protocol ColorSelectionItemViewModelingInputs {
    var colorChanged: PublishSubject<OWColor?> { get }
    var displayPicker: PublishSubject<UIColorPickerViewController> { get }
}

@available(iOS 14.0, *)
protocol ColorSelectionItemViewModelingOutputs {
    var title: String { get }
    var displayPickerObservable: Observable<UIColorPickerViewController> { get }
    var color: Observable<OWColor?> { get }
}

@available(iOS 14.0, *)
protocol ColorSelectionItemViewModeling {
    var inputs: ColorSelectionItemViewModelingInputs { get }
    var outputs: ColorSelectionItemViewModelingOutputs { get }
}

@available(iOS 14.0, *)
class ColorSelectionItemViewModel: ColorSelectionItemViewModeling, ColorSelectionItemViewModelingInputs, ColorSelectionItemViewModelingOutputs {
    var inputs: ColorSelectionItemViewModelingInputs { return self }
    var outputs: ColorSelectionItemViewModelingOutputs { return self }

    fileprivate var item: ThemeColorItem

    init(item: ThemeColorItem) {
        self.item = item
    }

    var displayPicker = PublishSubject<UIColorPickerViewController>()
    lazy var displayPickerObservable: Observable<UIColorPickerViewController> = {
        displayPicker
            .asObservable()
    }()

    var title: String {
        item.title
    }

    var colorChanged = PublishSubject<OWColor?>()
    lazy var color: Observable<OWColor?> = {
        colorChanged
            .asObservable()
            .startWith(item.initialColor)
    }()
}
