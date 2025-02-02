//
//  BaseCoordinator.swift
//  OpenWeb-iOS-SDK-Demo
//
//  Created by Alon Haiut on 29/11/2021.
//

import Foundation
import RxSwift

// Base abstract coordinator generic over the return type of the `start` method.
class BaseCoordinator<ResultType> {

    var disposeBag = DisposeBag()

    // Unique identifier.
    private let identifier = UUID()

    // Dictionary of the child coordinators. Every child coordinator should be added
    // to that dictionary in order to keep it in memory.
    // Key is an `identifier` of the child coordinator and value is the coordinator itself.
    // Value type is `Any` because Swift doesn't allow to store generic types in the array.
    private var childCoordinators = [UUID: Any]()

    // Stores coordinator to the `childCoordinators` dictionary.
    func store<T>(coordinator: BaseCoordinator<T>) {
        childCoordinators[coordinator.identifier] = coordinator
    }

    // Release coordinator from the `childCoordinators` dictionary.
    func free<T>(coordinator: BaseCoordinator<T>) {
        childCoordinators[coordinator.identifier] = nil
    }

    // 1. Stores coordinator in a dictionary of child coordinators.
    // 2. Calls method `start()` on that coordinator.
    // 3. On the `onNext:` of returning observable of method `start()` removes coordinator from the dictionary.
    func coordinate<T>(to coordinator: BaseCoordinator<T>,
                       deepLinkOptions: DeepLinkOptions? = nil,
                       coordinatorData: CoordinatorData? = nil) -> Observable<T> {
        store(coordinator: coordinator)
        return coordinator.start(deepLinkOptions: deepLinkOptions,
                                 coordinatorData: coordinatorData)
            .do(onNext: { [weak self, weak coordinator] _ in
                guard let self,
                    let coord = coordinator else { return }
                self.free(coordinator: coord)
            })
    }

    // Starts job of the coordinator.
    func start(deepLinkOptions: DeepLinkOptions? = nil,
               coordinatorData: CoordinatorData? = nil) -> Observable<ResultType> {
        fatalError("Start method should be implemented.")
    }

}
