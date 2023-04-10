//
//  OWViewActionsService.swift
//  SpotImCore
//
//  Created by Alon Haiut on 10/04/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

/*
 This service will be held by each coordinator (multiple services from this type are allowed).
 Will perform the logic of "waiting" for "bloking" tasks before triggering the callback with the appropriate view action
 Will use internally a queue for the view actions
*/

protocol OWViewActionsServicing {
    func append(viewAction: OWViewActionCallbackType)
}

class OWViewActionsService: OWViewActionsServicing {

    fileprivate let viewActionsCallbacks: OWViewActionsCallbacks
    fileprivate let servicesProvider: OWSharedServicesProviding
    fileprivate let viewSourceType: OWViewSourceType
    fileprivate let queue = OWQueue<OWViewActionCallbackType>(duplicationStrategy: .replaceDuplicates)
    fileprivate var disposeBag: DisposeBag?

    init(servicesProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared,
         viewActionsCallbacks: @escaping OWViewActionsCallbacks,
         viewSourceType: OWViewSourceType) {
        self.viewActionsCallbacks = viewActionsCallbacks
        self.servicesProvider = servicesProvider
        self.viewSourceType = viewSourceType
    }

    func append(viewAction: OWViewActionCallbackType) {
        queue.insert(viewAction)
        setupBlockerServiceObservers()
    }
}

fileprivate extension OWViewActionsService {
    func setupBlockerServiceObservers() {
        disposeBag = DisposeBag() // Cancel previous subscriptions
        guard let dispose = disposeBag else { return }
        let blockerService = servicesProvider.blockerServicing()

        blockerService.waitForNonBlocker()
            .take(1) // Exist already in the blocker service side, but for clarity written here as well
            .subscribe(onNext: { [weak self] _ in
                self?.triggerAllAvailableActions()
            })
            .disposed(by: dispose)
    }

    func triggerAllAvailableActions() {
        guard let postId = OWManager.manager.postId else { return }
        while !queue.isEmpty(),
              let action = queue.popFirst() {
            viewActionsCallbacks(action, viewSourceType, postId)
        }
    }
}
