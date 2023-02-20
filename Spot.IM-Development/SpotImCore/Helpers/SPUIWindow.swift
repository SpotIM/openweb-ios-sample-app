//
//  SPUIWindow.swift
//  SpotImCore
//
//  Created by Alon Shprung on 03/10/2021.
//  Copyright © 2021 Spot.IM. All rights reserved.
//

import UIKit

internal class SPUIWindow {

    // holding the current view window frame
    static var frame: CGRect = {
        return UIScreen.main.bounds // default
    }()
}
