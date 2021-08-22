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
    
    private lazy var bannerContainerView: BaseView = .init()
    private var bannerView: UIView?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupUI()
    }
    
    func updateColorsAccordingToStyle() {
        contentView.backgroundColor = .spBackground0
    }
    
    private func setupUI() {
        addSubviews(bannerContainerView)
        
        setupCloseView()
        setupBannerView()
        updateColorsAccordingToStyle()
    }
    
    private func setupCloseView() {
    }
    
    func updateBannerView(_ bannerView: UIView, height: CGFloat) {
        self.bannerView?.removeFromSuperview()
        self.bannerView = bannerView
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        bannerContainerView.addSubview(bannerView)
        bannerView.layout {
            $0.top.equal(to: bannerContainerView.topAnchor)
            $0.leading.equal(to: bannerContainerView.leadingAnchor)
            $0.trailing.equal(to: bannerContainerView.trailingAnchor)
            $0.height.equal(to: height)
        }
        
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    private func setupBannerView() {
        bannerContainerView.layout {
            $0.top.equal(to: topAnchor, offsetBy: 20.0)
            $0.bottom.equal(to: bottomAnchor, offsetBy: -20.0)
            $0.leading.equal(to: leadingAnchor)
            $0.trailing.equal(to: trailingAnchor)
        }
    }
}
