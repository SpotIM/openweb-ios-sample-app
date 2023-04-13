//
//  SPPreConversationHeaderView.swift
//  Spot.IM-Core
//
//  Created by Andriy Fedin on 13/08/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import UIKit

protocol SPPreConversationHeaderViewDelegate: AnyObject {
    func updateHeaderCustomUI(titleLabel: UILabel, counterLabel: UILabel)
}

internal final class SPPreConversationHeaderView: OWBaseView {
    fileprivate struct Metrics {
        static let counterLeading: CGFloat = 5
        static let titleFontSize: CGFloat = 25
        static let counterFontSize: CGFloat = 16
        static let margins: UIEdgeInsets = .init(top: 16, left: 16, bottom: 16, right: 16)
        static let identifier = "pre_conversation_header_view_id"
        static let titleLabelIdentifier = "pre_conversation_header_title_label_id"
        static let counterLabelIdentifier = "pre_conversation_header_counter_label_id"
    }

    private lazy var titleLabel: OWBaseLabel = {
        let lbl = OWBaseLabel()
        lbl.font = UIFont.preferred(style: .bold, of: Metrics.titleFontSize)
        lbl.textColor = .spForeground0
        return lbl
    }()

    private lazy var counterLabel: OWBaseLabel = {
        let lbl = OWBaseLabel()
        lbl.font = UIFont.preferred(style: .regular, of: Metrics.counterFontSize)
        lbl.textColor = .spForeground1
        return lbl
    }()

    private lazy var onlineViewingUsersView: SPOnlineViewingUsersCounterView = {
       return SPOnlineViewingUsersCounterView()
    }()

    internal weak var delegate: SPPreConversationHeaderViewDelegate?

    init(onlineViewingUsersCounterVM: SPOnlineViewingUsersCounterViewModeling) {
        super.init(frame: .zero)
        onlineViewingUsersView.configure(with: onlineViewingUsersCounterVM)
        setupUI()
    }

    private func applyAccessibility() {
        self.accessibilityIdentifier = Metrics.identifier
        titleLabel.accessibilityIdentifier = Metrics.titleLabelIdentifier
        counterLabel.accessibilityIdentifier = Metrics.counterLabelIdentifier
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupUI()
    }

    // Handle dark mode \ light mode change
    func updateColorsAccordingToStyle() {
        backgroundColor = .spBackground0
        titleLabel.textColor = .spForeground0
        counterLabel.textColor = .spForeground1
        updateCustomUI()
    }

    private func updateCustomUI() {
        delegate?.updateHeaderCustomUI(titleLabel: titleLabel, counterLabel: counterLabel)
    }

    internal func set(title: String) {
        titleLabel.text = title
        updateCustomUI()
    }

    internal func set(commentCount: String?) {
        counterLabel.fadeTransition(1.0)
        if let commentCount = commentCount {
            counterLabel.text = "(\(commentCount))"
        } else {
            counterLabel.text = nil
        }
        updateCustomUI()
    }

    // Idealy this header view will have a VM as well which will hold the online users VM
    // I decided to wait with the refactoring and do so in a more specific task for it
    // The delegate flow for updating the custom UI here is anti patteren which will also be refactor soon. Prevented me from creating a VM file at the current state because it will be too much boilerplate code
    func configure(onlineViewingUsersVM: SPOnlineViewingUsersCounterViewModeling) {
        onlineViewingUsersView.configure(with: onlineViewingUsersVM)
    }

    private func setupUI() {
        self.addSubview(titleLabel)
        titleLabel.OWSnp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(Metrics.margins.left)
        }

        self.addSubview(counterLabel)
        counterLabel.OWSnp.makeConstraints { make in
            make.firstBaseline.equalTo(titleLabel)
            make.leading.equalTo(titleLabel.OWSnp.trailing).offset(Metrics.counterLeading)
            make.trailing.lessThanOrEqualToSuperview()
        }

        self.addSubview(onlineViewingUsersView)
        onlineViewingUsersView.OWSnp.makeConstraints { make in
            make.centerY.equalTo(titleLabel)
            make.trailing.equalToSuperview().offset(-Metrics.margins.right)
        }

        applyAccessibility()
    }
}
