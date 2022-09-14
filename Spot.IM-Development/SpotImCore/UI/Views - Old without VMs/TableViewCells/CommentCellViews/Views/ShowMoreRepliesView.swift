//
//  ShowMoreRepliesView.swift
//  Spot.IM-Core
//
//  Created by Andriy Fedin on 27/09/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import UIKit

internal final class ShowMoreRepliesView: OWBaseView {
    fileprivate struct Metrics {
        static let identifier = "show_more_replies_id"
    }
    
    weak var delegate: ShowMoreRepliesViewDelegate?
    var collapsedTitle: String?
    var expandedTitle: String?

    private let activityIndicator = UIActivityIndicatorView(style: .gray)
    private let showHideRepliesButton: OWBaseButton = .init()
    private let disclosureIndicator: OWBaseUIImageView = .init(image: UIImage(spNamed: "messageDisclosureIndicatorIcon", supportDarkMode: true))

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.accessibilityIdentifier = Metrics.identifier
        clipsToBounds = true
        setupUI()
    }
    
    // Handle dark mode \ light mode change
    func updateColorsAccordingToStyle() {
        backgroundColor = .spBackground0
        showHideRepliesButton.backgroundColor = .spBackground0
        showHideRepliesButton.setTitleColor(.spForeground1, for: .normal)
        disclosureIndicator.image = UIImage(spNamed: "messageDisclosureIndicatorIcon", supportDarkMode: true)
    }
    

    func updateView(with state: RepliesButtonState) {
        switch state {
        case .collapsed, .expanded:
            activityIndicator.isHidden = true
            activityIndicator.stopAnimating()
            disclosureIndicator.isHidden = false
        case .loading:
            activityIndicator.isHidden = false
            activityIndicator.startAnimating()
            disclosureIndicator.isHidden = true
        case .hidden:
            activityIndicator.stopAnimating()
        }
        showHideRepliesButton.setTitle(repliesButtonTitle(for: state), for: .normal)
        updateDisclosure(with: state)
    }

    // MARK: - Private

    private func updateDisclosure(with state: RepliesButtonState) {
        switch state {
        case .collapsed:
            disclosureIndicator.transform = .init(rotationAngle: .pi)
        case .expanded:
            disclosureIndicator.transform = .identity
        default: break
        }
    }

    private func setupUI() {
        addSubview(showHideRepliesButton)
        showHideRepliesButton.addSubviews(disclosureIndicator, activityIndicator)
        configureShowHideRepliesButton()
        configureActivityIndicator()
        configureDisclosureIndicator()
    }

    private func configureShowHideRepliesButton() {
        showHideRepliesButton.backgroundColor = .spBackground0
        showHideRepliesButton.addTarget(self, action: #selector(showHideReplies), for: .touchUpInside)
        showHideRepliesButton.titleLabel?.font = .preferred(style: .bold, of: Theme.fontSize)
        showHideRepliesButton.setTitleColor(.spForeground1, for: .normal)
        showHideRepliesButton.OWSnp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        if LocalizationManager.currentLanguage?.isRightToLeft ?? false {
            showHideRepliesButton.contentEdgeInsets.left += activityIndicator.frame.width + Theme.activityOffset
        } else {
            showHideRepliesButton.contentEdgeInsets.right += activityIndicator.frame.width + Theme.activityOffset
        }
    }
    
    private func configureActivityIndicator() {
        activityIndicator.style = SPUserInterfaceStyle.isDarkMode ? .white : .gray
        activityIndicator.OWSnp.makeConstraints { make in
            make.centerY.trailing.equalToSuperview()
        }
    }

    private func configureDisclosureIndicator() {
        disclosureIndicator.OWSnp.makeConstraints { make in
            make.center.equalTo(activityIndicator)
        }
    }

    private func repliesButtonTitle(for state: RepliesButtonState) -> String? {
        switch state {
        case .collapsed, .loading:
            return collapsedTitle
        case .expanded:
            return expandedTitle
        default:
            return nil
        }
    }

    // MARK: - Actions

    @objc
    private func showHideReplies() {
        delegate?.showHideReplies()
    }
}

// MARK: - Delegate

protocol ShowMoreRepliesViewDelegate: class {

    func showHideReplies()

}

// MARK: - Theme

private enum Theme {
    static let fontSize: CGFloat = 16.0
    static let activityOffset: CGFloat = 6
}
