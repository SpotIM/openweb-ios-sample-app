//
//  AutomationCoordinator.swift
//  OpenWeb-SampleApp
//
//  Created by Alon Haiut on 12/08/2024.
//  Copyright © 2024 OpenWeb. All rights reserved.
//

#if AUTOMATION

import Foundation
import RxSwift

class AutomationCoordinator: BaseCoordinator<Void> {

    fileprivate let router: Routering

    init(router: Routering) {
        self.router = router
    }

    override func start(deepLinkOptions: DeepLinkOptions? = nil,
                        coordinatorData: CoordinatorData? = nil) -> Observable<Void> {

        guard let data = coordinatorData,
              case CoordinatorData.conversationDataModel(let conversationDataModel) = data else {
            fatalError("AutomationCoordinator requires coordinatorData from `CoordinatorData.conversationDataModel` type")
        }

        let automationVM: AutomationViewModeling = AutomationViewModel(dataModel: conversationDataModel)
        let automationVC = AutomationVC(viewModel: automationVM)

        let vcPopped = PublishSubject<Void>()

        router.push(automationVC,
                    animated: true,
                    completion: vcPopped)

        return vcPopped
            .asObservable()
    }
}

#endif
