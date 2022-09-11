//
//  OWBaseCoordinator.swift
//  SpotImCore
//
//  Created by Alon Haiut on 01/03/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

// Base abstract coordinator generic over the return type of the `start` method.
class OWBaseCoordinator<ResultType> {

    // Typealias which will allows to access a ResultType of the Coordainator
    typealias CoordinationResult = ResultType

    var disposeBag = DisposeBag()

    // Unique identifier.
    private let identifier = UUID()

    // Dictionary of the child coordinators. Every child coordinator should be added
    // to that dictionary in order to keep it in memory.
    // Key is an `identifier` of the child coordinator and value is the coordinator itself.
    // Value type is `Any` because Swift doesn't allow to store generic types in the array.
    private var childCoordinators = [UUID: Any]()
    
    func removeAllChildCoordinators() {
        childCoordinators.removeAll()
    }

    // Stores coordinator to the `childCoordinators` dictionary.
    func store<T>(coordinator: OWBaseCoordinator<T>) {
        childCoordinators[coordinator.identifier] = coordinator
    }

    // Release coordinator from the `childCoordinators` dictionary.
    func free<T>(coordinator: OWBaseCoordinator<T>) {
        childCoordinators[coordinator.identifier] = nil
    }

    // 1. Stores coordinator in a dictionary of child coordinators.
    // 2. Calls method `start()` on that coordinator.
    // 3. On the `onNext:` of returning observable of method `start()` removes coordinator from the dictionary.
    func coordinate<T>(to coordinator: OWBaseCoordinator<T>,
                       deepLinkOptions: OWDeepLinkOptions? = nil) -> Observable<T> {
        store(coordinator: coordinator)
        return coordinator.start(deepLinkOptions: deepLinkOptions)
            .do(onNext: { [weak self, weak coordinator] _ in
                guard let self = self,
                    let coord = coordinator else { return }
                self.free(coordinator: coord)
            })
    }

    // Starts the job of the coordinator. Should be used when a router is available (i.e UINavigationController)
    func start(deepLinkOptions: OWDeepLinkOptions? = nil) -> Observable<ResultType> {
        fatalError("Method should be implemented.")
    }
    
    // Used for retriving the component which we create for publishers & partners (i.e SDK consumers) to show. Can be used when a router is NOT available
    func showableComponent() -> Observable<OWShowable> {
        fatalError("Method should be implemented.")
    }
    
    // Used for retriving a component with a preferred dynamic size we create for publishers & partners (i.e SDK consumers) to show. Can be used when a router is NOT available
    func showableComponentDynamicSize() -> Observable<OWViewDynamicSizeOption> {
        fatalError("Method should be implemented.")
    }
    
    // A callback once the publishers & partners (i.e SDK consumers) removed a component from their UI . Should be used when a router is NOT available
    func showableComponentRemoved() -> Observable<Void> {
        fatalError("Method should be implemented.")
    }
}

