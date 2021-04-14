//
//  PreConversationBannerView.swift
//  SpotImCore
//
//  Created by Rotem Itzhak on 11/03/2020.
//  Copyright © 2020 Spot.IM. All rights reserved.
//

import UIKit

internal final class PreConversationBannerView: BaseView {
    private lazy var bannerContainerView: BaseView = .init()
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
        bannerView?.backgroundColor = .spBackground0
    }
    
    
    func update(_ bannerView: UIView, height: CGFloat) {
        self.bannerView?.removeFromSuperview()
        self.bannerView = bannerView
        bannerContainerView.addSubview(bannerView)
        bannerView.layout {
            $0.height.equal(to: height)
            $0.leading.equal(to: bannerContainerView.leadingAnchor)
            $0.trailing.equal(to: bannerContainerView.trailingAnchor)
            $0.bottom.equal(to: bannerContainerView.bottomAnchor)
        }
        bannerContainerHeight?.constant = height
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
