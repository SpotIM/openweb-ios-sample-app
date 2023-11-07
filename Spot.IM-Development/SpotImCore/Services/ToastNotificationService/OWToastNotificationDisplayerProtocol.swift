//
//  OWToastNotificationDisplayerProtocol.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 12/09/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

protocol OWToastNotificationDisplayerProtocol {
    mutating func displayToast(requiredData: OWToastRequiredData, actionCompletion: PublishSubject<Void>)
    func dismissToast()
    var toastView: OWToastView? { get set }
    var panGesture: UIPanGestureRecognizer { get set }
    var disposeBag: DisposeBag { get }
}

struct ToastMetrics {
    fileprivate static var bottomOffsetForAnimation: CGFloat = 50
    static var animationDuration: TimeInterval = 0.5

    fileprivate static let swipeThresholdToDismiss: CGFloat = 50
    fileprivate static let swipeMagnetAnimationDuration: CGFloat = 0.3
}

extension OWToastNotificationDisplayerProtocol where Self: UIView {

    mutating func displayToast(requiredData: OWToastRequiredData, actionCompletion: PublishSubject<Void>) {
        // Make sure no old toast is visible
        removeToast()

        let toastVM = OWToastViewModel(requiredData: requiredData, actionCompletion: actionCompletion)
        self.toastView = OWToastView(viewModel: toastVM)
        guard let toastView = toastView else { return }

        self.addSubview(toastView)
        toastView.OWSnp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(ToastMetrics.bottomOffsetForAnimation)
        }
        self.setNeedsLayout()
        self.layoutIfNeeded()

        UIView.animate(withDuration: ToastMetrics.animationDuration, animations: { [weak self] in
            guard let toastView = self?.toastView else { return }
            toastView.OWSnp.updateConstraints { make in
                make.bottom.equalToSuperview().inset(requiredData.bottomPadding)
            }
            self?.setNeedsLayout()
            self?.layoutIfNeeded()
        })

        self.applySwipeRecognition()
    }

    func dismissToast() {
        UIView.animate(withDuration: ToastMetrics.animationDuration, animations: { [weak self] in
            guard let toastView = self?.toastView else { return }
            toastView.OWSnp.updateConstraints { make in
                make.bottom.equalToSuperview().offset(ToastMetrics.bottomOffsetForAnimation)
            }
            self?.setNeedsLayout()
            self?.layoutIfNeeded()
        }, completion: { [weak self] _ in
            self?.removeToast()
        })
    }
}

fileprivate extension OWToastNotificationDisplayerProtocol where Self: UIView {
    func applySwipeRecognition() {
        guard let toastView = self.toastView else { return }

        toastView.addGestureRecognizer(panGesture)
        panGesture.rx.event
            .subscribe(onNext: { [weak self] recognizer in
                guard let self = self, let superView = self.superview else { return }

                switch recognizer.state {
                case .changed, .began:
                    let translation = recognizer.translation(in: superView)
                    toastView.OWSnp.updateConstraints { make in
                        make.centerX.equalToSuperview().offset(translation.x)
                    }
                case .ended:
                    let translation = recognizer.translation(in: superView)
                    let currentOffset = translation.x
                    var newOffset: CGFloat
                    // Dismiss view
                    if abs(currentOffset) > ToastMetrics.swipeThresholdToDismiss {
                        newOffset = currentOffset > 0 ? superView.bounds.width : -superView.bounds.width
                    } else {
                        // Back to center
                        newOffset = 0
                    }
                    UIView.animate(withDuration: ToastMetrics.swipeMagnetAnimationDuration, animations: { [weak self] in
                        guard let toastView = self?.toastView else { return }
                        toastView.OWSnp.updateConstraints { make in
                            make.centerX.equalToSuperview().offset(newOffset)
                        }
                        self?.setNeedsLayout()
                        self?.layoutIfNeeded()
                    }, completion: { [weak self] _ in
                        // remove if needed
                        guard newOffset != 0 else { return }
                        self?.removeToast()
                    })
                default:
                    break
                }
            })
            .disposed(by: disposeBag)
    }

    mutating func removeToast() {
        guard let toastView = self.toastView else { return }
        toastView.removeFromSuperview()
        toastView.removeGestureRecognizer(panGesture)
        self.toastView = nil
    }
}
