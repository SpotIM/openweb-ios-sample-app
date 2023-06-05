//
//  UIActivityViewController+Rx.swift
//  SpotImCore
//
//  Created by Alon Shprung on 05/06/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

extension Reactive where Base: UIActivityViewController {
    static func show(
        onViewController viewController: UIViewController,
        animated: Bool = true,
        activityItems: [Any],
        applicationActivities: [UIActivity]? = nil
    ) -> Observable<OWRxPresenterResponseType>  {

        return Observable.create { observer in
            // Create UIActivityViewController
            let activityVC = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
            viewController.present(activityVC, animated: animated) {
                observer.onNext(.completion)
            }

            return Disposables.create()
        }
    }
    }
