//
//  MonetizationFlowsCoordinator.swift
//  OpenWeb-SampleApp
//
//  Created by Anael on 25/11/2024.
//

import Combine

class MonetizationFlowsCoordinator: BaseCoordinator<Void> {

    private let router: Routering

    init(router: Routering) {
        self.router = router
    }

    override func start(deepLinkOptions: DeepLinkOptions? = nil,
                        coordinatorData: CoordinatorData? = nil) -> AnyPublisher<Void, Never> {
        guard let data = coordinatorData,
              case CoordinatorData.postId(let postId) = data else {
            fatalError("MonetizationFlowsCoordinator requires coordinatorData from `CoordinatorData.postId` type")
        }

        let monetizationViewModel: MonetizationFlowsViewModeling = MonetizationFlowsViewModel(postId: postId)
        let monetizationVC = MonetizationFlowsVC(viewModel: monetizationViewModel)

        let vcPopped = PassthroughSubject<Void, Never>()

        setupCoordinatorInternalNavigation(viewModel: monetizationViewModel)

        router.push(monetizationVC,
                    animated: true,
                    completion: vcPopped)

        return vcPopped
            .eraseToAnyPublisher()
    }
}

private extension MonetizationFlowsCoordinator {
    func setupCoordinatorInternalNavigation(viewModel: MonetizationFlowsViewModeling) {
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
                    let coordinatorData = CoordinatorData.actionsFlowSettings(data: dataModel)
                    guard case CoordinatorData.actionsFlowSettings(let settings) = coordinatorData else {
                        fatalError("MonetizationFlowsCoordinator requires coordinatorData from `CoordinatorData.actionsFlowSettings` type")
                    }

                    let preconversationFlowsWithAdVM: PreconversationFlowsWithAdViewModeling = PreconversationFlowsWithAdViewModel(
                        actionSettings: settings,
                        postId: dataModel.postId
                    )
                    let preconversationFlowsWithAdVC = PreconversationFlowsWithAdVC(viewModel: preconversationFlowsWithAdVM)
                    self.router.push(preconversationFlowsWithAdVC,
                                     animated: true,
                                     completion: nil)
                }
            )
            .store(in: &cancellables)
    }
}
