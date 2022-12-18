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
    private let viewModel: OWSafariViewModel
    
    init(viewModel: OWSafariViewModel) {
        self.viewModel = viewModel
        super.init(url: viewModel.outputs.options.url, configuration: .init())
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.inputs.viewDidLoad.onNext()
    }
}
