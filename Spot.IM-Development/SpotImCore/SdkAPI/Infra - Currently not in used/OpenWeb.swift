//
//  OpenWeb.swift
//  SpotImCore
//
//  Created by Alon Haiut on 28/06/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation

#if NEW_API
public class OpenWeb {
    public static let manager: OWManagerProtocol = OWManager.manager
}
#else
class OpenWeb {
    static let manager: OWManagerProtocol = OWManager.manager
}
#endif
