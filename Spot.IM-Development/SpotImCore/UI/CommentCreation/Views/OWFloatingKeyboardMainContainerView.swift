//
//  OWFloatingKeyboardMainContainerView.swift
//  SpotImCore
//
//  Created by Refael Sommer on 01/02/2024.
//  Copyright © 2024 Spot.IM. All rights reserved.
//

import UIKit
import Foundation

class OWFloatingKeyboardMainContainerView: UIView, OWToastNotificationDisplayerProtocol {
    var toastView: OWToastView?
    var panGesture = UIPanGestureRecognizer()
}
