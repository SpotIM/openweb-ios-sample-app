//
//  OWAnimationTransitioning.swift
//  SpotImCore
//
//  Created by Refael Sommer on 02/08/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import UIKit
import Foundation
import RxSwift

class OWPushOverFullScreenAnimationTransitioning: NSObject, UIViewControllerAnimatedTransitioning {
    fileprivate struct Metrics {
        static let transitionDuration: TimeInterval = 0.3
        static let orientationChangeDelay = 10
    }

    fileprivate let disposeBag = DisposeBag()
    fileprivate var viewFromOrientation: UIView?
    fileprivate var viewToOrientation: UIView?
    fileprivate var presenting: Bool = true

    override init() {
        super.init()
        setupObservers()
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return Metrics.transitionDuration
    }

    func presenting(_ presenting: Bool) -> OWPushOverFullScreenAnimationTransitioning {
        self.presenting = presenting
        return self
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)
        let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)
        guard let toView = transitionContext.view(forKey: .to) else { return }
        guard let vcTo = toViewController,
              let vcFrom = fromViewController else { return }
        let container = transitionContext.containerView
        if presenting {
            container.addSubview(vcTo.view)
            vcTo.view.alpha = 0.0
            UIView.animate(withDuration: self.transitionDuration(using: transitionContext),
                           animations: {
                vcTo.view.alpha = 1.0
            }, completion: { [weak self] _ in
                guard let self = self else { return }
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                container.insertSubview(vcFrom.view, belowSubview: vcTo.view)
                self.viewFromOrientation = vcFrom.view
                self.viewToOrientation = vcTo.view
            })
        } else {
            viewFromOrientation = nil
            viewToOrientation = nil
            vcFrom.view.alpha = 1.0
            UIView.animate(withDuration: self.transitionDuration(using: transitionContext),
                           animations: {
                vcFrom.view.alpha = 0.0
            }, completion: { _ in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            })
        }
    }
}

fileprivate extension OWPushOverFullScreenAnimationTransitioning {
    func setupObservers() {
        NotificationCenter.default.rx
            .notification(UIDevice.orientationDidChangeNotification)
            .delay(.milliseconds(Metrics.orientationChangeDelay), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                if let viewToOrientation = self.viewToOrientation,
                   let viewFromOrientation = self.viewFromOrientation {
                    viewFromOrientation.frame = viewToOrientation.frame
                }
            })
            .disposed(by: disposeBag)
    }
}
