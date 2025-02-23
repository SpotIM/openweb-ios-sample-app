//
//  MonetizationViewsCoordinator.swift
//  OpenWeb-SampleApp
//
//  Created by Anael on 15/01/2025.
//

import Foundation
import RxSwift

class MonetizationViewsCoordinator: BaseCoordinator<Void> {

    private let router: Routering

    init(router: Routering) {
        self.router = router
    }

    override func start(deepLinkOptions: DeepLinkOptions? = nil,
                        coordinatorData: CoordinatorData? = nil) -> Observable<Void> {
        guard let data = coordinatorData,
              case CoordinatorData.postId(let postId) = data else {
            fatalError("MonetizationViewsCoordinator requires coordinatorData from `CoordinatorData.postId` type")
        }

        let monetizationViewModel: MonetizationViewsViewModeling = MonetizationViewsViewModel(postId: postId)
        let monetizationVC = MonetizationViewsVC(viewModel: monetizationViewModel)

        let vcPopped = PublishSubject<Void>()

        setupCoordinatorInternalNavigation(viewModel: monetizationViewModel)

        router.push(monetizationVC,
                    animated: true,
                    completion: vcPopped)

        return vcPopped
            .asObservable()
    }
}

private extension MonetizationViewsCoordinator {
    func setupCoordinatorInternalNavigation(viewModel: MonetizationViewsViewModeling) {
        viewModel.outputs.openSingleAdExample
            .asObservable()
            .subscribe(onNext: { [weak self] postId in
                guard let self else { return }
                let singleAdExampleViewModel = SingleAdExampleViewModel(postId: postId)
                let singleAdExampleVC = SingleAdExampleVC(viewModel: singleAdExampleViewModel)
                self.router.push(singleAdExampleVC,
                                 animated: true,
                                 completion: nil)
            })
            .disposed(by: disposeBag)

        viewModel.outputs.openPreconversationWithAdExample
            .asObservable()
            .subscribe(
                onNext: { [weak self] dataModel in
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
            .disposed(by: disposeBag)
    }
}
