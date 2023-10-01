//
//  SampleAppNavigationController.swift
//  Spot-IM.Development
//
//  Created by Alon Haiut on 31/07/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import UIKit

class SampleAppNavigationController: UINavigationController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return topViewController?.preferredStatusBarStyle ?? .default
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return self.topViewController?.supportedInterfaceOrientations ?? .allButUpsideDown
    }
}
