//
//  UIMenu+RX.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 25/04/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

@available(iOS 14.0, *)
extension Reactive where Base: UIMenu {
    static func show(onButton button: UIButton,
                     animated: Bool = true,
                     actions: [UIRxAction]) -> Observable<UIAlertType> {
        return Observable.create { observer in
            // Map to regular UIAction
            let menuItems = actions.map { rxAlert in
                var attributes: UIMenuElement.Attributes = []
                if rxAlert.disabeled {
                    attributes = .disabled
                }
                if rxAlert.destructive {
                    attributes = .destructive
                }
                return UIAction(
                    title: rxAlert.title,
                    attributes: attributes,
                    state: rxAlert.selected ? .on : .off
                ) { _ in
                    observer.onNext(.selected(action: rxAlert))
                    observer.onCompleted()
                }
            }
            var menu: UIMenu {
                return UIMenu(identifier: nil, options: [], children: menuItems)
            }
            button.menu = menu
            button.showsMenuAsPrimaryAction = true
            return Disposables.create()
        }
    }
}
