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
    mutating func displayToast(requiredData: OWToastRequiredData)
    func removeToast()
    var toastView: OWToastView? { get set }
}

extension OWToastNotificationDisplayerProtocol where Self: UIView {
    mutating func displayToast(requiredData: OWToastRequiredData) {
        let toastVM = OWToastViewModel(requiredData: requiredData) { }
        self.toastView = OWToastView(viewModel: toastVM)
        guard let toastView = toastView else { return }

        self.addSubview(toastView)
        toastView.OWSnp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(50) // TODO: what insets?
        }
        self.setNeedsLayout()
        self.layoutIfNeeded()
//        self.bringSubviewToFront(toastView)

        UIView.animate(withDuration: 0.5, animations: { [weak self] in
            guard let toastView = self?.toastView else { return }
            toastView.OWSnp.updateConstraints { make in
                make.bottom.equalToSuperview().inset(30) // TODO: insets
            }
            self?.setNeedsLayout()
            self?.layoutIfNeeded()
        }, completion: { _ in
//            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 5) {
//                UIView.animate(withDuration: 0.5, animations: {
//                    toastView.OWSnp.updateConstraints { make in
//                        make.bottom.equalToSuperview().offset(50)
//                    }
//                    presenterVC.view.setNeedsLayout()
//                    presenterVC.view.layoutIfNeeded()
//                }, completion: { _ in
//                    toastView.removeFromSuperview()
//                    observer.onNext(.completion)
//                })
//            }

        })
    }

    // The implementing view should hold the toast view!
    func removeToast() {
        UIView.animate(withDuration: 0.5, animations: { [weak self] in
            guard let toastView = self?.toastView else { return }
            toastView.OWSnp.updateConstraints { make in
                make.bottom.equalToSuperview().offset(50)
            }
            self?.setNeedsLayout()
            self?.layoutIfNeeded()
        }, completion: { [weak self] _ in
            guard let toastView = self?.toastView else { return }
            toastView.removeFromSuperview()
            self?.toastView = nil
        })
    }
}
