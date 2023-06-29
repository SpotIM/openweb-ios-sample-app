//
//  UILabel+OWExtensions.swift
//  SpotImCore
//
//  Created by Refael Sommer on 03/05/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import UIKit
import Foundation

extension UILabel {
    @discardableResult func addRangeGesture(targetRange: String, function: @escaping OWBasicCompletion) -> UILabel {
        self.isUserInteractionEnabled = true
        let tapGesture = RangeGestureRecognizer(target: self, action: #selector(tappedOnLabel(_ :)))
        tapGesture.stringRange = targetRange
        tapGesture.function = function
        tapGesture.numberOfTapsRequired = 1
        self.addGestureRecognizer(tapGesture)
        return self
    }

    @objc func tappedOnLabel(_ gesture: RangeGestureRecognizer) {
        guard let text = self.text else { return }
        let stringRange = (text as NSString).range(of: gesture.stringRange ?? "")
        if gesture.didTapAttributedText(in: self, inRange: stringRange) {
            guard let existedFunction = gesture.function else { return }
            existedFunction()
        }
    }
}
