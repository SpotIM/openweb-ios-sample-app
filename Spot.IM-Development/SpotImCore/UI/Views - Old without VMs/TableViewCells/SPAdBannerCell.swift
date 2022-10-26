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
    fileprivate struct Metrics {
        static let identifier = "ad_banner_cell_id"
        static let adBannerIdentifier = "ad_banner_id"
        static let closeButtonIdentifier = "close_button_id"
    }
    weak var delegate: SPAdBannerCellDelegate?
    
    private lazy var adBannerView: SPAdBannerView = .init()
    private lazy var closeButton: OWBaseButton = .init(type: .custom)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupUI()
        applyAccessibility()
    }
    
    private func applyAccessibility() {
        self.accessibilityIdentifier = Metrics.identifier
        adBannerView.accessibilityIdentifier = Metrics.adBannerIdentifier
        closeButton.accessibilityIdentifier = Metrics.closeButtonIdentifier
    }
    
    func updateColorsAccordingToStyle() {
        contentView.backgroundColor = .spBackground0
        self.adBannerView.updateColorsAccordingToStyle()
        self.closeButton.setImage(UIImage(spNamed: "closeIcon", supportDarkMode: true), for: .normal)
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
        
        closeButton.OWSnp.makeConstraints { make in
            make.top.equalToSuperview().offset(Theme.bannerTopOffset)
            if #available(iOS 11.0, *) {
                make.trailing.equalTo(safeAreaLayoutGuide).offset(-Theme.closeButtonTrailingOffset)
            } else {
                make.trailing.equalToSuperview().offset(-Theme.closeButtonTrailingOffset)
            }
            make.size.equalTo(Theme.closeButtonSize)
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
        adBannerView.OWSnp.makeConstraints { make in
            make.top.equalToSuperview().offset(Theme.bannerTopOffset)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
}

extension SPAdBannerCell {
    // MARK: - Theme

    private enum Theme {
        static let bannerTopOffset: CGFloat = 16.0
        static let closeButtonTrailingOffset: CGFloat = 16.0
        static let closeButtonSize: CGFloat = 35.0
    }
}
