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
    private lazy var closeButton: BaseButton = .init(type: .custom)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupUI()
    }
    
    func updateColorsAccordingToStyle() {
        contentView.backgroundColor = .spBackground0
        self.adBannerView.updateColorsAccordingToStyle()
        self.closeButton.setImage(UIImage(spNamed: "closeIcon"), for: .normal)
    }
    
    private func setupUI() {
        addSubviews(adBannerView, closeButton)
        
        setupCloseButton()
        setupBannerView()
        updateColorsAccordingToStyle()
    }
    
    private func setupCloseButton() {
        closeButton.addTarget(self, action: #selector(self.onCloseClicked(_:)), for: .touchUpInside)
        
        closeButton.contentHorizontalAlignment = .right
        closeButton.contentVerticalAlignment = .top
        
        closeButton.layout {
            $0.top.equal(to: topAnchor, offsetBy: Theme.bannerTopOffset)
            $0.trailing.equal(to: trailingAnchor, offsetBy: -Theme.closeButtonTrailingOffset)
            $0.height.equal(to: Theme.closeButtonHeight)
            $0.width.equal(to: Theme.closeButtonWidth)
        }
    }
    
    @objc
    private func onCloseClicked(_ sender: UIButton) {
        delegate?.hideBanner()
    }
    
    func updateBannerView(_ bannerView: UIView, height: CGFloat) {
        self.adBannerView.update(bannerView, height: height)
    }
    
    private func setupBannerView() {
        adBannerView.layout {
            $0.top.equal(to: topAnchor, offsetBy: Theme.bannerTopOffset)
            $0.bottom.equal(to: bottomAnchor, offsetBy: -Theme.bannerBottomOffset)
            $0.leading.equal(to: leadingAnchor)
            $0.trailing.equal(to: trailingAnchor)
        }
    }
}

extension SPAdBannerCell {
    // MARK: - Theme

    private enum Theme {
        static let bannerTopOffset: CGFloat = 16.0
        static let bannerBottomOffset: CGFloat = 0.0
        static let closeButtonTrailingOffset: CGFloat = 16.0
        static let closeButtonWidth: CGFloat = 35.0
        static let closeButtonHeight: CGFloat = 35.0
    }
}
