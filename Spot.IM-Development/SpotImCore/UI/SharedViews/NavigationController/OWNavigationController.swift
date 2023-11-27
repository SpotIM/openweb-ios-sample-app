//
//  OWNavigationController.swift
//  SpotImCore
//
//  Created by Alon Haiut on 08/09/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import UIKit
import RxSwift

protocol OWNavigationControllerProtocol {
    var dismissed: Observable<Void> { get }
    func clear()
}

class OWNavigationController: UINavigationController, OWNavigationControllerProtocol {

    // We need to create a shared nav controller so it will stay in the memory, Router layer "holds" nav controller in a weak reference
    static let shared: OWNavigationController = {
        let navController = OWNavigationController()
        return navController
    }()

    fileprivate let _dismissed = PublishSubject<Void>()
    var dismissed: Observable<Void> {
        return _dismissed
            .asObservable()
    }

    func clear() {
        self.setViewControllers([], animated: false)
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        if let topVC = topViewController {
            return topVC.preferredStatusBarStyle
        } else {
            let statusBarService = OWSharedServicesProvider.shared.statusBarStyleService()
            return statusBarService.currentStyle
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if isBeingDismissed {
            _dismissed.onNext()
        }
    }

    override func popViewController(animated: Bool) -> UIViewController? {
        let vcCount = viewControllers.count
        let poppedVC = super.popViewController(animated: animated)
        // Dismiss the navigation controller if it's empty
        if vcCount == 1 {
            dismiss(animated: animated, completion: nil)
        }
        return poppedVC
    }
}
