//
//  Coordinator.swift
//  Spot.IM-Core
//
//  Created by Eugene on 8/6/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import Foundation
import UIKit

protocol Coordinator: class {
    
    // should be weak in realization
    var containerViewController: UIViewController? { get set }
    
}

extension Coordinator {
    
    var navigationController: UINavigationController? {
        return containerViewController as? UINavigationController
    }
    
}
