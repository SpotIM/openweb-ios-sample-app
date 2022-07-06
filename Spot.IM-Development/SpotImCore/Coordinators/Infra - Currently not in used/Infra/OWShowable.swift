//
//  OWShowable.swift
//  SpotImCore
//
//  Created by Alon Haiut on 01/03/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation
import UIKit

protocol OWShowable {
    func toShowable() -> UIView
}

extension UIViewController: OWShowable {
    func toShowable() -> UIView {
        return self.view
    }
}

extension UIView: OWShowable {
    func toShowable() -> UIView {
        return self
    }
}
