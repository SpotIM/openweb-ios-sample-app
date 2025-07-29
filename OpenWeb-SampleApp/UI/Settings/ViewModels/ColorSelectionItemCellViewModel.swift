//
//  ColorSelectionItemCellViewModel.swift
//  OpenWeb-Development
//
//  Created by  Nogah Melamed on 01/01/2024.
//  Copyright © 2024 OpenWeb. All rights reserved.
//

import Combine
import UIKit
import OpenWebSDK

@available(iOS 14.0, *)
protocol ColorSelectionItemCellViewModelingInputs {
    var isEnabled: CurrentValueSubject<Bool, Never> { get }
    var displayPicker: PassthroughSubject<ColorType, Never> { get }
    var lightColor: CurrentValueSubject<UIColor?, Never> { get }
    var darkColor: CurrentValueSubject<UIColor?, Never> { get }
}

@available(iOS 14.0, *)
protocol ColorSelectionItemCellViewModelingOutputs {
    var title: String { get }
    var displayPickerObservable: AnyPublisher<ColorType, Never> { get }
    var color: AnyPublisher<OWColor?, Never> { get }
    var lightColorObservable: AnyPublisher<UIColor?, Never> { get }
    var darkColorObservable: AnyPublisher<UIColor?, Never> { get }
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

    private var item: ThemeColorItem

    init(item: ThemeColorItem) {
        self.item = item
        self.lightColor = CurrentValueSubject(item.initialColor?.lightColor)
        self.darkColor = CurrentValueSubject(item.initialColor?.darkColor)
    }

    var displayPicker = PassthroughSubject<ColorType, Never>()
    lazy var displayPickerObservable: AnyPublisher<ColorType, Never> = {
        displayPicker
            .eraseToAnyPublisher()
    }()

    var title: String {
        item.title
    }

    var lightColor: CurrentValueSubject<UIColor?, Never>
    lazy var lightColorObservable: AnyPublisher<UIColor?, Never> = {
        lightColor
            .eraseToAnyPublisher()
    }()
    var darkColor: CurrentValueSubject<UIColor?, Never>
    lazy var darkColorObservable: AnyPublisher<UIColor?, Never> = {
        darkColor
            .eraseToAnyPublisher()
    }()

    lazy var color: AnyPublisher<OWColor?, Never> = {
        Publishers.CombineLatest3(
            lightColorObservable,
            darkColorObservable,
            isEnabled
        )
        .map { light, dark, enabled in
            guard enabled,
                  let lightColor = light,
                  let darkColor = dark
            else { return nil }

            return OWColor(lightColor: lightColor, darkColor: darkColor)
        }
        .prepend(item.initialColor)
        .eraseToAnyPublisher()
    }()

    var isEnabled = CurrentValueSubject<Bool, Never>(true)
}

@available(iOS 14.0, *)
extension ColorSelectionItemCellViewModel: Hashable {
    static func == (lhs: ColorSelectionItemCellViewModel, rhs: ColorSelectionItemCellViewModel) -> Bool {
        lhs.title == rhs.title
    }

    func hash(into hasher: inout Hasher) {
        title.hash(into: &hasher)
    }
}
