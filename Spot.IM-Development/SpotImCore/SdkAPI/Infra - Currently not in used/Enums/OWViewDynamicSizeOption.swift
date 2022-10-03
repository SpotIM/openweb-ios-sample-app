//
//  OWViewDynamicSizeOption.swift
//  SpotImCore
//
//  Created by Alon Haiut on 07/09/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import UIKit

#if NEW_API
public enum OWViewDynamicSizeOption {
    case viewInitialSize(view: UIView, initialSize: CGSize)
    case updateSize(view: UIView, newSize: CGSize)
}
#else
enum OWViewDynamicSizeOption {
    case viewInitialSize(view: UIView, initialSize: CGSize)
    case updateSize(view: UIView, newSize: CGSize)
}
#endif
