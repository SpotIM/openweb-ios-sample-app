//
//  OWOnlineViewingUsersCounterView.swift
//  SpotImCore
//
//  Created by Alon Haiut on 13/12/2021.
//  Copyright © 2021 Spot.IM. All rights reserved.
//

import Foundation
import UIKit

class OWOnlineViewingUsersCounterView: UIView {
    fileprivate struct Metrics {
        static let horizontalMargin: CGFloat = 6
        static let viewersFontSize: CGFloat = 15.0
    }
    
    fileprivate var viewModel: OWOnlineViewingUsersCounterViewModeling!
    
    fileprivate lazy var imgViewIcon: UIImageView = {
        let img = UIImageView()
        img.contentMode = .scaleAspectFill
        return img
    }()
    
    fileprivate lazy var lblViewersNumber: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.preferred(style: .bold, of: Metrics.viewersFontSize)
        lbl.textColor = .spForeground3
        return lbl
    }()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
    }
    
    init() {
        super.init(frame: .zero)
        setupViews()
    }

    func configure(with viewModel: OWOnlineViewingUsersCounterViewModeling) {
        self.viewModel = viewModel
        configureViews()
    }
}

fileprivate extension OWOnlineViewingUsersCounterView {
    func setupViews() {
        self.addSubview(imgViewIcon)
        imgViewIcon.layout {
            $0.top.equal(to: self.topAnchor)
            $0.leading.equal(to: self.leadingAnchor)
            $0.bottom.equal(to: self.bottomAnchor)
        }
        
        self.addSubview(lblViewersNumber)
        lblViewersNumber.layout {
            $0.centerY.equal(to: self.centerYAnchor)
            $0.leading.equal(to: imgViewIcon.trailingAnchor, offsetBy: Metrics.horizontalMargin)
            $0.trailing.equal(to: self.trailingAnchor)
        }
    }
    
    func configureViews() {
        imgViewIcon.image = viewModel.outputs.image
        viewModel.outputs.viewingCount = { [weak self] viewingCount in
            guard let self = self else { return }
            self.lblViewersNumber.text = "\(viewingCount)"
        }
    }
}

