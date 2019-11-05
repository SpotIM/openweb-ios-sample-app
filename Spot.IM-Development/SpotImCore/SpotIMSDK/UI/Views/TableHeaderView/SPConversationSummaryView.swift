//
//  SPConversationSummaryView.swift
//  Spot.IM-Core
//
//  Created by Eugene on 7/29/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import UIKit

internal protocol SPConversationSummaryViewDelegate: class {
    
    func sortingDidTap(_ summaryView: SPConversationSummaryView, sender: UIView)
    func newCommentsDidTap(_ summaryView: SPConversationSummaryView)

}

final class SPConversationSummaryView: BaseView {

    private let commentsCountLabel: UILabel = .init()
    private let separatorView: UIView = .init()
    private let sortButton: UIButton = .init(type: .system)
    private let newCommentsButton: UIButton = .init(type: .system)

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
        configureButtonsTargets()
    }
    
    // MARK: - Internal methods

    func updateNewComments(_ newCommentsCount: Int) {
        newCommentsButton.isHidden = newCommentsCount <= 0
        let newString: String = LocalizationManager.localizedString(key: "NEW")
        newCommentsButton.setTitle("\(newCommentsCount) " + newString, for: .normal)
    }
    
    func updateCommentsLabel(_ newCommentsCount: Int) {
        let commentsText: String = newCommentsCount > 1 ?
            LocalizationManager.localizedString(key: "Comments") :
            LocalizationManager.localizedString(key: "Comment")
        commentsCountLabel.text = "\(newCommentsCount.formatedCount()) " + commentsText
    }
    
    func updateSortOption(_ title: String) {
        sortButton.setTitle(title, for: .normal)
    }
    
    // MARK: - Selectors
    
    private func configureButtonsTargets() {
        sortButton.addTarget(self, action: #selector(selectSorting), for: .touchUpInside)
        newCommentsButton.addTarget(self, action: #selector(selectNewComments), for: .touchUpInside)
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
        addSubviews(commentsCountLabel, newCommentsButton, sortButton, separatorView)
        
        configureCommentCountLabel()
        configureSortButton()
        configureNewCommentsButton()
        configureSeparatorView()
    }
    
    private func configureCommentCountLabel() {
        commentsCountLabel.textColor = .spForeground4
        commentsCountLabel.backgroundColor = .spBackground0
        commentsCountLabel.font = UIFont.roboto(style: .regular, of: Theme.commentsFontSize)
        commentsCountLabel.layout {
            $0.leading.equal(to: leadingAnchor, offsetBy: Theme.sideOffset)
            $0.centerY.equal(to: centerYAnchor)
        }
    }
    
    private func configureSortButton() {
        let sortIcon = UIImage(spNamed: "sortingIcon")?.withRenderingMode(.alwaysOriginal)
        sortButton.setTitleColor(.spForeground4, for: .normal)
        sortButton.titleLabel?.font = UIFont.roboto(style: .regular, of: Theme.sortButtonFontSize)
        sortButton.setImage(sortIcon, for: .normal)
        let spacing: CGFloat = Theme.insetTiny
        var inset: CGFloat = spacing / 2
        
        // Update insets in order to make additional space begween title and image
        if UIView.appearance().semanticContentAttribute == .forceRightToLeft {
            inset = -inset
        }
        
        sortButton.imageEdgeInsets = UIEdgeInsets(top: 0.0, left: -inset, bottom: 0.0, right: inset)
        sortButton.titleEdgeInsets = UIEdgeInsets(top: 0.0, left: inset, bottom: 0.0, right: -inset)
        sortButton.contentEdgeInsets = UIEdgeInsets(top: 0.0, left: inset, bottom: 0.0, right: inset)
        
        // Transform Button in order to put image to the right
        sortButton.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        sortButton.titleLabel?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        sortButton.imageView?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        
        sortButton.layout {
            $0.trailing.equal(to: trailingAnchor, offsetBy: -Theme.sideOffset)
            $0.bottom.equal(to: bottomAnchor)
            $0.top.equal(to: topAnchor)
        }
    }
    
    private func configureNewCommentsButton() {
        newCommentsButton.isHidden = true
        newCommentsButton.setTitleColor(.white, for: .normal)
        newCommentsButton.titleLabel?.font = UIFont.roboto(style: .regular, of: Theme.newCommentsFontSize)
        newCommentsButton.contentEdgeInsets = UIEdgeInsets(
            top: Theme.newCommentsButtonVerticalInset,
            left: Theme.newCommentsButtonHorizontalInset,
            bottom: Theme.newCommentsButtonVerticalInset,
            right: Theme.newCommentsButtonHorizontalInset
        )
        newCommentsButton.backgroundColor = .brandColor
        newCommentsButton.addCornerRadius(Theme.newCommentsButtonRadius)
        
        newCommentsButton.layout {
            $0.leading.equal(to: commentsCountLabel.trailingAnchor, offsetBy: Theme.insetTiny)
            $0.centerY.equal(to: centerYAnchor)
        }
    }
    
    private func configureSeparatorView() {
        separatorView.backgroundColor = .spSeparator2
        
        separatorView.layout {
            $0.leading.equal(to: leadingAnchor)
            $0.bottom.equal(to: bottomAnchor)
            $0.trailing.equal(to: trailingAnchor)
            $0.height.equal(to: Theme.separatorHeight)
        }
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
        layer.shadowOpacity = Theme.viewShadowOpacity
        layer.shadowPath = shadowPath.cgPath
    }
}

private enum Theme {
    
    static let newCommentsButtonVerticalInset: CGFloat = 4.0
    static let newCommentsButtonHorizontalInset: CGFloat = 7.0
    static let separatorHeight: CGFloat = 1.0
    static let insetTiny: CGFloat = 9.0
    static let insetShort: CGFloat = 10.0
    static let newCommentsButtonRadius: CGFloat = 11.5
    static let sortButtonFontSize: CGFloat = 15.0
    static let commentsFontSize: CGFloat = 15.0
    static let newCommentsFontSize: CGFloat = 13.0
    static let sideOffset: CGFloat = 16.0
    static let viewShadowOpacity: Float = 0.08
}
