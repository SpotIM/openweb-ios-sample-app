//
//  OWOnlineUsersViewingCounterView.swift
//  SpotImCore
//
//  Created by Alon Haiut on 13/12/2021.
//  Copyright © 2021 Spot.IM. All rights reserved.
//

import Foundation
import UIKit

class OWOnlineUsersViewingCounterView: UIView {
    fileprivate struct Metrics {
        static let horizontalMargin: CGFloat = 5
        static let viewersFontSize: CGFloat = 14.0
    }
    
    fileprivate lazy var imgViewIcon: UIImageView = {
        let img = UIImageView()
        img.contentMode = .scaleAspectFill
        return img
    }()
    
    fileprivate lazy var lblViewersNumber: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.preferred(style: .regular, of: Metrics.viewersFontSize)
        lbl.textColor = .spForeground3
        return lbl
    }()
}

