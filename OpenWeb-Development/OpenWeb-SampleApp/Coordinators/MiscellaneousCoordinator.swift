//
//  MiscellaneousCoordinator.swift
//  OpenWeb-SampleApp
//
//  Created by Alon Haiut on 11/08/2024.
//  Copyright © 2024 OpenWeb. All rights reserved.
//

import Foundation
import RxSwift

class MiscellaneousCoordinator: BaseCoordinator<Void> {

    fileprivate let router: Routering

    init(router: Routering) {
        self.router = router
    }

    override func start(deepLinkOptions: DeepLinkOptions? = nil,
                        coordinatorData: CoordinatorData? = nil) -> Observable<Void> {

        guard let data = coordinatorData,
              case CoordinatorData.conversationDataModel(let conversationDataModel) = data else {
            fatalError("UIFlowsCoordinator requires coordinatorData from `CoordinatorData.conversationDataModel` type")
        }

        let miscellaneousVM: MiscellaneousViewModeling = MiscellaneousViewModel(dataModel: conversationDataModel)
        let miscellaneousVC = MiscellaneousVC(viewModel: miscellaneousVM)

        let vcPopped = PublishSubject<Void>()

        setupCoordinatorInternalNavigation(viewModel: miscellaneousVM)

        router.push(miscellaneousVC,
                    animated: true,
                    completion: vcPopped)

        return vcPopped
            .asObservable()
    }
}

fileprivate extension MiscellaneousCoordinator {
    func setupCoordinatorInternalNavigation(viewModel: MiscellaneousViewModeling) {

    }
}
