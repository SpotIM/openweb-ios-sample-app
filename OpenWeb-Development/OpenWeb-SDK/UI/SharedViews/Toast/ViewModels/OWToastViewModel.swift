//
//  OWToastViewModel.swift
//  OpenWebSDK
//
//  Created by  Nogah Melamed on 20/06/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import RxSwift
import UIKit

protocol OWToastViewModelingInputs {
    var actionClick: PublishSubject<Void> { get }
    var dismiss: PublishSubject<Void> { get }
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
    var dismiss = PublishSubject<Void>()
    let completions: [OWToastCompletion: PublishSubject<Void>?]
    var disposeBag = DisposeBag()

    init(requiredData: OWToastRequiredData, completions: [OWToastCompletion: PublishSubject<Void>?]) {
        title = requiredData.title
        toastActionViewModel = OWToastActionViewModel(action: requiredData.action)
        showAction = requiredData.action != .none
        self.completions = completions
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
                guard let actionCompletion = self?.completions[.action]
                else { return }
                actionCompletion?.onNext()
            })
            .disposed(by: disposeBag)

        dismiss
            .asObservable()
            .subscribe(onNext: { [weak self] in
                guard let dismissCompletion = self?.completions[.dismiss]
                else { return }
                dismissCompletion?.onNext()
            })
            .disposed(by: disposeBag)
    }

    func iconForType(type: OWToastType) -> UIImage {
        var image: UIImage? = nil
        switch type {
        case .information: image = UIImage(spNamed: "informationToast", supportDarkMode: false)
        case .success: image = UIImage(spNamed: "successToast", supportDarkMode: false)
        case .error: image = UIImage(spNamed: "errorToast", supportDarkMode: false)
        case .warning: image = UIImage(spNamed: "warningToast", supportDarkMode: false)
        }

        return image ?? UIImage()
    }

    func borderColorForType(type: OWToastType) -> UIColor {
        switch type {
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
