//
//  TestAPICoordinator.swift
//  OpenWeb-SampleApp
//
//  Created by Alon Haiut on 07/08/2024.
//  Copyright © 2024 OpenWeb. All rights reserved.
//

import Foundation
import RxSwift

class TestAPICoordinator: BaseCoordinator<Void> {

    fileprivate let router: Routering

    init(router: Routering) {
        self.router = router
    }

    override func start(deepLinkOptions: DeepLinkOptions? = nil) -> Observable<Void> {
        let testAPIVM: TestAPIViewModeling = TestAPIViewModel()
        let testAPIVC = TestAPIVC(viewModel: testAPIVM)

        let vcPopped = PublishSubject<Void>()

        router.push(testAPIVC,
                    animated: true,
                    completion: vcPopped)

        return vcPopped
            .asObservable()
    }
}
