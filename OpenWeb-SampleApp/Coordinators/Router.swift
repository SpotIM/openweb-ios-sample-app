//
//  Router.swift
//  OpenWeb-iOS-SDK-Demo
//
//  Created by Alon Haiut on 29/11/2021.
//

import Foundation
import UIKit
import Combine

protocol Routering {
    var navigationController: UINavigationController { get }
    var rootViewController: UIViewController? { get }
    func present(_ module: Presentable, animated: Bool)
    func push(_ module: Presentable, animated: Bool, completion: PassthroughSubject<Void, Never>?)
    func pop(animated: Bool)
    func dismiss(animated: Bool, completion: PassthroughSubject<Void, Never>?)
    func setRoot(_ module: Presentable)
    func popToRoot(animated: Bool)
}

class Router: NSObject, Routering {

    private var completions: [UIViewController: PassthroughSubject<Void, Never>]
    unowned let navigationController: UINavigationController
    var rootViewController: UIViewController? {
        return navigationController.viewControllers.first
    }

    public init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.completions = [:]
        super.init()
        self.navigationController.delegate = self
    }

    func present(_ module: Presentable, animated: Bool) {
        navigationController.present(module.toPresentable(),
                                     animated: animated,
                                     completion: nil)
    }

    func push(_ module: Presentable,
              animated: Bool,
              completion: PassthroughSubject<Void, Never>?) {
        guard module.toPresentable() is UINavigationController == false else {
                return
        }

        if let completion {
            completions[module.toPresentable()] = completion
        }

        navigationController.pushViewController(module.toPresentable(), animated: animated)
    }

    func pop(animated: Bool) {
        if let controller = navigationController.popViewController(animated: animated) {
            runCompletion(for: controller)
        }
    }

    func dismiss(animated: Bool, completion: PassthroughSubject<Void, Never>?) {
        navigationController.dismiss(animated: animated) {
            completion?.send()
        }
    }

    func setRoot(_ module: Presentable) {
        navigationController.setViewControllers([module.toPresentable()], animated: false)
    }

    func popToRoot(animated: Bool) {
        if let controllers = navigationController.popToRootViewController(animated: animated) {
            controllers.forEach { runCompletion(for: $0) }
        }
    }
}

extension Router: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        // Ensure the view controller is popping
        // swiftlint:disable line_length
        guard let poppedViewController = navigationController.transitionCoordinator?.viewController(forKey: .from), !navigationController.viewControllers.contains(poppedViewController) else {
            return
        }
        // swiftlint:enable line_length
        runCompletion(for: poppedViewController)
    }
}

private extension Router {
    func runCompletion(for controller: UIViewController) {
        guard let completion = completions[controller] else {
            return
        }
        completion.send()
        completions.removeValue(forKey: controller)
    }
}
