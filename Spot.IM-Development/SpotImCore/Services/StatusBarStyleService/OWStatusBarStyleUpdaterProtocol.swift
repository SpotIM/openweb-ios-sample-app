//
//  OWStatusBarStyleUpdaterProtocol.swift
//  SpotImCore
//
//  Created by Alon Haiut on 01/08/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import UIKit
import RxSwift

protocol OWStatusBarStyleUpdaterProtocol {
    var disposeBag: DisposeBag { get }
    func setupStatusBarStyleUpdaterObservers()
}

extension OWStatusBarStyleUpdaterProtocol where Self: UIViewController {
    func setupStatusBarStyleUpdaterObservers() {
        OWSharedServicesProvider.shared.statusBarStyleService()
            .forceStatusBarUpdate
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.setNeedsStatusBarAppearanceUpdate()
            })
            .disposed(by: disposeBag)
    }
}
