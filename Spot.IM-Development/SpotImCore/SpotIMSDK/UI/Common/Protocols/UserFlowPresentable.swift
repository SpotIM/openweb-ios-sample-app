//
//  UserFlowPresentable.swift
//  Spot.IM-Core
//
//  Created by Eugene on 8/30/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import UIKit

protocol UserAuthFlowDelegateContainable: class {
    
    var userAuthFlowDelegate: UserAuthFlowDelegate? { get set }
    
}

protocol UserAuthFlowDelegate: class {
    
    func presentAuth()
    func signOut()
    
}

protocol UserPresentable: class {
    
    var userIcon: UIButton { get }
    /// Setup selector and target for `userIcon` here! Call it on the start of the flow.
    func setupUserIconHandler()
}

extension UserPresentable where Self: UIViewController & AlertPresentable & UserAuthFlowDelegateContainable {
    
    func updateUserIcon(image: UIImage) {
        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(navigationAvatarSize, false, scale)
        image.draw(in: CGRect(origin: .zero, size: navigationAvatarSize))
        let newIM = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        userIcon.setImage(newIM, for: .normal)
    }
    
    func showProfileActions(sender: UIView) {
        var profileActions: [UIAlertAction] = []
        
        if let user = SPUserSessionHolder.session.user, user.registered {
            let logOutAction = UIAlertAction(
                title: NSLocalizedString("Log Out", comment: "log out"),
                style: .default
            ) { _ in
                self.presentLogOutConfirmation()
            }
            profileActions.append(logOutAction)
        } else {
            let logInAction = UIAlertAction(
                title: NSLocalizedString("Log In", comment: "log in"),
                style: .default
            ) { _ in
                SPAnalyticsHolder.default.log(event: .loginClicked(.mainLogin), source: .conversation)
                self.userAuthFlowDelegate?.presentAuth()
            }
            profileActions.append(logInAction)
        }
        let noAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "cancel title"),
                                     style: .cancel)
        
        profileActions.append(noAction)

        showActionSheet(actions: profileActions, sender: sender)
    }
    
    private func presentLogOutConfirmation() {
        let yesAction = UIAlertAction(
            title: NSLocalizedString("Log Out", comment: "log out title"),
            style: .destructive) { _ in
                self.userAuthFlowDelegate?.signOut()
        }
        
        let noAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "cancel title"),
                                     style: .default)
        showAlert(
            title: NSLocalizedString("Log Out", comment: "log out"),
            message: NSLocalizedString(
                "Are you sure you want to log out?",
                comment: "log out confirmation"),
            actions: [yesAction, noAction]
        )
    }
}
