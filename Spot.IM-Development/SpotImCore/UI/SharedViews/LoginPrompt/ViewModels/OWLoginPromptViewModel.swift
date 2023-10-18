//
//  OWLoginPromptViewModel.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 17/10/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

protocol OWLoginPromptViewModelingInputs {
    var loginPromptTap: PublishSubject<Void> { get }
}

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

        setupObservers()
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

    var loginPromptTap = PublishSubject<Void>()
    fileprivate var _openLogin: Observable<Void> {
        loginPromptTap
            .asObservable()
    }
}

fileprivate extension OWLoginPromptViewModel {
    func setupObservers() {
        _openLogin
            .flatMapLatest { [weak self] _ -> Observable<Void> in
                guard let self = self else { return .empty() }
                return self.servicesProvider.authenticationManager().ifNeededTriggerAuthenticationUI(for: .loginPrompt)
                    .voidify()
            }
            .flatMapLatest { [weak self] _ -> Observable<Void> in
                guard let self = self else { return .empty() }
                return self.servicesProvider.authenticationManager().waitForAuthentication(for: .loginPrompt)
                    .voidify()
            }
            .subscribe(onNext: { _ in return })
            .disposed(by: disposeBag)
    }
}
