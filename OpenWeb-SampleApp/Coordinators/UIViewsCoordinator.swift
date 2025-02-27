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

    private let router: Routering

    init(router: Routering) {
        self.router = router
    }

    override func start(deepLinkOptions: DeepLinkOptions? = nil,
                        coordinatorData: CoordinatorData? = nil) -> Observable<Void> {

        guard let data = coordinatorData,
              case CoordinatorData.conversationDataModel(let conversationDataModel) = data else {
            fatalError("UIViewsCoordinator requires coordinatorData from `CoordinatorData.conversationDataModel` type")
        }

        let viewsVM: UIViewsViewModeling = UIViewsViewModel(dataModel: conversationDataModel)
        let viewsVC = UIViewsVC(viewModel: viewsVM)

        let vcPopped = PublishSubject<Void>()

        router.push(viewsVC,
                    animated: true,
                    completion: vcPopped)

        // Child coordinators
        let mockArticleIndependentCoordinator = viewsVM.outputs.openMockArticleScreen
            .asObservable()
            .flatMap { [weak self] dataModel -> Observable<Void> in
                guard let self else { return .empty() }
                let coordinatorData = CoordinatorData.actionsViewSettings(data: dataModel)
                let coordinator = MockArticleIndependentCoordinator(router: self.router)
                return self.coordinate(to: coordinator, coordinatorData: coordinatorData)
            }
            .flatMap { _ -> Observable<Void> in
                return .never()
            }

        let viewsExamplesCoordinator = viewsVM.outputs.openExamplesScreen
            .asObservable()
            .flatMap { [weak self] dataModel -> Observable<Void> in
                guard let self else { return .empty() }
                let coordinatorData = CoordinatorData.postId(data: dataModel)
                let coordinator = ViewsExamplesCoordinator(router: self.router)
                return self.coordinate(to: coordinator, coordinatorData: coordinatorData)
            }
            .flatMap { _ -> Observable<Void> in
                return .never()
            }

        let monetizationCoordinator = viewsVM.outputs.openMonetizationScreen
            .asObservable()
            .flatMap { [weak self] dataModel -> Observable<Void> in
                guard let self else { return .empty() }
                let coordinatorData = CoordinatorData.postId(data: dataModel)
                let coordinator = MonetizationViewsCoordinator(router: self.router)
                return self.coordinate(to: coordinator, coordinatorData: coordinatorData)
            }
            .flatMap { _ -> Observable<Void> in
                return .never()
            }

        return Observable.merge(vcPopped.asObservable(),
                                mockArticleIndependentCoordinator,
                                viewsExamplesCoordinator,
                                monetizationCoordinator)
    }
}
