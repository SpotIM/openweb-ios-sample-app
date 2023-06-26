//
//  Notification+Keyboard.swift
//  Spot-IM.Development
//
//  Created by Refael Sommer on 21/06/23.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import UIKit

extension Notification {

    var keyboardSize: CGSize? {
        return (userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size
    }

    var keyboardAnimationDuration: Double? {
        return userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
    }

}
