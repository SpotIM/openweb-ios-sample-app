//
//  OWSafariViewController.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 09/11/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation
import UIKit
import SafariServices

class OWSafariViewController: SFSafariViewController {
    private let options: OWSafariViewControllerOptions
    
    init(options: OWSafariViewControllerOptions) {
        self.options = options
        super.init(url: options.url, configuration: .init())
    }
    
}
