//
//  UIViewsCoordinator.swift
//  OpenWeb-SampleApp
//
//  Created by Alon Haiut on 11/08/2024.
//  Copyright © 2024 OpenWeb. All rights reserved.
//

import Foundation
import RxSwift

class UIViewsCoordinator: BaseCoordinator<Void> {

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

        let viewsVM: UIViewsViewModeling = UIViewsViewModel(dataModel: conversationDataModel)
        let viewsVC = UIViewsVC(viewModel: viewsVM)

        let vcPopped = PublishSubject<Void>()

        setupCoordinatorInternalNavigation(viewModel: viewsVM)

        router.push(viewsVC,
                    animated: true,
                    completion: vcPopped)

        return vcPopped
            .asObservable()
    }
}

fileprivate extension UIViewsCoordinator {
    func setupCoordinatorInternalNavigation(viewModel: UIViewsViewModeling) {

    }
}
