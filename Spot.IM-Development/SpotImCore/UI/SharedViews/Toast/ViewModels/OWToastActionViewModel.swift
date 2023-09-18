//
//  OWToastActionViewModel.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 20/06/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import RxSwift
import UIKit

protocol OWToastActionViewModelingInputs {
}

protocol OWToastActionViewModelingOutputs {
    var title: String { get }
    var icon: UIImage? { get }
    var color: Observable<UIColor> { get }
}

protocol OWToastActionViewModeling {
    var inputs: OWToastActionViewModelingInputs { get }
    var outputs: OWToastActionViewModelingOutputs { get }
}

class OWToastActionViewModel: OWToastActionViewModeling, OWToastActionViewModelingInputs, OWToastActionViewModelingOutputs {
    var inputs: OWToastActionViewModelingInputs { return self }
    var outputs: OWToastActionViewModelingOutputs { return self }

    var title: String = ""
    var icon: UIImage?
    var action: OWToastAction

    fileprivate var _color = BehaviorSubject<UIColor>(value: OWColorPalette.shared.color(type: .textColor7, themeStyle: .light))
    var color: Observable<UIColor> {
        _color
            .asObservable()
    }

    fileprivate let servicesProvider: OWSharedServicesProviding
    fileprivate var disposeBag: DisposeBag

    init(action: OWToastAction, servicesProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared) {
        self.servicesProvider = servicesProvider
        self.disposeBag = DisposeBag()
        self.action = action
        self.title = title(for: action)
        self.icon = icon(for: action)

        setupObservers()
    }
}

fileprivate extension OWToastActionViewModel {
    func title(for action: OWToastAction) -> String {
        switch(action) {
        case .learnMore:
            return OWLocalizationManager.shared.localizedString(key: "Learn More")
        case .tryAgain:
            return OWLocalizationManager.shared.localizedString(key: "Try Again")
        case .undo:
            return OWLocalizationManager.shared.localizedString(key: "Undo") // TODO: missing translations
        case .close:
            return ""
        case .none:
            return ""
        }
    }

    func icon(for action: OWToastAction) -> UIImage? {
        switch(action) {
        case .learnMore:
            return nil
        case .tryAgain:
            return UIImage(spNamed: "tryAgain")
        case .undo:
            return UIImage(spNamed: "undo")
        case .close:
            return UIImage(spNamed: "crossmark")
        case .none:
            return nil
        }
    }

    func setupObservers() {
        servicesProvider.themeStyleService()
            .style
            .subscribe(onNext: { [weak self] currentStyle in
                guard let self = self else { return }
                switch self.action {
                case .undo, .learnMore, .tryAgain:
                    self._color.onNext(OWColorPalette.shared.color(type: .textColor7, themeStyle: currentStyle))
                case .close:
                    self._color.onNext(OWColorPalette.shared.color(type: .textColor2, themeStyle: currentStyle))
                case .none:
                    break
                }
            })
            .disposed(by: disposeBag)
    }
}

