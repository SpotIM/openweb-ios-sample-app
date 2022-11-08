//
//  OWConfigurableCell.swift
//  SpotImCore
//
//  Created by Alon Haiut on 25/10/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import UIKit

@objc protocol OWConfigurableCell {
    func configure(with viewModel: OWCellViewModel)
}

extension UITableViewCell: OWConfigurableCell {
    func configure(with viewModel: OWCellViewModel) {
        fatalError("configure(with viewModel:) has not been implemented, please override this method")
    }
}
