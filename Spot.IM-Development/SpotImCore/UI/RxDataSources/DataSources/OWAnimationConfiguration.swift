//
//  OWAnimationConfiguration.swift
//  SpotImCore
//
//  Created by Alon Haiut on 07/07/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import UIKit

struct OWAnimationConfiguration {
    let insertAnimation: UITableView.RowAnimation
    let reloadAnimation: UITableView.RowAnimation
    let deleteAnimation: UITableView.RowAnimation

    init(insertAnimation: UITableView.RowAnimation = .automatic,
         reloadAnimation: UITableView.RowAnimation = .automatic,
         deleteAnimation: UITableView.RowAnimation = .automatic) {
        self.insertAnimation = insertAnimation
        self.reloadAnimation = reloadAnimation
        self.deleteAnimation = deleteAnimation
    }
}
