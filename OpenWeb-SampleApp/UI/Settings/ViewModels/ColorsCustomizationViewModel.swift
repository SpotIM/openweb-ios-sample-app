//
//  ColorsCustomizationViewModel.swift
//  OpenWeb-Development
//
//  Created by  Nogah Melamed on 01/01/2024.
//  Copyright © 2024 OpenWeb. All rights reserved.
//

import Foundation
import Combine
import CombineExt
import OpenWebSDK

protocol ColorsCustomizationViewModelingInputs { }

@available(iOS 14.0, *)
protocol ColorsCustomizationViewModelingOutputs {
    var title: String { get }
    var cellsViewModels: AnyPublisher<[ColorSelectionItemCellViewModel], Never> { get }
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
            ThemeColorItem(title: "Skeleton", initialColor: initialColorTheme.skeletonColor),
            ThemeColorItem(title: "Skeleton Shimmering", initialColor: initialColorTheme.skeletonShimmeringColor),
            ThemeColorItem(title: "Primary Separator", initialColor: initialColorTheme.primarySeparatorColor),
            ThemeColorItem(title: "Secondary Separator", initialColor: initialColorTheme.secondarySeparatorColor),
            ThemeColorItem(title: "Tertiary Separator", initialColor: initialColorTheme.tertiarySeparatorColor),
            ThemeColorItem(title: "Primary Text", initialColor: initialColorTheme.primaryTextColor),
            ThemeColorItem(title: "Secondary Text", initialColor: initialColorTheme.secondaryTextColor),
            ThemeColorItem(title: "Tertiary Text", initialColor: initialColorTheme.tertiaryTextColor),
            ThemeColorItem(title: "Primary Background", initialColor: initialColorTheme.primaryBackgroundColor),
            ThemeColorItem(title: "Secondary Background", initialColor: initialColorTheme.secondaryBackgroundColor),
            ThemeColorItem(title: "Tertiary Background", initialColor: initialColorTheme.tertiaryBackgroundColor),
            ThemeColorItem(title: "Surface Color", initialColor: initialColorTheme.surfaceColor),
            ThemeColorItem(title: "Primary Border", initialColor: initialColorTheme.primaryBorderColor),
            ThemeColorItem(title: "Secondary Border", initialColor: initialColorTheme.secondaryBorderColor),
            ThemeColorItem(title: "Loader", initialColor: initialColorTheme.loaderColor),
            ThemeColorItem(title: "Brand Color", initialColor: initialColorTheme.brandColor),
            ThemeColorItem(title: "Vote Up Unselected", initialColor: initialColorTheme.voteUpUnselectedColor),
            ThemeColorItem(title: "Vote Down Unselected", initialColor: initialColorTheme.voteDownUnselectedColor),
            ThemeColorItem(title: "Vote Up Selected", initialColor: initialColorTheme.voteUpSelectedColor),
            ThemeColorItem(title: "Vote Down Selected", initialColor: initialColorTheme.voteDownSelectedColor)
        ]
    }()

    private let _selectedTheme = PassthroughSubject<OWTheme, Never>()
    var selectedTheme: AnyPublisher<OWTheme, Never> {
        return _selectedTheme
            .eraseToAnyPublisher()
    }

    lazy var cellsViewModels: AnyPublisher<[ColorSelectionItemCellViewModel], Never> = {
        return CurrentValueSubject(colorItems.map { item in
            return ColorSelectionItemCellViewModel(item: item)
        })
        .eraseToAnyPublisher()
    }()

    private var userDefaultsProvider: UserDefaultsProviderProtocol
    private var cancellables = Set<AnyCancellable>()
    private var initialColorTheme: OWTheme

    init(userDefaultsProvider: UserDefaultsProviderProtocol = UserDefaultsProvider.shared) {
        self.userDefaultsProvider = userDefaultsProvider
        self.initialColorTheme = userDefaultsProvider.get(key: .colorCustomizationCustomTheme, defaultValue: OWTheme())
        setupObservers()
    }
}

@available(iOS 14.0, *)
private extension ColorsCustomizationViewModel {
    func setupObservers() {
        cellsViewModels
            .map { cellsVms -> [AnyPublisher<OWColor?, Never>] in
                return cellsVms.map { vm in
                    return vm.outputs.color
                }
            }
            .map { colors in
                return colors.combineLatest().map { [weak self] colorsValues -> OWTheme in
                    guard let self else { return OWTheme() }
                    return self.getTheme(from: colorsValues)
                }
            }
            .flatMapLatest { $0 }
            .bind(to: _selectedTheme)
            .store(in: &cancellables)

        selectedTheme
            .dropFirst()
            .bind(to: userDefaultsProvider.setValues(key: UserDefaultsProvider.UDKey<OWTheme>.colorCustomizationCustomTheme))
            .store(in: &cancellables)
    }

    func getTheme(from colors: [OWColor?]) -> OWTheme {
        return OWTheme(
            skeletonColor: colors[0],
            skeletonShimmeringColor: colors[1],
            primarySeparatorColor: colors[2],
            secondarySeparatorColor: colors[3],
            tertiarySeparatorColor: colors[4],
            primaryTextColor: colors[5],
            secondaryTextColor: colors[6],
            tertiaryTextColor: colors[7],
            primaryBackgroundColor: colors[8],
            secondaryBackgroundColor: colors[9],
            tertiaryBackgroundColor: colors[10],
            surfaceColor: colors[11],
            primaryBorderColor: colors[12],
            secondaryBorderColor: colors[13],
            loaderColor: colors[14],
            brandColor: colors[15],
            voteUpUnselectedColor: colors[16],
            voteDownUnselectedColor: colors[17],
            voteUpSelectedColor: colors[18],
            voteDownSelectedColor: colors[19])
    }
}

struct ThemeColorItem {
    let title: String
    let initialColor: OWColor?
}
