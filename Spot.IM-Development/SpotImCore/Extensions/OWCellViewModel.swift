//
//  OWCellViewModel.swift
//  SpotImCore
//
//  Created by Alon Haiut on 27/07/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation
import UIKit

protocol OWCellViewModel {}

extension UITableViewCell {
    func configure(with viewModel: OWCellViewModel) {
        fatalError("configure(with viewModel:) has not been implemented, please override this method")
    }
}
