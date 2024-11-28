//
//  UIFlowsCoordinator.swift
//  OpenWeb-SampleApp
//
//  Created by Alon Haiut on 11/08/2024.
//  Copyright © 2024 OpenWeb. All rights reserved.
//

import Foundation
import RxSwift

class UIFlowsCoordinator: BaseCoordinator<Void> {

    private let router: Routering

    init(router: Routering) {
        self.router = router
    }

    override func start(deepLinkOptions: DeepLinkOptions? = nil,
                        coordinatorData: CoordinatorData? = nil) -> Observable<Void> {

        guard let data = coordinatorData,
              case CoordinatorData.conversationDataModel(let conversationDataModel) = data else {
            fatalError("UIFlowsCoordinator requires coordinatorData from `CoordinatorData.conversationDataModel` type")
        }

        let flowsVM: UIFlowsViewModeling = UIFlowsViewModel(dataModel: conversationDataModel)
        let flowsVC = UIFlowsVC(viewModel: flowsVM)

        let vcPopped = PublishSubject<Void>()

        router.push(flowsVC,
                    animated: true,
                    completion: vcPopped)

        let mockArticleFlowCoordinator = flowsVM.outputs.openMockArticleScreen
            .flatMap { [weak self] dataModel -> Observable<Void> in
                guard let self else { return .empty() }
                let coordinatorData = CoordinatorData.actionsFlowSettings(data: dataModel)
                let coordinator = MockArticleFlowCoordinator(router: self.router)
                return self.coordinate(to: coordinator, coordinatorData: coordinatorData)
            }
            .flatMap { _ -> Observable<Void> in
                return .never()
            }

        return Observable.merge(vcPopped.asObservable(),
                                mockArticleFlowCoordinator)
    }
}
