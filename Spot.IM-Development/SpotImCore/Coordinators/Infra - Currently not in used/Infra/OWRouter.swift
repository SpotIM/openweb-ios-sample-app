//
//  OWRouter.swift
//  SpotImCore
//
//  Created by Alon Haiut on 07/03/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import UIKit
import RxSwift

protocol OWRoutering {
    var navigationController: UINavigationController? { get }
    var rootViewController: UIViewController? { get }
    func present(_ module: OWPresentable, animated: Bool)
    func push(_ module: OWPresentable, animated: Bool, popCompletion: PublishSubject<Void>?)
    func pop(animated: Bool)
    func dismiss(animated: Bool, completion: PublishSubject<Void>?)
    func setRoot(_ module: OWPresentable, animated: Bool)
    func popToRoot(animated: Bool)
    func isEmpty() -> Bool
}

class OWRouter: NSObject, OWRoutering {

    fileprivate var completions: [UIViewController: PublishSubject<Void>]
    weak var navigationController: UINavigationController?
    
    var rootViewController: UIViewController? {
        return navigationController?.viewControllers.first
    }

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.completions = [:]
        super.init()
        self.navigationController?.delegate = self
    }

    func present(_ module: OWPresentable, animated: Bool) {
        navigationController?.present(module.toPresentable(),
                                     animated: animated,
                                     completion: nil)
    }

    func push(_ module: OWPresentable, animated: Bool, popCompletion: PublishSubject<Void>?) {
        if let completion = popCompletion {
            completions[module.toPresentable()] = completion
        }

        navigationController?.pushViewController(module.toPresentable(), animated: animated)
    }

    func pop(animated: Bool) {
        if let controller = navigationController?.popViewController(animated: animated) {
            runCompletion(for: controller)
        }
    }

    func dismiss(animated: Bool, completion: PublishSubject<Void>?) {
        navigationController?.dismiss(animated: animated) {
            completion?.onNext()
        }
    }

    func setRoot(_ module: OWPresentable, animated: Bool = false) {
        navigationController?.setViewControllers([module.toPresentable()], animated: animated)
    }

    func popToRoot(animated: Bool) {
        if let controllers = navigationController?.popToRootViewController(animated: animated) {
            controllers.forEach { runCompletion(for: $0) }
        }
    }
    
    func isEmpty() -> Bool {
        guard let navController = navigationController else { return true }
        
        let childs = navController.children
        return childs.isEmpty
    }
}

extension OWRouter: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        // Ensure the view controller is popping
        guard let poppedViewController = navigationController.transitionCoordinator?.viewController(forKey: .from), !navigationController.viewControllers.contains(poppedViewController) else {
            return
        }
        runCompletion(for: poppedViewController)
    }
}

fileprivate extension OWRouter {
    func runCompletion(for controller: UIViewController) {
        guard let completion = completions[controller] else {
            return
        }
        completion.onNext()
        completions.removeValue(forKey: controller)
    }
}
