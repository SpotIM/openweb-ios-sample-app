//
//  SPConversationSummaryView.swift
//  Spot.IM-Core
//
//  Created by Eugene on 7/29/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import UIKit

internal protocol SPConversationSummaryViewDelegate: AnyObject {

    func sortingDidTap(_ summaryView: SPConversationSummaryView, sender: UIView)
    func newCommentsDidTap(_ summaryView: SPConversationSummaryView)
}

final class SPConversationSummaryView: BaseView {

    private lazy var commentsCountLabel: BaseLabel = {
        let lbl = BaseLabel()
        lbl.font = UIFont.preferred(style: .regular, of: Metrics.commentsFontSize)
        return lbl
    }()
    
    // Product decision was to remove this label due to the online viewing users addition
    // Still might changed so I keep this code commented until the release of the feature
//    private lazy var sortByLabel: BaseLabel = {
//        let lbl = BaseLabel()
//        lbl.font = UIFont.preferred(style: .regular, of: Metrics.sortButtonFontSize)
//        lbl.text = LocalizationManager.localizedString(key: "Sort by")
//        return lbl
//    }()
    
    private lazy var sortButton: BaseButton = {
        let btn = BaseButton()
        btn.titleLabel?.font = UIFont.preferred(style: .bold, of: Metrics.sortButtonFontSize)
        let spacing: CGFloat = Metrics.insetTiny
        var inset: CGFloat = spacing / 2
        
        // Update insets in order to make additional space begween title and image
        if LocalizationManager.currentLanguage?.isRightToLeft ?? false {
            inset = -inset
        }
        
        btn.imageEdgeInsets = UIEdgeInsets(top: 0.0, left: -inset, bottom: 0.0, right: inset)
        btn.titleEdgeInsets = UIEdgeInsets(top: 0.0, left: inset, bottom: 0.0, right: -inset)
        btn.contentEdgeInsets = UIEdgeInsets(top: 0.0, left: inset, bottom: 0.0, right: inset)
        
        // Transform Button in order to put image to the right
        btn.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        btn.titleLabel?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        btn.imageView?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        
        btn.addTarget(self, action: #selector(selectSorting), for: .touchUpInside)
        
        return btn
    }()
    
    // This button stay hidden, there is no part in the code which change it to be visible
    // Understand what it was and delete it if no longer in use
    // Will conflict with the vertical separator if in use. Therefor need to understand if it something old or we want it and then change the constraints accordingly
    private lazy var newCommentsButton: BaseButton = {
        let btn = BaseButton()

        btn.isHidden = true
        btn.titleLabel?.font = UIFont.preferred(style: .regular, of: Metrics.newCommentsFontSize)
        btn.contentEdgeInsets = UIEdgeInsets(
            top: Metrics.newCommentsButtonVerticalInset,
            left: Metrics.newCommentsButtonHorizontalInset,
            bottom: Metrics.newCommentsButtonVerticalInset,
            right: Metrics.newCommentsButtonHorizontalInset
        )
        btn.addCornerRadius(Metrics.newCommentsButtonRadius)
        
        btn.addTarget(self, action: #selector(selectNewComments), for: .touchUpInside)
        
        return btn
    }()
    
    private lazy var onlineViewingUsersView: OWOnlineViewingUsersCounterView = {
       return OWOnlineViewingUsersCounterView()
    }()

    private lazy var bottomHorizontalSeparator: BaseView = {
        let separator = BaseView()
        separator.backgroundColor = .spSeparator2
        return separator
    }()
    
    private lazy var verticalSeparatorBetweenCommentsAndViewingUsers: BaseView = {
        let separator = BaseView()
        separator.backgroundColor = .spSeparator2
        return separator
    }()
    
    internal var dropsShadow: Bool = false
    
    weak var delegate: SPConversationSummaryViewDelegate?
    
    override var bounds: CGRect {
        didSet {
            dropShadowIfNeeded()
        }
    }
    
    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    // Handle dark mode \ light mode change
    func updateColorsAccordingToStyle() {
        backgroundColor = .spBackground0
        commentsCountLabel.textColor = .spForeground4
        commentsCountLabel.backgroundColor = .spBackground0
        sortButton.setTitleColor(.spForeground0, for: .normal)
        sortButton.setImage(UIImage(spNamed: "sortingIcon"), for: .normal)
        // Product decision was to remove this label due to the online viewing users addition
        // Still might changed so I keep this code commented until the release of the feature
//        sortByLabel.textColor = .spForeground0
        newCommentsButton.setTitleColor(.white, for: .normal)
        newCommentsButton.backgroundColor = .brandColor
        bottomHorizontalSeparator.backgroundColor = .spSeparator2
        verticalSeparatorBetweenCommentsAndViewingUsers.backgroundColor = .spSeparator2
    }
    
    // MARK: - Internal methods    
    func updateCommentsLabel(_ newCommentsCount: Int) {
        let commentsText: String = newCommentsCount > 1 ?
            LocalizationManager.localizedString(key: "Comments") :
            LocalizationManager.localizedString(key: "Comment")
        commentsCountLabel.text = "\(newCommentsCount.formatedCount()) " + commentsText
    }
    
    func updateSortOption(_ title: String) {
        sortButton.setTitle(title, for: .normal)
    }
    
    // Idealy this summary view will have a VM as well which will hold the online users VM
    // I decided to wait until we will choose if to use RxSwift or Combine and then I will refactor it
    func configure(onlineViewingUsersVM: OWOnlineViewingUsersCounterViewModeling) {
        onlineViewingUsersView.configure(with: onlineViewingUsersVM)
    }
    
    // MARK: - Actions

    @objc
    private func selectSorting() {
        delegate?.sortingDidTap(self, sender: sortButton)
    }
    
    @objc
    private func selectNewComments() {
        delegate?.newCommentsDidTap(self)
    }
}

extension SPConversationSummaryView {
    
    private func setupUI() {
        // Setup comments label
        self.addSubview(commentsCountLabel)
        commentsCountLabel.layout {
            // avoide device notch in landscape
            if #available(iOS 11.0, *) {
                $0.leading.equal(to: safeAreaLayoutGuide.leadingAnchor, offsetBy: Metrics.sideOffset)
            } else {
                $0.leading.equal(to: leadingAnchor, offsetBy: Metrics.sideOffset)
            }
            $0.centerY.equal(to: centerYAnchor)
        }
        
        // Product decision was to remove this label due to the online viewing users addition
        // Still might changed so I keep this code commented until the release of the feature
//        // Setup sort label
//        self.addSubview(sortByLabel)
//        sortByLabel.layout {
//            $0.trailing.equal(to: sortButton.leadingAnchor, offsetBy: -Metrics.sortByTrailingOffset)
//            $0.bottom.equal(to: bottomAnchor)
//            $0.top.equal(to: topAnchor)
//        }
        
        // Setup sort button
        self.addSubview(sortButton)
        sortButton.layout {
            // avoide device notch in landscape
            if #available(iOS 11.0, *) {
                $0.trailing.equal(to: safeAreaLayoutGuide.trailingAnchor, offsetBy: -Metrics.sideOffset)
            } else {
                $0.trailing.equal(to: trailingAnchor, offsetBy: -Metrics.sideOffset)
            }
            $0.bottom.equal(to: bottomAnchor)
            $0.top.equal(to: topAnchor)
        }
        
        // Setup new comments button
        self.addSubview(newCommentsButton)
        newCommentsButton.layout {
            $0.leading.equal(to: commentsCountLabel.trailingAnchor, offsetBy: Metrics.insetTiny)
            $0.centerY.equal(to: centerYAnchor)
        }
        
        // Setup bottom horizontal separator
        self.addSubview(bottomHorizontalSeparator)
        bottomHorizontalSeparator.layout {
            $0.leading.equal(to: leadingAnchor)
            $0.bottom.equal(to: bottomAnchor)
            $0.trailing.equal(to: trailingAnchor)
            $0.height.equal(to: Metrics.separatorHeight)
        }
        
        // Setup vertical separator between comments and viewingUsers
        self.addSubview(verticalSeparatorBetweenCommentsAndViewingUsers)
        verticalSeparatorBetweenCommentsAndViewingUsers.layout {
            $0.leading.equal(to: commentsCountLabel.trailingAnchor, offsetBy: Metrics.horizontalMarginBetweenSeparator)
            $0.bottom.equal(to: bottomAnchor, offsetBy: -Metrics.topMarginBetweenSeparator)
            $0.top.equal(to: topAnchor, offsetBy: Metrics.topMarginBetweenSeparator)
            $0.width.equal(to: Metrics.separatorWidth)
        }
        
        // Setup online viewing users
        self.addSubview(onlineViewingUsersView)
        onlineViewingUsersView.layout {
            $0.leading.equal(to: verticalSeparatorBetweenCommentsAndViewingUsers.trailingAnchor, offsetBy: Metrics.horizontalMarginBetweenSeparator)
            $0.centerY.equal(to: centerYAnchor)
        }
        
        updateColorsAccordingToStyle()
    }
    
