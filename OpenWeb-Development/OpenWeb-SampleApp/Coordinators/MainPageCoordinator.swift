//
//  MainPageCoordinator.swift
//  OpenWeb-SampleApp
//
//  Created by Alon Haiut on 07/08/2024.
//  Copyright © 2024 OpenWeb. All rights reserved.
//

import Foundation
import RxSwift

class MainPageCoordinator: BaseCoordinator<Void> {

    fileprivate let router: Routering

    init(router: Routering) {
        self.router = router
    }

    override func start(deepLinkOptions: DeepLinkOptions? = nil) -> Observable<Void> {
        let mainPageVM: MainPageViewModeling = MainPageViewModel()
        let mainPageVC = mainPageVC(viewModel: mainPageVM)
        router.setRoot(mainPageVC)

        let aboutCoordinator = mainPageVM.outputs.showAbout
            .flatMap { [weak self] _ -> Observable<Void> in
                guard let self = self else { return .empty() }
                let coordinator = AboutCoordinator(router: self.router)
                return self.coordinate(to: coordinator)
            }

        let testAPICoordinator = mainPageVM.outputs.testAPI
            .flatMap { [weak self] _ -> Observable<Void> in
                guard let self = self else { return .empty() }
                let coordinator = TestAPICoordinator(router: self.router)
                return self.coordinate(to: coordinator)
            }

        return Observable.merge(aboutCoordinator, testAPICoordinator)
            .flatMap { _ -> Observable<Void> in
                // We always showing the main demo screen, that's why we return never here.
                return .never()
            }
    }
}
