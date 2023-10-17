//
//  OWLoginPromptViewModel.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 17/10/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

protocol OWLoginPromptViewModelingInputs { }

protocol OWLoginPromptViewModelingOutputs {
    var shouldShowView: Observable<Bool> { get }
}

protocol OWLoginPromptViewModeling {
    var inputs: OWLoginPromptViewModelingInputs { get }
    var outputs: OWLoginPromptViewModelingOutputs { get }
}

class OWLoginPromptViewModel: OWLoginPromptViewModeling,
                              OWLoginPromptViewModelingInputs,
                              OWLoginPromptViewModelingOutputs {

    var inputs: OWLoginPromptViewModelingInputs { return self }
    var outputs: OWLoginPromptViewModelingOutputs { return self }

    fileprivate let servicesProvider: OWSharedServicesProviding
    fileprivate let disposeBag: DisposeBag

    init(servicesProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared) {
        self.servicesProvider = servicesProvider
        disposeBag = DisposeBag()
    }

    var shouldShowView: Observable<Bool> {
        servicesProvider.authenticationManager()
            .userAuthenticationStatus
            .map { status in
                guard OWManager.manager.authentication.shouldDisplayLoginPrompt == true
                else { return false }
                switch status {
                case .ssoLoggedIn:
                    return false
                default:
                    return true
                }
            }
            .startWith(false)
    }
}
