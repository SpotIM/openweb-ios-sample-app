//
//  OWNavigationCustomizableElement.swift
//  SpotImCore
//
//  Created by Revital Pisman on 28/06/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import UIKit

#if NEW_API
public enum OWNavigationCustomizableElement {
    case navigationItem(_ navigationItem: UINavigationItem)
    case navigationBar(_ navigationBar: UINavigationBar)
}

#else
enum OWNavigationCustomizableElement {
    case navigationItem(_ navigationItem: UINavigationItem)
    case navigationBar(_ navigationBar: UINavigationBar)
}
#endif
