//
//  OWViewActionsService.swift
//  OpenWebSDK
//
//  Created by Alon Haiut on 10/04/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
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

    private var viewActionsCallbacks: OWViewActionsCallbacks?
    private let servicesProvider: OWSharedServicesProviding
    private let viewSourceType: OWViewSourceType
    private let queue = OWQueue<OWViewActionCallbackType>(duplicationStrategy: .replaceDuplicates)
    private var disposeBag: DisposeBag?

    init(servicesProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared,
         viewActionsCallbacks: OWViewActionsCallbacks?,
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

private extension OWViewActionsService {
    func setupBlockerServiceObservers() {
        disposeBag = DisposeBag() // Cancel previous subscriptions
        guard let dispose = disposeBag else { return }
        let blockerService = servicesProvider.blockerServicing()

        blockerService.waitForNonBlocker(for: [.authentication, .renewAuthentication])
            .take(1) // Exist already in the blocker service side, but for clarity written here as well
            .subscribe(onNext: { [weak self] _ in
                self?.triggerAllAvailableActions()
            })
            .disposed(by: dispose)
    }

    func triggerAllAvailableActions() {
        guard let postId = OWManager.manager.postId else { return }

        // Ensure callbacks are triggered from main thread
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            while !self.queue.isEmpty(),
                  let action = self.queue.popFirst() {
                self.viewActionsCallbacks?(action, self.viewSourceType, postId)
            }
        }
    }
}
