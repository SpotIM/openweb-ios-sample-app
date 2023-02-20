//
//  OWThemeStyleService.swift
//  SpotImCore
//
//  Created by Alon Haiut on 08/03/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

/*
 Im aware of `SPUserInterfaceStyle` enum.
 I still decided that internally we will use a new enum which will make us one step closer to eventually support a better API.
 Internally we will convert the enum from the old API as long as we will support it
*/

import Foundation
import RxSwift

protocol OWThemeStyleServicing {
    func setEnforcement(enforcement: OWThemeStyleEnforcement)
    func setStyle(style: OWThemeStyle)
    var style: Observable<OWThemeStyle> { get }
    var currentStyle: OWThemeStyle { get } // Non RX way to retrieve the current style as sometimes it might be required
}

class OWThemeStyleService: OWThemeStyleServicing {
    fileprivate let _style = BehaviorSubject<OWThemeStyle>(value: .light)
    fileprivate var _currentStyle: OWThemeStyle = .light
    fileprivate var _enforcement: OWThemeStyleEnforcement = .none
    fileprivate let disposeBag = DisposeBag()

    init() {
        setupObservers()
    }

    func setEnforcement(enforcement: OWThemeStyleEnforcement) {
        _enforcement = enforcement

        if case let OWThemeStyleEnforcement.theme(style) = enforcement {
            _style.onNext(style)
        }
    }

    func setStyle(style: OWThemeStyle) {
        // No need to log anything in case the enforcement is not none, as it's very common that traitCollection will change but we will not actually change the style
        if _enforcement == .none {
            _style.onNext(style)
        }
    }

    lazy var style: Observable<OWThemeStyle> = {
        return _style
            .asObservable()
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .share(replay: 1)
    }()

    var currentStyle: OWThemeStyle {
        return _currentStyle
    }
}

fileprivate extension OWThemeStyleService {
    func setupObservers() {
        style
            .subscribe(onNext: { [weak self] themeStyle in
                self?._currentStyle = themeStyle
            })
            .disposed(by: disposeBag)
    }
}

