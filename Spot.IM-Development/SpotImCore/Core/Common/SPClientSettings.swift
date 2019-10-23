//
//  SPClientSettings.swift
//  Spot.IM-Core
//
//  Created by Andriy Fedin on 18/06/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import Foundation
import UIKit

public struct SPClientSettings {
    
    internal private(set) static var spotKey: String?

    public static func setup(spotKey: String?) {
        if self.spotKey != spotKey {
            self.spotKey = spotKey
            UIFont.loadAllFonts
            
            SPAnalyticsHolder.default.log(event: .appOpened, source: .mainPage)
            
            SPDefaultConfigProvider.getConfig { (conf, _) in
                SPConfigDataSource.config = conf
            }
        }
    }
}
