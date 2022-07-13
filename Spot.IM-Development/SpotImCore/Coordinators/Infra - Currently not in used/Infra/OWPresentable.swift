//
//  OWPresentable.swift
//  SpotImCore
//
//  Created by Alon Haiut on 01/03/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation
import UIKit

protocol OWPresentable {
    func toPresentable() -> UIViewController
}

extension UIViewController: OWPresentable {
    func toPresentable() -> UIViewController {
        return self
    }
}
