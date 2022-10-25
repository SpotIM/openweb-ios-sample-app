//
//  OWPreConversationHeaderView.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 24/10/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import UIKit

protocol OWPreConversationHeaderViewDelegate: AnyObject {
    func updateHeaderCustomUI(titleLabel: UILabel, counterLabel: UILabel)
}

internal final class OWPreConversationHeaderView: OWBaseView {
    fileprivate struct Metrics {
        static let counterLeading: CGFloat = 5
        static let titleFontSize: CGFloat = 25
        static let counterFontSize: CGFloat = 16
        static let margins: UIEdgeInsets = .init(top: 16, left: 16, bottom: 16, right: 16)
        static let identifier = "pre_conversation_header_view_id"
    }
    
    private lazy var titleLabel: OWBaseLabel = {
        let lbl = OWBaseLabel()
        lbl.font = UIFont.preferred(style: .bold, of: Metrics.titleFontSize)
        lbl.textColor = .spForeground0
        lbl.text = LocalizationManager.localizedString(key: "Conversation")
        return lbl
    }()
    
    private lazy var counterLabel: OWBaseLabel = {
        let lbl = OWBaseLabel()
        lbl.font = UIFont.preferred(style: .regular, of: Metrics.counterFontSize)
        lbl.textColor = .spForeground1
        return lbl
    }()
    
    private lazy var onlineViewingUsersView: OWOnlineViewingUsersCounterView = {
       return OWOnlineViewingUsersCounterView()  // TODO: use VM
    }()
    
    internal weak var delegate: OWPreConversationHeaderViewDelegate?
    
    init(onlineViewingUsersCounterVM: OWOnlineViewingUsersCounterViewModeling) {
        super.init(frame: .zero)
        self.accessibilityIdentifier = Metrics.identifier
        onlineViewingUsersView.configure(with: onlineViewingUsersCounterVM) // TODO: do not use configure :)
        setupUI()
        setupObservers()
    }
    
    // Handle dark mode \ light mode change
    func updateColorsAccordingToStyle() {
        titleLabel.textColor = .spForeground0
        counterLabel.textColor = .spForeground1
        updateCustomUI()
    }
    
    private func updateCustomUI() {
        delegate?.updateHeaderCustomUI(titleLabel: titleLabel, counterLabel: counterLabel)
    }

    // TODO: should be set from VM
    internal func set(commentCount: String?) {
        counterLabel.fadeTransition(1.0)
        if let commentCount = commentCount {
            counterLabel.text = "(\(commentCount))"
        } else {
            counterLabel.text = nil
        }
        updateCustomUI()
    }
}

fileprivate extension OWPreConversationHeaderView {
    func setupUI() {
        self.addSubview(titleLabel)
        titleLabel.OWSnp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
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
    }
    
    func setupObservers() {
        
    }
}

