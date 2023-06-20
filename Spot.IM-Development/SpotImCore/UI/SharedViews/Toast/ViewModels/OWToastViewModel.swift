//
//  OWToastViewModel.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 20/06/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import RxSwift

protocol OWToastViewModelingInputs {
}

protocol OWToastViewModelingOutputs {
    var iconImage: UIImage { get }
    var title: String { get }
}

protocol OWToastViewModeling {
    var inputs: OWToastViewModelingInputs { get }
    var outputs: OWToastViewModelingOutputs { get }
}

class OWToastViewModel: OWToastViewModeling, OWToastViewModelingInputs, OWToastViewModelingOutputs {
    var inputs: OWToastViewModelingInputs { return self }
    var outputs: OWToastViewModelingOutputs { return self }

    var iconImage: UIImage = UIImage()

    var title: String

    init(requiredData: OWToastRequiredData) {
        title = requiredData.title
        iconImage = self.iconForType(type: requiredData.type)
    }
}

fileprivate extension OWToastViewModel {
    func iconForType(type: OWToastType) -> UIImage {
        var image: UIImage? = nil
        switch(type) {
        case .information: image = UIImage(spNamed: "informationToast", supportDarkMode: false)
        case .success: image = UIImage(spNamed: "sucessToast", supportDarkMode: false)
        case .error: image = UIImage(spNamed: "errorToast", supportDarkMode: false)
        }

        return image ?? UIImage()
    }
}
