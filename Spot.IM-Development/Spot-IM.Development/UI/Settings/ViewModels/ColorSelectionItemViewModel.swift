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
    var isEnabled: BehaviorSubject<Bool> { get }
    var displayPicker: PublishSubject<ColorType> { get }
    var lightColor: BehaviorSubject<UIColor?> { get }
    var darkColor: BehaviorSubject<UIColor?> { get }
}

@available(iOS 14.0, *)
protocol ColorSelectionItemViewModelingOutputs {
    var title: String { get }
    var displayPickerObservable: Observable<ColorType> { get }
    var color: Observable<OWColor?> { get }
    var lightColorObservable: Observable<UIColor?> { get }
    var darkColorObservable: Observable<UIColor?> { get }
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
