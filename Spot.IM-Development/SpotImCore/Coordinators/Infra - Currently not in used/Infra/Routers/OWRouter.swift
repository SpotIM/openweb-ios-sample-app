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
    func start()
    func present(_ module: OWPresentable, animated: Bool, dismissCompletion: PublishSubject<Void>?)
    func push(_ module: OWPresentable, pushStyle: OWScreenPushStyle, animated: Bool, popCompletion: PublishSubject<Void>?)
    func setRoot(_ module: OWPresentable, animated: Bool, dismissCompletion: PublishSubject<Void>?)
    func pop(animated: Bool)
    func dismiss(animated: Bool, completion: PublishSubject<Void>?)
    func popToRoot(animated: Bool)
    func isEmpty() -> Bool
}

class OWRouter: NSObject, OWRoutering {

    fileprivate var completions: [UIViewController: PublishSubject<Void>]
    weak var navigationController: UINavigationController?
    fileprivate let presentationalMode: OWPresentationalModeExtended
    fileprivate var navDisposedBag: DisposeBag!

    var rootViewController: UIViewController? {
        return navigationController?.viewControllers.first
    }

    init(navigationController: UINavigationController, presentationalMode: OWPresentationalModeExtended) {
        self.navigationController = navigationController
        self.completions = [:]
        self.presentationalMode = presentationalMode
        super.init()
        self.navigationController?.delegate = self
        if let sdkNavigationController = self.navigationController as? OWNavigationControllerProtocol {
            setupSDKNavigationObserver(navigationController: sdkNavigationController)
        }
    }

    func start() {
        guard let navigationController = navigationController else { return }
        switch presentationalMode {
        case .present(let viewController, _, let animated):
            viewController.present(navigationController, animated: animated)
        case .push(_):
            // Already handled in coordinator
            break
        }
    }

    func present(_ module: OWPresentable, animated: Bool, dismissCompletion: PublishSubject<Void>?) {
        if let completion = dismissCompletion {
            completions[module.toPresentable()] = completion
        }
        navigationController?.present(module.toPresentable(),
                                     animated: animated,
                                     completion: nil)
    }

    func push(_ module: OWPresentable, pushStyle: OWScreenPushStyle = .regular, animated: Bool, popCompletion: PublishSubject<Void>?) {
        if let completion = popCompletion {
            completions[module.toPresentable()] = completion
        }

        switch pushStyle {
        case .regular:
            navigationController?.pushViewController(module.toPresentable(), animated: animated)
        case .presentStyle:
            let transition = CATransition()
            transition.duration = 0.5
            transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            transition.type = .moveIn
            transition.subtype = .fromTop
            navigationController?.view.layer.add(transition, forKey: kCATransition)
            navigationController?.pushViewController(module.toPresentable(), animated: false)
        }
    }

    func setRoot(_ module: OWPresentable, animated: Bool = false, dismissCompletion: PublishSubject<Void>?) {
        if let completion = dismissCompletion {
            completions[module.toPresentable()] = completion
        }
        navigationController?.setViewControllers([module.toPresentable()], animated: animated)
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
        guard let poppedViewController = navigationController.transitionCoordinator?.viewController(forKey: .from),
                !navigationController.viewControllers.contains(poppedViewController) else {
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

    func setupSDKNavigationObserver(navigationController: OWNavigationControllerProtocol) {
        navDisposedBag = DisposeBag()

        navigationController.dismissed
            .subscribe(onNext: { [ weak self] _ in
                guard let self = self,
                      let navController = navigationController as? UINavigationController else { return }
                let childs = navController.children.reversed()
                childs.forEach { self.runCompletion(for: $0) }
                navigationController.clear()
            })
            .disposed(by: navDisposedBag)
    }
}
