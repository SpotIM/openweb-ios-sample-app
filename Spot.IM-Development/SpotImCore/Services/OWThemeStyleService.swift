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
    func setStyle(style: OWThemeStyle)
    var style: Observable<OWThemeStyle> { get }
}

class OWThemeStyleService: OWThemeStyleServicing {
    fileprivate let _style = BehaviorSubject<OWThemeStyle>(value: .light)
    
    func setStyle(style: OWThemeStyle) {
        _style.onNext(style)
    }
    
    lazy var style: Observable<OWThemeStyle> = {
        return _style
            .asObservable()
            .share(replay: 1)
    }()
}

