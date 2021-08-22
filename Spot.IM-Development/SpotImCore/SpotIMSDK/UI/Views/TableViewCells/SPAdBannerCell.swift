//
//  SPAdBannerCell.swift
//  SpotImCore
//
//  Created by Alon Shprung on 19/08/2021.
//  Copyright © 2021 Spot.IM. All rights reserved.
//

import UIKit

protocol SPAdBannerCellDelegate: AnyObject {
    func hideBanner()
}

internal final class SPAdBannerCell: SPBaseTableViewCell {
    
    weak var delegate: SPAdBannerCellDelegate?
    
    private lazy var adBannerView: SPAdBannerView = .init()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupUI()
    }
    
    func updateColorsAccordingToStyle() {
        contentView.backgroundColor = .spBackground0
        self.adBannerView.updateColorsAccordingToStyle()
    }
    
    private func setupUI() {
        addSubviews(adBannerView)
        
        setupCloseView()
        setupBannerView()
        updateColorsAccordingToStyle()
    }
    
    private func setupCloseView() {
    }
    
    func updateBannerView(_ bannerView: UIView, height: CGFloat) {
        self.adBannerView.update(bannerView, height: height)
    }
    
    private func setupBannerView() {
        adBannerView.layout {
            $0.top.equal(to: topAnchor, offsetBy: 20.0)
            $0.bottom.equal(to: bottomAnchor, offsetBy: -20.0)
            $0.leading.equal(to: leadingAnchor)
            $0.trailing.equal(to: trailingAnchor)
        }
    }
}
