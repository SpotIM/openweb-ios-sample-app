//
//  UIAlertController+Rx.swift
//  SpotImCore
//
//  Created by Alon Haiut on 16/06/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import UIKit
import RxSwift

extension Reactive where Base: UIAlertController {
    static func show(onViewController viewController: UIViewController,
                     animated: Bool = true,
                     preferredStyle: UIAlertController.Style = .alert,
                     title: String?,
                     message: String?,
                     actions: [OWRxPresenterAction]) -> Observable<OWRxPresenterResponseType> {

        return Observable.create { observer in
            // Map to regular UIAlertAction
            let alertActions = actions.map { rxAction in
                UIAlertAction(title: rxAction.title,
                              style: rxAction.style) { _ in
                    observer.onNext(.selected(action: rxAction))
                    observer.onCompleted()
                }
            }

            // Create UIAlertController
            let alertVC = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
            if let popoverController = alertVC.popoverPresentationController {
                // set the source of alert (crash on iPad) with no arrows
                popoverController.sourceView = viewController.view
                popoverController.sourceRect = CGRect(x: viewController.view.bounds.midX, y: viewController.view.bounds.midY, width: 0, height: 0)
                popoverController.permittedArrowDirections = []
            }
            // Add the actions to the alertVC
            alertActions.forEach { alertVC.addAction($0) }

            viewController.present(alertVC, animated: animated) {
                observer.onNext(.completion)
            }

            return Disposables.create()
        }
    }
}
