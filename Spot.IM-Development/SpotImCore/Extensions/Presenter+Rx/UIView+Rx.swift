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
            UIView.animate(withDuration: 0.1, animations: {
                view.alpha = hidden ? 0 : 1
            }) { _ in
                view.isHidden = hidden
            }
        }
    }
}
