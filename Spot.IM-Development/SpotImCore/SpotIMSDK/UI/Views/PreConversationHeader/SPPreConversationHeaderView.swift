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

internal final class SPPreConversationHeaderView: BaseView {
    
    private lazy var titleLabel: BaseLabel = {
        let lbl = BaseLabel()
        lbl.font = UIFont.preferred(style: .bold, of: Metrics.titleFontSize)
        lbl.textColor = .spForeground0
        return lbl
    }()
    
    private lazy var counterLabel: BaseLabel = {
        let lbl = BaseLabel()
        lbl.font = UIFont.preferred(style: .regular, of: Metrics.counterFontSize)
        lbl.textColor = .spForeground1
        return lbl
    }()
    
    private lazy var onlineViewingUsersView: OWOnlineViewingUsersCounterView = {
       return OWOnlineViewingUsersCounterView()
    }()
    
    internal weak var delegate: SPPreConversationHeaderViewDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    // Handle dark mode \ light mode change
    func updateColorsAccordingToStyle() {
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
    // I decided to wait until we will choose if to use RxSwift or Combine and then I will refactor it
    // The delegate flow for updating the custom UI here is anti patteren which will also be refactor soon. Prevented me from creating a VM file at the current state because it will be too much boilerplate code
    func configure(onlineViewingUsersVM: OWOnlineViewingUsersCounterViewModeling) {
        onlineViewingUsersView.configure(with: onlineViewingUsersVM)
    }

    private func setupUI() {
        self.addSubview(titleLabel)
        titleLabel.layout {
            $0.centerY.equal(to: centerYAnchor)
            $0.leading.equal(to: leadingAnchor, offsetBy: Metrics.margins.left)
        }
        
        self.addSubview(counterLabel)
        counterLabel.layout {
            $0.firstBaseline.equal(to: titleLabel.firstBaselineAnchor)
            $0.leading.equal(to: titleLabel.trailingAnchor, offsetBy: Metrics.counterLeading)
            $0.trailing.lessThanOrEqual(to: trailingAnchor)
        }
        
        self.addSubview(onlineViewingUsersView)
        onlineViewingUsersView.layout {
            $0.centerY.equal(to: titleLabel.centerYAnchor)
            $0.trailing.equal(to: trailingAnchor, offsetBy: -Metrics.margins.right)
        }
    }
}

private extension SPPreConversationHeaderView {
    private enum Metrics {
        static let counterLeading: CGFloat = 5
        static let titleFontSize: CGFloat = 25
        static let counterFontSize: CGFloat = 16
        static let margins: UIEdgeInsets = .init(top: 16, left: 16, bottom: 16, right: 16)
    }
}
