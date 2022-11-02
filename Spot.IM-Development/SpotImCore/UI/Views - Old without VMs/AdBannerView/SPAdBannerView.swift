//
//  SPAdBannerView.swift
//  SpotImCore
//
//  Created by Alon Shprung on 22/08/2021.
//  Copyright © 2021 Spot.IM. All rights reserved.
//

import UIKit

internal final class SPAdBannerView: OWBaseView {
    fileprivate struct Metrics {
        static let identifier = "ad_banner_id"
        static let bannerViewIdentifier = "ad_banner_banner_view_id"
    }
    
    private lazy var bannerContainerView: OWBaseView = .init()
    private var bannerView: UIView?
    private var bannerContainerHeight: OWConstraint?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(bannerContainerView)
        setupBannerContainerView()
        applyAccessibility()
    }
    
    private func applyAccessibility() {
        self.accessibilityIdentifier = Metrics.identifier
        bannerView?.accessibilityIdentifier = Metrics.bannerViewIdentifier
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
        bannerView.OWSnp.makeConstraints { make in
            make.height.equalTo(height)
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        bannerContainerView.OWSnp.updateConstraints { make in
            make.height.equalTo(height)
        }
        
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    private func setupBannerContainerView() {
        bannerContainerView.OWSnp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(0.0)
        }
    }
}
