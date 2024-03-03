//
//  OWToastNotificationPresenterProtocol.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 12/09/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

protocol OWToastNotificationPresenterProtocol {
    mutating func presentToast(requiredData: OWToastRequiredData, completions: [OWToastCompletion: PublishSubject<Void>?], disposeBag: DisposeBag)
    func dismissToast()
    var toastView: OWToastView? { get set }
}

struct ToastMetrics {
    fileprivate static var bottomOffsetForAnimation: CGFloat = 50
    static var animationDuration: TimeInterval = 0.5

    fileprivate static let swipeThresholdToDismiss: CGFloat = 50
    fileprivate static let swipeMagnetAnimationDuration: CGFloat = 0.3
    fileprivate static let panGestureName = "OWToastPanGesture"
}

extension OWToastNotificationPresenterProtocol where Self: UIView {

    mutating func presentToast(requiredData: OWToastRequiredData, completions: [OWToastCompletion: PublishSubject<Void>?], disposeBag: DisposeBag) {
        // Make sure no old toast is visible
        removeToast()

        let toastVM = OWToastViewModel(requiredData: requiredData, completions: completions)
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

        self.setupToastObservers(disposeBag: disposeBag)
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

    fileprivate func setupToastObservers(disposeBag: DisposeBag) {
        let panGesture = UIPanGestureRecognizer()
        panGesture.name = ToastMetrics.panGestureName
        panGesture.rx.event
            .subscribe(onNext: { [weak self] recognizer in
                guard let self = self,
                      let toastView = self.toastView,
                      let superView = toastView.superview else { return }

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
        toastView?.addGestureRecognizer(panGesture)
    }
}

fileprivate extension OWToastNotificationPresenterProtocol where Self: UIView {
    mutating func removeToast() {
        guard let toastView = self.toastView else { return }
        toastView.removeFromSuperview()
        if let panGesture = toastView.gestureRecognizers?.first(where: { $0.name == ToastMetrics.panGestureName }) {
            toastView.removeGestureRecognizer(panGesture)
        }
        self.toastView = nil
    }
}
