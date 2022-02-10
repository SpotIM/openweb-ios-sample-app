//
//  SPAdBannerView.swift
//  SpotImCore
//
//  Created by Alon Shprung on 22/08/2021.
//  Copyright © 2021 Spot.IM. All rights reserved.
//

import UIKit

internal final class SPAdBannerView: OWBaseView {
    private lazy var bannerContainerView: OWBaseView = .init()
    private var bannerView: UIView?
    private var bannerContainerHeight: NSLayoutConstraint?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(bannerContainerView)
        
        setupBannerContainerView()
    }
    
    // Handle dark mode \ light mode change
    func updateColorsAccordingToStyle() {
        backgroundColor = .spBackground0
        bannerContainerView.backgroundColor = .spBackground0
        bannerView?.backgroundColor = .spBackground0
    }
    
    
    func update(_ bannerView: UIView, height: CGFloat) {
        self.bannerView?.removeFromSuperview()
        self.bannerView = bannerView
        bannerContainerView.addSubview(bannerView)
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        bannerView.layout {
            $0.height.equal(to: height)
            $0.top.equal(to: bannerContainerView.topAnchor)
            $0.centerX.equal(to: bannerContainerView.centerXAnchor)
        }
        bannerContainerHeight?.constant = height
        
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    private func setupBannerContainerView() {
        bannerContainerView.layout {
            $0.top.equal(to: topAnchor)
            $0.leading.equal(to: leadingAnchor)
            $0.trailing.equal(to: trailingAnchor)
            bannerContainerHeight = $0.height.equal(to: 0.0)
        }
    }
}
