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

    fileprivate let shouldShow: Bool

    init(shouldShow: Bool = true, servicesProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared) {
        self.servicesProvider = servicesProvider
        self.shouldShow = shouldShow
        disposeBag = DisposeBag()
    }

    var shouldShowView: Observable<Bool> {
        servicesProvider.authenticationManager()
            .userAuthenticationStatus
            .map { [weak self] status in
                guard self?.shouldShow == true,
                      OWManager.manager.authentication.shouldDisplayLoginPrompt == true
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
