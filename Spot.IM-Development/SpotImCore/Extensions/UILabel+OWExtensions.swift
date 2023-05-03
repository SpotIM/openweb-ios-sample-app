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
    typealias MethodHandler = () -> Void
    @discardableResult func addRangeGesture(stringRange: String, function: @escaping MethodHandler) -> UILabel {
        RangeGestureRecognizer.stringRange = stringRange
        RangeGestureRecognizer.function = function
        self.isUserInteractionEnabled = true
        let tapgesture: UITapGestureRecognizer = RangeGestureRecognizer(target: self, action: #selector(tappedOnLabel(_ :)))
        tapgesture.numberOfTapsRequired = 1
        self.addGestureRecognizer(tapgesture)
        return self
    }

    @objc func tappedOnLabel(_ gesture: RangeGestureRecognizer) {
        guard let text = self.text else { return }
        let stringRange = (text as NSString).range(of: RangeGestureRecognizer.stringRange ?? "")
        if gesture.didTapAttributedTextInLabel(label: self, inRange: stringRange) {
            guard let existedFunction = RangeGestureRecognizer.function else { return }
            existedFunction()
        }
    }
}
