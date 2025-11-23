//
//  UIViewsCoordinator.swift
//  OpenWeb-SampleApp
//
//  Created by Alon Haiut on 11/08/2024.
//  Copyright © 2024 OpenWeb. All rights reserved.
//

import Foundation
import Combine

class UIViewsCoordinator: BaseCoordinator<Void> {

    private let router: Routering

    init(router: Routering) {
        self.router = router
    }

    override func start(deepLinkOptions: DeepLinkOptions? = nil,
                        coordinatorData: CoordinatorData? = nil) -> AnyPublisher<Void, Never> {

        guard let data = coordinatorData,
              case CoordinatorData.conversationDataModel(let conversationDataModel) = data else {
            fatalError("UIViewsCoordinator requires coordinatorData from `CoordinatorData.conversationDataModel` type")
        }

        let viewsVM: UIViewsViewModeling = UIViewsViewModel(dataModel: conversationDataModel)
        let viewsVC = UIViewsVC(viewModel: viewsVM)

        let vcPopped = PassthroughSubject<Void, Never>()

        router.push(viewsVC,
                    animated: true,
                    completion: vcPopped)

        // Child coordinators
        let mockArticleIndependentCoordinator = viewsVM.outputs.openMockArticleScreen
            .flatMap { [weak self] dataModel -> AnyPublisher<Void, Never> in
                guard let self else { return Empty().eraseToAnyPublisher() }
                let coordinatorData = CoordinatorData.actionsViewSettings(data: dataModel)
                let coordinator = MockArticleIndependentCoordinator(router: self.router)
                return self.coordinate(to: coordinator, coordinatorData: coordinatorData)
            }
            .flatMap { _ -> AnyPublisher<Void, Never> in
                return Empty(completeImmediately: false).eraseToAnyPublisher()
            }

        let viewsExamplesCoordinator = viewsVM.outputs.openExamplesScreen
            .flatMap { [weak self] dataModel -> AnyPublisher<Void, Never> in
                guard let self else { return Empty().eraseToAnyPublisher() }
                let coordinatorData = CoordinatorData.postId(data: dataModel)
                let coordinator = UIViewsExamplesCoordinator(router: self.router)
                return self.coordinate(to: coordinator, coordinatorData: coordinatorData)
            }
            .flatMap { _ -> AnyPublisher<Void, Never> in
                return Empty(completeImmediately: false).eraseToAnyPublisher()
            }

        let monetizationCoordinator = viewsVM.outputs.openMonetizationScreen
            .flatMap { [weak self] dataModel -> AnyPublisher<Void, Never> in
                guard let self else { return Empty().eraseToAnyPublisher() }
                let coordinatorData = CoordinatorData.postId(data: dataModel)
                let coordinator = MonetizationViewsCoordinator(router: self.router)
                return self.coordinate(to: coordinator, coordinatorData: coordinatorData)
            }
            .flatMap { _ -> AnyPublisher<Void, Never> in
                return Empty(completeImmediately: false).eraseToAnyPublisher()
            }

        return Publishers.Merge4(vcPopped,
                                 mockArticleIndependentCoordinator,
                                 viewsExamplesCoordinator,
                                 monetizationCoordinator)
            .eraseToAnyPublisher()
    }
}
