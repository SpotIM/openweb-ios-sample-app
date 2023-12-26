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
    var style: OWLoginPromptAlignmentStyle { get }
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

    let style: OWLoginPromptAlignmentStyle
    fileprivate let servicesProvider: OWSharedServicesProviding
    fileprivate let disposeBag: DisposeBag

    fileprivate let isFeatureEnabled: Bool

    init(isFeatureEnabled: Bool = true,
         style: OWLoginPromptAlignmentStyle,
         servicesProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared) {
        self.servicesProvider = servicesProvider
        self.isFeatureEnabled = isFeatureEnabled
        self.style = style
        disposeBag = DisposeBag()

        setupObservers()
    }

    var shouldShowView: Observable<Bool> {
        Observable.combineLatest(
            servicesProvider.authenticationManager().userAuthenticationStatus,
            servicesProvider.networkAvailabilityService().networkAvailable
        ) { status, networkAvailable -> OWInternalUserAuthenticationStatus? in
            guard networkAvailable == true else { return nil }
            return status
        }
        .map { [weak self] status in
            guard self?.isFeatureEnabled == true,
                  OWManager.manager.authentication.shouldDisplayLoginPrompt == true,
                  let status = status
            else { return false }
            switch status {
            case .ssoLoggedIn, .ssoRecovering, .ssoRecoveredSuccessfully:
                return false
            default:
                return true
            }
        }
        .startWith(false)
        .distinctUntilChanged()
        .share(replay: 1)
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
            .flatMapLatest { [weak self] _ -> Observable<Bool> in
                guard let self = self else { return .empty() }
                return self.servicesProvider.authenticationManager().waitForAuthentication(for: .loginPrompt)
            }
            .filter { $0 }
            .subscribe(onNext: { _ in return })
            .disposed(by: disposeBag)
    }
}
