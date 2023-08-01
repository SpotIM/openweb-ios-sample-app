//
//  OWStatusBarStyleService.swift
//  SpotImCore
//
//  Created by Alon Haiut on 01/08/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import UIKit
import RxSwift

protocol OWStatusBarStyleServicing {
    func setEnforcement(enforcement: OWStatusBarEnforcement)
    var currentStyle: UIStatusBarStyle { get }
    var forceStatusBarUpdate: Observable<Void> { get }
}

class OWStatusBarStyleService: OWStatusBarStyleServicing {
    fileprivate unowned let servicesProvider: OWSharedServicesProviding
    fileprivate var _currentStyle: UIStatusBarStyle = .default
    fileprivate let _forceStatusBarUpdate = PublishSubject<Void>()
    fileprivate var _enforcement: OWStatusBarEnforcement = .matchTheme
    fileprivate let disposeBag = DisposeBag()

    init(servicesProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared) {
        self.servicesProvider = servicesProvider
    }

    func setEnforcement(enforcement: OWStatusBarEnforcement) {
        _enforcement = enforcement

        if case let OWStatusBarEnforcement.style(style) = enforcement {
            _currentStyle = style
            _forceStatusBarUpdate.onNext(())
        }
    }

    var currentStyle: UIStatusBarStyle {
        return _currentStyle
    }

    var forceStatusBarUpdate: Observable<Void> {
        return _forceStatusBarUpdate
            .asObservable()
    }
}

fileprivate extension OWStatusBarStyleService {
    func setupObservers() {
        let themeService = servicesProvider.themeStyleService()

        themeService.style
            .subscribe(onNext: { [weak self] themeStyle in
                guard let self = self,
                        self._enforcement == .matchTheme else { return }

                self._currentStyle = UIStatusBarStyle(reverseFrom: themeStyle)
                self._forceStatusBarUpdate.onNext(())
            })
            .disposed(by: disposeBag)
    }
}
