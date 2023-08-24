//
//  UIView+Rx.swift
//  SpotImCore
//
//  Created by Revital Pisman on 24/08/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
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
}
