//
//  MonetizationViewsCoordinator.swift
//  OpenWeb-SampleApp
//
//  Created by Anael on 15/01/2025.
//

import Foundation
import Combine

class MonetizationViewsCoordinator: BaseCoordinator<Void> {

    private let router: Routering

    init(router: Routering) {
        self.router = router
    }

    override func start(deepLinkOptions: DeepLinkOptions? = nil,
                        coordinatorData: CoordinatorData? = nil) -> AnyPublisher<Void, Never> {
        guard let data = coordinatorData,
              case CoordinatorData.postId(let postId) = data else {
            fatalError("MonetizationViewsCoordinator requires coordinatorData from `CoordinatorData.postId` type")
        }

        let monetizationViewModel: MonetizationViewsViewModeling = MonetizationViewsViewModel(postId: postId)
        let monetizationVC = MonetizationViewsVC(viewModel: monetizationViewModel)

        let vcPopped = PassthroughSubject<Void, Never>()

        setupCoordinatorInternalNavigation(viewModel: monetizationViewModel)

        router.push(monetizationVC,
                    animated: true,
                    completion: vcPopped)

        return vcPopped
            .eraseToAnyPublisher()
    }
}

private extension MonetizationViewsCoordinator {
    func setupCoordinatorInternalNavigation(viewModel: MonetizationViewsViewModeling) {
        viewModel.outputs.openSingleAdExample
            .sink(receiveValue: { [weak self] postId in
                guard let self else { return }
                let singleAdExampleViewModel = SingleAdExampleViewModel(postId: postId)
                let singleAdExampleVC = SingleAdExampleVC(viewModel: singleAdExampleViewModel)
                self.router.push(singleAdExampleVC,
                                 animated: true,
                                 completion: nil)
            })
            .store(in: &cancellables)

        viewModel.outputs.openPreconversationWithAdExample
            .sink(
                receiveValue: { [weak self] dataModel in
                    guard let self else { return }
                    let coordinatorData = CoordinatorData.actionsViewSettings(data: dataModel)
                    guard case CoordinatorData.actionsViewSettings(let settings) = coordinatorData else {
                        fatalError("MonetizationViewsCoordinator requires coordinatorData from `CoordinatorData.actionsViewSettings` type")
                    }

                    let preconversationViewsWithAdVM: PreconversationViewsWithAdViewModeling = PreconversationViewsWithAdViewModel(
                        actionSettings: settings,
                        postId: dataModel.postId
                    )
                    let preconversationViewsWithAdVC = PreconversationViewsWithAdVC(viewModel: preconversationViewsWithAdVM)
                    self.router.push(preconversationViewsWithAdVC,
                                     animated: true,
                                     completion: nil)

                })
            .store(in: &cancellables)
    }
}
