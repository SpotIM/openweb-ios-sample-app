//
//  OWNavigationController.swift
//  SpotImCore
//
//  Created by Alon Haiut on 08/09/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import UIKit

class OWNavigationController: UINavigationController {
    
    // We need to create a shared nav controller so it will stay in the memory, Router layer "holds" nav controller in a weak reference
    static let shared = OWNavigationController()
    
    func clear() {
        self.setViewControllers([], animated: false)
    }
}
