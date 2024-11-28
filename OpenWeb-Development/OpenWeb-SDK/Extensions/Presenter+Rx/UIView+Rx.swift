//
//  UIView+Rx.swift
//  OpenWebSDK
//
//  Created by Revital Pisman on 24/08/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

extension Reactive where Base: UIView {

    var isHiddenAnimated: Binder<Bool> {
        return Binder(self.base) { view, hidden in
            UIView.animate(withDuration: 0.25,
                           delay: 0,
                           usingSpringWithDamping: 0.7,
                           initialSpringVelocity: 0.5,
                           options: [],
                           animations: {
                view.transform = hidden ? CGAffineTransform(scaleX: 0.95, y: 0.95) : .identity
                view.isHidden = hidden
            })
        }
    }

    var didMoveToSuperview: ControlEvent<Void> {
        let source = self.methodInvoked(#selector(Base.didMoveToSuperview))
        return ControlEvent(events: source.voidify())
    }

    var bounds: Observable<CGRect> {
        return observeWeakly(CGRect.self, "bounds", options: [.new])
            .unwrap()
            .distinctUntilChanged()
    }

    var center: Observable<CGPoint> {
        return base.rx.observeWeakly(CGPoint.self, "center", options: [.new])
            .unwrap()
            .distinctUntilChanged()
    }

    var isHidden: Observable<Bool> {
        return base.rx.observeWeakly(Bool.self, "hidden", options: [.new])
            .unwrap()
            .distinctUntilChanged()
    }

    var alpha: Observable<CGFloat> {
        return base.rx.observeWeakly(CGFloat.self, "alpha", options: [.new])
            .unwrap()
            .distinctUntilChanged()
    }

    var clipsToBounds: Observable<Bool> {
        return base.rx.observeWeakly(Bool.self, "clipsToBounds", options: [.new])
            .unwrap()
            .distinctUntilChanged()
    }

    /// Change in any property that impacts visibility.
    ///
    /// - Note: Uses `bounds` instead of `frame` because it changes with animations like vc-dismiss and app-backgrounding.
    var didChangeVisibility: Observable<Void> {
        var visibiltyChanges: [Observable<Void>] = [
            isHidden.voidify(),
            alpha.voidify(),
            clipsToBounds.voidify()
        ]
        if !(base is UIScrollView) {
            visibiltyChanges += [bounds.voidify()]
        }
        return Observable.merge(visibiltyChanges)
    }
}
