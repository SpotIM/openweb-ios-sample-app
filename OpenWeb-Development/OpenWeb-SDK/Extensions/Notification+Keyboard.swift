//
//  Notification+Keyboard.swift
//  OpenWebSDK
//
//  Created by Eugene on 8/1/19.
//  Copyright © 2019 OpenWeb. All rights reserved.
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
