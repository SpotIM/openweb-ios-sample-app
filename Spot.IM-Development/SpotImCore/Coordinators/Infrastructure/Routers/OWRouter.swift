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
    var numberOfActiveViewControllers: Int { get }
    func start()
    func present(_ module: OWPresentable, animated: Bool, dismissCompletion: PublishSubject<Void>?)
    func push(_ module: OWPresentable, pushStyle: OWScreenPushStyle, animated: Bool, popCompletion: PublishSubject<Void>?)
    func setRoot(_ module: OWPresentable, animated: Bool, dismissCompletion: PublishSubject<Void>?)
    func pop(popStyle: OWScreenPopStyle, animated: Bool)
    func pop(toViewController: UIViewController, animated: Bool)
    func dismiss(animated: Bool, completion: PublishSubject<Void>?)
    func popToRoot(animated: Bool)
    func isEmpty() -> Bool

    func setCompletion(for vc: UIViewController, dismissCompletion: PublishSubject<Void>)
}

extension OWRoutering {
    func pop(popStyle: OWScreenPopStyle = .regular, animated: Bool) {
        pop(popStyle: popStyle, animated: animated)
    }

    func present(_ module: OWPresentable, presentStyle: OWScreenPresentStyle = .regular, animated: Bool = false, dismissCompletion: PublishSubject<Void>?) {
        switch presentStyle {
        case .regular:
            present(module, animated: animated, dismissCompletion: dismissCompletion)
        case .fade:
            let viewController = module.toPresentable()
            viewController.modalTransitionStyle = .crossDissolve
            viewController.modalPresentationStyle = .overFullScreen
            present(module, animated: true, dismissCompletion: dismissCompletion)
        }
    }

    func dismiss(animated: Bool = false, dismissStyle: OWScreenPresentStyle = .regular, completion: PublishSubject<Void>?) {
        switch dismissStyle {
        case .regular:
            dismiss(animated: animated, completion: completion)
        case .fade:
            dismiss(animated: true, completion: completion)
        }
    }
}

class OWRouter: NSObject, OWRoutering {
    fileprivate struct Metrics {
        static let transitionDuration = 0.5
        static let childAnimationDuration = 0.3
    }
    fileprivate var completions: [UIViewController: PublishSubject<Void>]
    fileprivate var pushedVCStyles: [UIViewController: OWScreenPushStyle]
    weak var navigationController: UINavigationController?
    fileprivate var presentationalMode: OWPresentationalModeExtended
    fileprivate var navDisposedBag: DisposeBag!
    fileprivate lazy var pushOverFullScreenAnimationTransitioning = OWPushOverFullScreenAnimationTransitioning()
    var rootViewController: UIViewController? {
        return navigationController?.viewControllers.first
    }

    init(navigationController: UINavigationController, presentationalMode: OWPresentationalModeExtended) {
        self.navigationController = navigationController
        self.completions = [:]
        self.pushedVCStyles = [:]
        self.presentationalMode = presentationalMode
        super.init()
        self.navigationController?.delegate = self
        if let sdkNavigationController = self.navigationController as? OWNavigationControllerProtocol {
            setupSDKNavigationObserver(navigationController: sdkNavigationController)
        }
    }

    func setCompletion(for vc: UIViewController, dismissCompletion: PublishSubject<Void>) {
        completions[vc] = dismissCompletion
    }

    func start() {
        guard let navigationController = navigationController else { return }
        switch presentationalMode {
        case .present(let viewControllerWeakEncapsulation, _, let animated):
            viewControllerWeakEncapsulation.value()?.present(navigationController, animated: animated)
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
        case .present:
            let transition = CATransition()
            transition.duration = Metrics.transitionDuration
            transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            transition.type = .moveIn
            transition.subtype = .fromTop
            navigationController?.view.layer.add(transition, forKey: kCATransition)
            navigationController?.pushViewController(module.toPresentable(), animated: false)
        case .presentOverFullScreen:
            pushedVCStyles[module.toPresentable()] = .presentOverFullScreen
            navigationController?.pushViewController(module.toPresentable(), animated: animated)
        case .addAsChild:
            guard let viewController = navigationController?.viewControllers.last else { return }
            let presentable = module.toPresentable()
            viewController.addChild(presentable)
            viewController.view.addSubview(presentable.view)
            presentable.view.OWSnp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
            presentable.didMove(toParent: viewController)
            if animated {
                presentable.view.alpha = 0
                UIView.animate(withDuration: Metrics.childAnimationDuration) {
                    presentable.view.alpha = 1
                }
            }
        }
    }

    func setRoot(_ module: OWPresentable, animated: Bool = false, dismissCompletion: PublishSubject<Void>?) {
        if let completion = dismissCompletion {
            completions[module.toPresentable()] = completion
        }
        navigationController?.setViewControllers([module.toPresentable()], animated: animated)
    }

    func pop(popStyle: OWScreenPopStyle, animated: Bool) {
        switch popStyle {
        case .regular, .dismissOverFullScreen:
            if let controller = navigationController?.popViewController(animated: animated) {
                runCompletion(for: controller)
            }
        case .dismiss:
            let transition = CATransition()
            transition.duration = Metrics.transitionDuration
            transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            transition.type = .reveal
            transition.subtype = .fromBottom
            navigationController?.view.layer.add(transition, forKey: kCATransition)
            if let controller = navigationController?.popViewController(animated: false) {
                runCompletion(for: controller)
            }
        case .removeChild:
            guard let viewController = navigationController?.viewControllers.last?.children.first else { return }
            if animated {
                UIView.animate(withDuration: Metrics.childAnimationDuration) {
                    viewController.view.alpha = 0
                } completion: { [weak self] _ in
                    viewController.willMove(toParent: nil)
                    viewController.removeFromParent()
                    viewController.view.removeFromSuperview()
                    self?.runCompletion(for: viewController)
                }
            } else {
                viewController.willMove(toParent: nil)
                viewController.removeFromParent()
                viewController.view.removeFromSuperview()
                runCompletion(for: viewController)
            }
        }
    }

    func pop(toViewController: UIViewController, animated: Bool) {
        if let controllers = navigationController?.popToViewController(toViewController, animated: animated) {
            for controller in controllers {
                runCompletion(for: controller)
            }
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

    var numberOfActiveViewControllers: Int {
        return navigationController?.viewControllers.count ?? 0
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

    func navigationController(_ navigationController: UINavigationController,
                              animationControllerFor operation: UINavigationController.Operation,
                              from fromVC: UIViewController,
                              to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if operation == .push {
            if let style = pushedVCStyles[toVC],
               style == .presentOverFullScreen {
                toVC.title = fromVC.title
                return pushOverFullScreenAnimationTransitioning.presenting(true)
            }
        } else {
            if let style = pushedVCStyles[fromVC],
               style == .presentOverFullScreen {
                pushedVCStyles.removeValue(forKey: fromVC)
                return pushOverFullScreenAnimationTransitioning.presenting(false)
            }
        }
        return nil
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
                childs.forEach { [weak self] in
                    self?.runCompletion(for: $0)
                }
                navigationController.clear()
            })
            .disposed(by: navDisposedBag)
    }
}
