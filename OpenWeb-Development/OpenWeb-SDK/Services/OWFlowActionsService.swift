//
//  OWFlowActionsService.swift
//  OpenWebSDK
//
//  Created by Refael Sommer on 09/09/2024.
//  Copyright © 2024 OpenWeb. All rights reserved.
//

import Foundation
import RxSwift
import UIKit

/*
 This service will be held by each coordinator (multiple services from this type are allowed).
 Will perform the logic of "waiting" for "bloking" tasks before triggering the callback with the appropriate view action
 Will use internally a queue for the view actions
*/

protocol OWFlowActionsServicing {
    func append(flowAction: OWFlowActionCallbackType)
    // This is used to tell the coordinator that all events where sent to publisher before the coordinator is deallocated
    var serviceQueueEmpty: Observable<Void> { get }
    func getOpenProfileActionCallback(for navigationController: UINavigationController?,
                                      openProfileType: OWOpenProfileType,
                                      presentationalModeCompact: OWPresentationalModeCompact) -> OWFlowActionCallbackType?
}

class OWFlowActionsService: OWFlowActionsServicing {

    private var flowActionsCallbacks: OWFlowActionsCallbacks?
    private let servicesProvider: OWSharedServicesProviding
    private let viewSourceType: OWViewSourceType
    private let queue = OWQueue<OWFlowActionCallbackType>(duplicationStrategy: .replaceDuplicates)
    private var disposeBag: DisposeBag?

    private var _serviceQueueEmpty = PublishSubject<Void>()
    var serviceQueueEmpty: Observable<Void> {
        return _serviceQueueEmpty
            .asObservable()
    }

    init(servicesProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared,
         flowActionsCallbacks: OWFlowActionsCallbacks?,
         viewSourceType: OWViewSourceType) {
        self.flowActionsCallbacks = flowActionsCallbacks
        self.servicesProvider = servicesProvider
        self.viewSourceType = viewSourceType
        setupBlockerServiceObservers() // to ensure serviceQueueEmpty is setup when there are no action callbacks
    }

    func append(flowAction: OWFlowActionCallbackType) {
        queue.insert(flowAction)
        setupBlockerServiceObservers()
    }

    func getOpenProfileActionCallback(for navigationController: UINavigationController?,
                                      openProfileType: OWOpenProfileType,
                                      presentationalModeCompact: OWPresentationalModeCompact) -> OWFlowActionCallbackType? {
        guard let navigationController else { return nil }
        switch openProfileType {
        case .publisherProfile(let ssoPublisherId, let type):
            let presentationMode: OWPresentationalMode? = {
                switch presentationalModeCompact {
                case .present(style: let style):
                    guard let viewController = navigationController.viewControllers.last else { return nil }
                    return OWPresentationalMode.present(viewController: viewController, style: style)
                case .push, .none:
                    return OWPresentationalMode.push(navigationController: navigationController)
                }
            }()
            guard let presentationMode else { return nil }
            return OWFlowActionCallbackType.openPublisherProfile(ssoPublisherId: ssoPublisherId,
                                                                 type: type,
                                                                 presentationalMode: presentationMode)
        default:
            return nil
        }
    }
}

private extension OWFlowActionsService {
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
            guard let self else { return }
            while let action = self.queue.popFirst() {
                self.flowActionsCallbacks?(action, self.viewSourceType, postId)
            }
            _serviceQueueEmpty.onNext()
        }
    }
}
