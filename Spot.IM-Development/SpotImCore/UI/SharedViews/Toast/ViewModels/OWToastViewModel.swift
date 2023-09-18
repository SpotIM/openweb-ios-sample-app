//
//  OWToastViewModel.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 20/06/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import RxSwift

protocol OWToastViewModelingInputs {
    var actionClick: PublishSubject<Void> { get }
}

protocol OWToastViewModelingOutputs {
    var iconImage: UIImage { get }
    var title: String { get }
    var toastActionViewModel: OWToastActionViewModeling { get }
    var showAction: Bool { get }
    var borderColor: UIColor { get }
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
    var toastActionViewModel: OWToastActionViewModeling
    var showAction: Bool
    var borderColor: UIColor = .clear

    var actionClick = PublishSubject<Void>()
    let actionCompletion: PublishSubject<Void>
    var disposeBag = DisposeBag()

    init(requiredData: OWToastRequiredData, actionCompletion: PublishSubject<Void>) { //  } handler: @escaping (() -> Void)) {
        title = requiredData.title
        toastActionViewModel = OWToastActionViewModel(action: requiredData.action)
        showAction = requiredData.action != .none
        self.actionCompletion = actionCompletion
        iconImage = self.iconForType(type: requiredData.type)
        borderColor = self.borderColorForType(type: requiredData.type)

        setupObservers()
    }
}

fileprivate extension OWToastViewModel {
    func setupObservers() {
        actionClick
            .asObservable()
            .subscribe(onNext: { [weak self] in
                self?.actionCompletion.onNext()
            })
            .disposed(by: disposeBag)
    }

    func iconForType(type: OWToastType) -> UIImage {
        var image: UIImage? = nil
        switch(type) {
        case .information: image = UIImage(spNamed: "informationToast", supportDarkMode: false)
        case .success: image = UIImage(spNamed: "successToast", supportDarkMode: false)
        case .error: image = UIImage(spNamed: "errorToast", supportDarkMode: false)
        case .warning: image = UIImage(spNamed: "warningToast", supportDarkMode: false)
        }

        return image ?? UIImage()
    }

    func borderColorForType(type: OWToastType) -> UIColor {
        switch(type) {
        case .information:
            return OWDesignColors.G5
        case .success:
            return OWDesignColors.G3
        case .error:
            return OWDesignColors.G4
        case .warning:
            return OWDesignColors.G6
        }
    }
}
