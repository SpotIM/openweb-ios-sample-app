//
//  MonetizationCoordinator.swift
//  OpenWeb-SampleApp
//
//  Created by Anael on 25/11/2024.
//

import RxSwift

class MonetizationCoordinator: BaseCoordinator<Void> {

    private let router: Routering

    init(router: Routering) {
        self.router = router
    }

    override func start(deepLinkOptions: DeepLinkOptions? = nil,
                        coordinatorData: CoordinatorData? = nil) -> Observable<Void> {
        guard let data = coordinatorData,
              case CoordinatorData.postId(let postId) = data else {
            fatalError("MonetizationCoordinator requires coordinatorData from `CoordinatorData.postId` type")
        }

        let monetizationViewModel: MonetizationViewViewModeling = MonetizationViewViewModel(postId: postId)
        let monetizationVC = MonetizationViewVC(viewModel: monetizationViewModel)

        let vcPopped = PublishSubject<Void>()

        setupCoordinatorInternalNavigation(viewModel: monetizationViewModel)

        router.push(monetizationVC,
                    animated: true,
                    completion: vcPopped)

        return vcPopped
            .asObservable()
    }
}

private extension MonetizationCoordinator {
    func setupCoordinatorInternalNavigation(viewModel: MonetizationViewViewModeling) {
        viewModel.outputs.openSingleAdExample
            .subscribe(onNext: { [weak self] postId in
                guard let self else { return }
                let singleAdExampleViewModel = SingleAdExampleViewModel(postId: postId)
                let singleAdExampleVC = SingleAdExampleVC(viewModel: singleAdExampleViewModel)
                self.router.push(singleAdExampleVC,
                                 animated: true,
                                 completion: nil)
            })
            .disposed(by: disposeBag)

        viewModel.outputs.openMockArticleScreen
            .subscribe(
                onNext: { [weak self] dataModel in
                    guard let self else { return }
                    let coordinatorData = CoordinatorData.actionsFlowSettings(data: dataModel)
                    guard case CoordinatorData.actionsFlowSettings(let settings) = coordinatorData else {
                        fatalError("MockArticleCoordinator requires coordinatorData from `CoordinatorData.actionsFlowSettings` type")
                    }

                    let PreconversationWithAdVM: PreconversationWithAdViewModeling = PreconversationWithAdViewModel(
                        actionSettings: settings,
                        postId: dataModel.postId
                    )
                let PreconversationWithAdVC = PreconversationWithAdVC(viewModel: PreconversationWithAdVM)
                self.router.push(PreconversationWithAdVC,
                                 animated: true,
                                 completion: nil)

                })
            .disposed(by: disposeBag)

    }
}
