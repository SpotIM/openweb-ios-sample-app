//
//  AutomationViewModel.swift
//  Spot-IM.Development
//
//  Created by Alon Haiut on 06/07/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

#if AUTOMATION

protocol AutomationViewModelingInputs {
    var fontsTapped: PublishSubject<Void> { get }
    var userInformationTapped: PublishSubject<Void> { get }
}

protocol AutomationViewModelingOutputs {
    var title: String { get }
    var openUserInformation: Observable<SDKConversationDataModel> { get }
    var openFonts: Observable<SDKConversationDataModel> { get }
}

protocol AutomationViewModeling {
    var inputs: AutomationViewModelingInputs { get }
    var outputs: AutomationViewModelingOutputs { get }
}

class AutomationViewModel: AutomationViewModeling,
                                AutomationViewModelingOutputs,
                                AutomationViewModelingInputs {
    var inputs: AutomationViewModelingInputs { return self }
    var outputs: AutomationViewModelingOutputs { return self }

    fileprivate let dataModel: SDKConversationDataModel

    fileprivate let disposeBag = DisposeBag()

    let fontsTapped = PublishSubject<Void>()
    let userInformationTapped = PublishSubject<Void>()

    fileprivate let _openFonts = PublishSubject<SDKConversationDataModel>()
    var openFonts: Observable<SDKConversationDataModel> {
        return _openFonts.asObservable()
    }

    fileprivate let _openUserInformation = PublishSubject<SDKConversationDataModel>()
    var openUserInformation: Observable<SDKConversationDataModel> {
        return _openUserInformation.asObservable()
    }

    lazy var title: String = {
        return NSLocalizedString("Automation", comment: "")
    }()

    init(dataModel: SDKConversationDataModel) {
        self.dataModel = dataModel
        setupObservers()
    }
}

fileprivate extension AutomationViewModel {

    func setupObservers() {

        fontsTapped
            .map { [weak self] _ -> SDKConversationDataModel? in
                guard let self = self else { return nil }
                return self.dataModel
            }
            .unwrap()
            .bind(to: _openFonts)
            .disposed(by: disposeBag)

        userInformationTapped
            .map { [weak self] _ -> SDKConversationDataModel? in
                guard let self = self else { return nil }
                return self.dataModel
            }
            .unwrap()
            .bind(to: _openUserInformation)
            .disposed(by: disposeBag)
    }
}

#endif
