//
//  UIAlertController+Rx.swift
//  SpotImCore
//
//  Created by Alon Haiut on 16/06/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import UIKit
import RxSwift

enum UIAlertType {
    case completion
    case selected(action: UIRxAlertAction)
}

extension Reactive where Base: UIAlertController {
    static func show(onViewController viewController: UIViewController,
                     animated: Bool = true,
                     preferredStyle: UIAlertController.Style = .alert,
                     title: String,
                     message: String,
                     actions: [UIRxAlertAction]) -> Observable<UIAlertType> {

        return Observable.create { observer in
            // Map to regular UIAlertAction
            let alertActions = actions.map { rxAlert in
                UIAlertAction(title: rxAlert.title,
                              style: rxAlert.style) { _ in
                    observer.onNext(.selected(action: rxAlert))
                    observer.onCompleted()
                }
            }

            // Create UIAlertController
            let alertVC = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
            // Add the actions to the alertVC
            alertActions.forEach { alertVC.addAction($0) }

            viewController.present(alertVC, animated: animated) {
                observer.onNext(.completion)
            }

            return Disposables.create()
        }
    }
}

struct UIRxAlertAction: Equatable {
    var uuid: String = UUID().uuidString
    let title: String
    let style: UIAlertAction.Style
}

extension UIRxAlertAction {
    static func == (lhs: UIRxAlertAction, rhs: UIRxAlertAction) -> Bool {
        return lhs.uuid == rhs.uuid
    }
}
