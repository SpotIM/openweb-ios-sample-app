//
//  OWNavigationPlaceholderViewModel.swift
//  OpenWebSDK
//
//  Created by  Nogah Melamed on 14/11/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

protocol OWNavigationPlaceholderViewModelingInputs {
    func viewControllerAttached(vc: UIViewController)
}

protocol OWNavigationPlaceholderViewModelingOutputs {
}

protocol OWNavigationPlaceholderViewModeling {
    var inputs: OWNavigationPlaceholderViewModelingInputs { get }
    var outputs: OWNavigationPlaceholderViewModelingOutputs { get }
}

class OWNavigationPlaceholderViewModel: OWNavigationPlaceholderViewModeling,
                                        OWNavigationPlaceholderViewModelingInputs,
                                        OWNavigationPlaceholderViewModelingOutputs {

    var inputs: OWNavigationPlaceholderViewModelingInputs { return self }
    var outputs: OWNavigationPlaceholderViewModelingOutputs { return self }

    private struct Metrics {
        static let intervalForObservingNewVC = 300
    }

    private weak var vc: UIViewController?
    private let onFirstActualVC: (_ vc: UIViewController) -> Void
    private var disposeBag = DisposeBag()
    private let scheduler: SchedulerType = SerialDispatchQueueScheduler(qos: .background, internalSerialQueueName: "OWNavigationPlaceholderViewModel")

    init(onFirstActualVC: @escaping (_ vc: UIViewController) -> Void) {
        self.onFirstActualVC = onFirstActualVC
    }

    func viewControllerAttached(vc: UIViewController) {
        self.vc = vc

        setupObservers()
    }
}

private extension OWNavigationPlaceholderViewModel {
    func setupObservers() {
        Observable<Int>
            .interval(.milliseconds(Metrics.intervalForObservingNewVC), scheduler: scheduler)
            .observe(on: scheduler)
            .map { [weak self] _ -> Bool in
                // Make sure vc exist before checking its navigation controller
                guard let self,
                      let _ = self.vc else { return false }
                return true
            }
            .filter { $0 }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                guard let self,
                      let vc = self.vc else { return }

                if let topVC = vc.navigationController?.topViewController, topVC != vc {
                    self.onFirstActualVC(topVC)
                    // Once new VC added no need to have this empty VC so it is removed
                    if var viewControllers = vc.navigationController?.viewControllers,
                       let index = viewControllers.firstIndex(of: vc) {
                        viewControllers.remove(at: index)
                        vc.navigationController?.viewControllers = viewControllers
                    }
                    vc.dismiss(animated: false)
                    // Ending the subscription
                    self.disposeBag = DisposeBag()
                }
            })
            .disposed(by: disposeBag)
    }
}
