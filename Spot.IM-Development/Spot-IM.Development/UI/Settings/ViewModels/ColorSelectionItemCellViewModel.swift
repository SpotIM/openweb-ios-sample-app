//
//  ColorSelectionItemCellViewModel.swift
//  Spot-IM.Development
//
//  Created by  Nogah Melamed on 01/01/2024.
//  Copyright © 2024 Spot.IM. All rights reserved.
//

import RxSwift
import SpotImCore

@available(iOS 14.0, *)
protocol ColorSelectionItemCellViewModelingInputs {
    var isEnabled: BehaviorSubject<Bool> { get }
    var displayPicker: PublishSubject<ColorType> { get }
    var lightColor: BehaviorSubject<UIColor?> { get }
    var darkColor: BehaviorSubject<UIColor?> { get }
}

@available(iOS 14.0, *)
protocol ColorSelectionItemCellViewModelingOutputs {
    var title: String { get }
    var displayPickerObservable: Observable<ColorType> { get }
    var color: Observable<OWColor?> { get }
    var lightColorObservable: Observable<UIColor?> { get }
    var darkColorObservable: Observable<UIColor?> { get }
}

@available(iOS 14.0, *)
protocol ColorSelectionItemCellViewModeling {
    var inputs: ColorSelectionItemCellViewModelingInputs { get }
    var outputs: ColorSelectionItemCellViewModelingOutputs { get }
}

@available(iOS 14.0, *)
class ColorSelectionItemCellViewModel: ColorSelectionItemCellViewModeling, ColorSelectionItemCellViewModelingInputs, ColorSelectionItemCellViewModelingOutputs {
    var inputs: ColorSelectionItemCellViewModelingInputs { return self }
    var outputs: ColorSelectionItemCellViewModelingOutputs { return self }

    fileprivate var item: ThemeColorItem
    fileprivate let disposeBag = DisposeBag()

    init(item: ThemeColorItem) {
        self.item = item
        self.lightColor = BehaviorSubject(value: item.initialColor?.lightColor)
        self.darkColor = BehaviorSubject(value: item.initialColor?.darkColor)
    }

    var displayPicker = PublishSubject<ColorType>()
    lazy var displayPickerObservable: Observable<ColorType> = {
        displayPicker
            .asObservable()
    }()

    var title: String {
        item.title
    }

    var lightColor: BehaviorSubject<UIColor?>
    lazy var lightColorObservable: Observable<UIColor?> = {
        lightColor
            .asObservable()
    }()
    var darkColor: BehaviorSubject<UIColor?>
    lazy var darkColorObservable: Observable<UIColor?> = {
        darkColor
            .asObservable()
    }()

    lazy var color: Observable<OWColor?> = {
        Observable.combineLatest(
            lightColorObservable,
            darkColorObservable,
            isEnabled.asObservable()
        ) { light, dark, enabled in
            guard enabled,
                  let lightColor = light,
                  let darkColor = dark
            else { return nil }

            return OWColor(lightColor: lightColor, darkColor: darkColor)
        }
        .startWith(item.initialColor)
    }()

    var isEnabled = BehaviorSubject(value: true)
}

enum ColorType {
    case light
    case dark
}
