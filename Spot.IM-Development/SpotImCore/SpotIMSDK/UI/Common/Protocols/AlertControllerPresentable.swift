//
//  AlertControllerPresentable.swift
//  Spot.IM-Core
//
//  Created by Eugene on 7/30/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import UIKit

protocol AlertPresentable {}

extension AlertPresentable where Self: UIViewController {
    
    func showActionSheet(
        title: String? = nil,
        message: String? = nil,
        actions: [UIAlertAction],
        sender: UIView?,
        completion: (() -> Void)? = nil) {

        let actionSheet = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .actionSheet
        )

        if let popover = actionSheet.popoverPresentationController, let frame = sender?.bounds {
            popover.sourceRect = frame
            popover.sourceView = sender
        }
        
        for action in actions {
            actionSheet.addAction(action)
        }
        
        present(actionSheet, animated: true, completion: completion)
    }
    
    func showAlert(title: String? = nil, message: String? = nil, actions: [UIAlertAction] = [],
                   completion: (() -> Void)? = nil) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        if !actions.isEmpty {
            for action in actions {
                alert.addAction(action)
            }
        } else {
            let defaultAction = UIAlertAction(
                title: NSLocalizedString("OK", comment: "default ok"),
                style: .default)
            alert.addAction(defaultAction)
        }
        
        present(alert, animated: true, completion: completion)
    }
    
    func showToast(message: String, delay: Double) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.view.alpha = 0.6
        present(alert, animated: true)

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delay) {
            alert.dismiss(animated: true)
        }
    }
}
