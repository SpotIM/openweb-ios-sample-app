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
    func shouldDisplayLoginPromptForGuests() -> Bool
}

protocol UserPresentable: class {
    
    var userIcon: BaseButton { get }
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
                title: LocalizationManager.localizedString(key: "Log Out"),
                style: .default
            ) { _ in
                self.presentLogOutConfirmation()
            }
            profileActions.append(logOutAction)
        } else {
            let logInAction = UIAlertAction(
                title: LocalizationManager.localizedString(key: "Log In"),
                style: .default
            ) { _ in
                SPAnalyticsHolder.default.log(event: .loginClicked(.mainLogin), source: .conversation)
                self.userAuthFlowDelegate?.presentAuth()
            }
            profileActions.append(logInAction)
        }
        let noAction = UIAlertAction(title: LocalizationManager.localizedString(key: "Cancel"),
                                     style: .cancel)
        
        profileActions.append(noAction)

        showActionSheet(actions: profileActions, sender: sender)
    }
    
    private func presentLogOutConfirmation() {
        let yesAction = UIAlertAction(
            title: LocalizationManager.localizedString(key: "Log Out"),
            style: .destructive) { _ in
                SpotIm.logout { result in
                    switch result {
                    case .success:
                        print("Logout succeeded")
                    case .failure(let error):
                        print("Logout error: \(error)")
                    }
                }
        }
        
        let noAction = UIAlertAction(title: LocalizationManager.localizedString(key: "Cancel"),
                                     style: .default)
        showAlert(
            title: LocalizationManager.localizedString(key: "Log Out"),
            message: LocalizationManager.localizedString(key: "Are you sure you want to log out?"),
            actions: [yesAction, noAction]
        )
    }
}
