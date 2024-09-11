//
//  OWFlowActionsService.swift
//  OpenWebSDK
//
//  Created by Refael Sommer on 09/09/2024.
//  Copyright © 2024 OpenWeb. All rights reserved.
//

import Foundation
import RxSwift

/*
 This service will be held by each coordinator (multiple services from this type are allowed).
 Will perform the logic of "waiting" for "bloking" tasks before triggering the callback with the appropriate view action
 Will use internally a queue for the view actions
*/

protocol OWFlowActionsServicing {
    func append(viewAction: OWFlowActionCallbackType)
}

class OWFlowActionsService: OWFlowActionsServicing {

    fileprivate var flowActionsCallbacks: OWFlowActionsCallbacks?
    fileprivate let servicesProvider: OWSharedServicesProviding
    fileprivate let viewSourceType: OWViewSourceType
    fileprivate let queue = OWQueue<OWFlowActionCallbackType>(duplicationStrategy: .replaceDuplicates)
    fileprivate var disposeBag: DisposeBag?

    init(servicesProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared,
         flowActionsCallbacks: OWFlowActionsCallbacks?,
         viewSourceType: OWViewSourceType) {
        self.flowActionsCallbacks = flowActionsCallbacks
        self.servicesProvider = servicesProvider
        self.viewSourceType = viewSourceType
    }

    func append(viewAction: OWFlowActionCallbackType) {
        queue.insert(viewAction)
        setupBlockerServiceObservers()
    }
}

fileprivate extension OWFlowActionsService {
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
                self.flowActionsCallbacks?(action, self.viewSourceType, postId)
            }
        }
    }
}
