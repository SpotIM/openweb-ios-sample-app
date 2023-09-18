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
}

extension OWToastNotificationDisplayerProtocol where Self: UIView {
    mutating func displayToast(requiredData: OWToastRequiredData, actionCompletion: PublishSubject<Void>) {
        // Make sure no old toast is visible
        if let oldToast = self.toastView {
            oldToast.removeFromSuperview()
            self.toastView = nil
        }

        let toastVM = OWToastViewModel(requiredData: requiredData, actionCompletion: actionCompletion)
        self.toastView = OWToastView(viewModel: toastVM)
        guard let toastView = toastView else { return }

        self.addSubview(toastView)
        toastView.OWSnp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(50)
        }
        self.setNeedsLayout()
        self.layoutIfNeeded()

        UIView.animate(withDuration: 0.5, animations: { [weak self] in
            guard let toastView = self?.toastView else { return }
            toastView.OWSnp.updateConstraints { make in
                make.bottom.equalToSuperview().inset(requiredData.bottomPadding)
            }
            self?.setNeedsLayout()
            self?.layoutIfNeeded()
        })
    }

    func dismissToast() {
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
