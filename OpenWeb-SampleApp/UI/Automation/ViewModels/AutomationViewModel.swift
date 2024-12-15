//
//  AutomationViewModel.swift
//  OpenWeb-Development
//
//  Created by Alon Haiut on 06/07/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import OpenWebSDK

#if AUTOMATION

protocol AutomationViewModelingInputs {
    var fontsTapped: PublishSubject<Void> { get }
    var userInformationTapped: PublishSubject<Void> { get }
    func setNavigationController(_ navController: UINavigationController?)
}

protocol AutomationViewModelingOutputs {
    var title: String { get }
    var showError: Observable<String> { get }
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

    private let dataModel: SDKConversationDataModel
    private weak var navController: UINavigationController?

    private let disposeBag = DisposeBag()

    let fontsTapped = PublishSubject<Void>()
    let userInformationTapped = PublishSubject<Void>()

    private let _showError = PublishSubject<String>()
    var showError: Observable<String> {
        return _showError
            .asObservable()
    }

    lazy var title: String = {
        return NSLocalizedString("Automation", comment: "")
    }()

    init(dataModel: SDKConversationDataModel) {
        self.dataModel = dataModel
        setupObservers()
    }

    func setNavigationController(_ navController: UINavigationController?) {
        self.navController = navController
    }
}

private extension AutomationViewModel {

    func setupObservers() {
        fontsTapped
            .subscribe(onNext: { [weak self] _ in
                guard let self,
                      let navigationController = self.navController else { return }

                let manager = OpenWeb.manager
                let flows = manager.ui.flows

                flows.fonts(presentationalMode: OWPresentationalMode.push(navigationController: navigationController),
                                        additionalSettings: OWAutomationSettings(),
                                        callbacks: nil,
                                        completion: { [weak self] result in
                    guard let self else { return }
                    switch result {
                    case .success:
                        // All good
                        break
                    case .failure(let error):
                        let message = error.description
                        DLog("Calling flows.fonts error: \(message)")
                        self._showError.onNext(message)
                    }
                })
            })
            .disposed(by: disposeBag)

        userInformationTapped
            .subscribe(onNext: { [weak self] _ in
                guard let self,
                      let navigationController = self.navController else { return }

                let manager = OpenWeb.manager
                let flows = manager.ui.flows

                flows.userStatus(presentationalMode: OWPresentationalMode.push(navigationController: navigationController),
                                        additionalSettings: OWAutomationSettings(),
                                        callbacks: nil,
                                        completion: { [weak self] result in
                    guard let self else { return }
                    switch result {
                    case .success:
                        // All good
                        break
                    case .failure(let error):
                        let message = error.description
                        DLog("Calling flows.userStatus error: \(message)")
                        self._showError.onNext(message)
                    }
                })
            })
            .disposed(by: disposeBag)
    }
}

#endif
