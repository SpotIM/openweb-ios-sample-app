//
//  OWToastActionViewModel.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 20/06/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import RxSwift

protocol OWToastActionViewModelingInputs {
}

protocol OWToastActionViewModelingOutputs {
    var title: String { get }
    var icon: UIImage? { get }
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

    init(action: OWToastAction) {
        self.title = title(for: action)
        self.icon = icon(for: action)
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
        case .none:
            return nil
        }
    }
}

                                    
