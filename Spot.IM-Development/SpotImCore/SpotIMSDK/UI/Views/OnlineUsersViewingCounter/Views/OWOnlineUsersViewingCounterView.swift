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
    
    fileprivate var viewModel: OWOnlineUsersViewingCounterViewModeling!
    
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
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
    }

    func configure(with viewModel: OWOnlineUsersViewingCounterViewModeling) {
        self.viewModel = viewModel
        configureViews()
    }
}

fileprivate extension OWOnlineUsersViewingCounterView {
    func setupViews() {
        
    }
    
    func configureViews() {
        imgViewIcon.image = viewModel.outputs.image
        viewModel.outputs.viewingCount = { [weak self] viewingCount in
            guard let self = self else { return }
            self.lblViewersNumber.text = "\(viewingCount)"
        }
    }
}