    private func dropShadowIfNeeded() {
        guard dropsShadow else {
            layer.shadowPath = nil
            return
        }
        let shadowRect = CGRect(x: 0.0, y: bounds.height / 2, width: bounds.width, height: bounds.height / 2)
        let shadowPath = UIBezierPath(rect: shadowRect)
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        layer.shadowOpacity = Metrics.viewShadowOpacity
        layer.shadowPath = shadowPath.cgPath
    }
}

private enum Metrics {
    
    static let newCommentsButtonVerticalInset: CGFloat = 4.0
    static let newCommentsButtonHorizontalInset: CGFloat = 7.0
    static let separatorHeight: CGFloat = 1.0
    static let separatorWidth: CGFloat = 1.0
    static let insetTiny: CGFloat = 9.0
    static let insetShort: CGFloat = 10.0
    static let newCommentsButtonRadius: CGFloat = 11.5
    static let sortButtonFontSize: CGFloat = 15.0
    static let commentsFontSize: CGFloat = 15.0
    static let newCommentsFontSize: CGFloat = 13.0
    static let sortByTrailingOffset: CGFloat = 4.0
    static let sideOffset: CGFloat = 16.0
    static let viewShadowOpacity: Float = 0.08
    static let horizontalMarginBetweenSeparator: CGFloat = 9.5
    static let topMarginBetweenSeparator: CGFloat = 15.5
}
