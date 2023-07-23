//
//  OWAccessoryView.swift
//  SpotImCore
//
//  Created by Alon Haiut on 29/06/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import UIKit

#if NEW_API
public enum OWAccessoryViewStrategy {
    case none
    case bottomToolbar(toolbar: UIView)
}

#else
enum OWAccessoryViewStrategy {
    case none
    case bottomToolbar(toolbar: UIView)
}
#endif
