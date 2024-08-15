//
//  TestingPlaygroundCoordinator.swift
//  OpenWeb-SampleApp
//
//  Created by Alon Haiut on 12/08/2024.
//  Copyright © 2024 OpenWeb. All rights reserved.
//

#if BETA

import Foundation
import RxSwift

class TestingPlaygroundCoordinator: BaseCoordinator<Void> {

    fileprivate let router: Routering

    init(router: Routering) {
        self.router = router
    }

    override func start(deepLinkOptions: DeepLinkOptions? = nil,
                        coordinatorData: CoordinatorData? = nil) -> Observable<Void> {

        guard let data = coordinatorData,
              case CoordinatorData.conversationDataModel(let conversationDataModel) = data else {
            fatalError("TestingPlaygroundCoordinator requires coordinatorData from `CoordinatorData.conversationDataModel` type")
        }

        let testingPlaygroundVM: TestingPlaygroundViewModeling = TestingPlaygroundViewModel(dataModel: conversationDataModel)
        let testingPlaygroundVC = TestingPlaygroundVC(viewModel: testingPlaygroundVM)

        let vcPopped = PublishSubject<Void>()

        setupCoordinatorInternalNavigation(viewModel: testingPlaygroundVM)

        router.push(testingPlaygroundVC,
                    animated: true,
                    completion: vcPopped)

        return vcPopped
            .asObservable()
    }
}

fileprivate extension TestingPlaygroundCoordinator {
    func setupCoordinatorInternalNavigation(viewModel: TestingPlaygroundViewModeling) {
        viewModel.outputs.openTestingPlaygroundIndependent
            .subscribe(onNext: { [weak self] dataModel in
                guard let self = self else { return }
                let testingPlaygroundIndependentVM = TestingPlaygroundIndependentViewModel(dataModel: dataModel)
                let testingPlaygroundIndependentVC = TestingPlaygroundIndependentViewVC(viewModel: testingPlaygroundIndependentVM)
                self.router.push(testingPlaygroundIndependentVC,
                            animated: true,
                            completion: nil)
            })
            .disposed(by: disposeBag)
    }
}

#endif
