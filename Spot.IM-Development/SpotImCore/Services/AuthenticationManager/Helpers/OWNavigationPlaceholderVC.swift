//
//  OWNavigationPlaceholderVC.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 13/11/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import UIKit

class OWNavigationPlaceholderVC: UIViewController {

    fileprivate let viewModel: OWNavigationPlaceholderViewModeling

    init(viewModel: OWNavigationPlaceholderViewModeling) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)

        viewModel.inputs.viewControllerAttached(vc: self)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
