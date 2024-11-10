//
//  UIViewController+Rx.swift
//  OpenWebSDK
//
//  Created by Yonat Sharon on 04/11/2024.
//  Copyright © 2024 OpenWeb. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

extension Reactive where Base: UIViewController {
    var viewDidAppear: ControlEvent<Void> {
        let source = self.methodInvoked(#selector(Base.viewDidAppear))
        return ControlEvent(events: source.voidify())
    }

    var viewWillDisappear: ControlEvent<Void> {
        let source = self.methodInvoked(#selector(Base.viewWillDisappear))
        return ControlEvent(events: source.voidify())
    }
}
