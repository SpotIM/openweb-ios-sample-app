//
//  SPConversationSummaryView.swift
//  Spot.IM-Core
//
//  Created by Eugene on 7/29/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import UIKit
import RxSwift

internal protocol SPConversationSummaryViewDelegate: AnyObject {

    func sortingDidTap(_ summaryView: SPConversationSummaryView, sender: UIView)
}

final class SPConversationSummaryView: OWBaseView {

    fileprivate struct Metrics {
        static let separatorHeight: CGFloat = 1.0
        static let separatorWidth: CGFloat = 1.0
        static let insetTiny: CGFloat = 9.0
        static let insetShort: CGFloat = 10.0
        static let sortButtonFontSize: CGFloat = 15.0
        static let commentsFontSize: CGFloat = 15.0
        static let newCommentsFontSize: CGFloat = 13.0
        static let sideOffset: CGFloat = 16.0
        static let viewShadowOpacity: Float = 0.08
        static let horizontalMarginBetweenSeparator: CGFloat = 9.5
        static let topMarginBetweenSeparator: CGFloat = 15.5
        
        static let identifier = "conversation_summary_id"
        static let commentsCountLabelIdentifier = "comments_count_label_id"
        static let sortButtonIdentifier = "sort_button_id"
        static let onlineViewingUsersIdentifier = "online_viewing_users_id"
        static let bottomHorizontalSeparatorIdentifier = "bottom_horizontal_separator_id"
        static let verticalSeparatorBetweenCommentsAndViewingUsersIdentifier = "vertical_separator_between_comments_and_viewing_users_id"
    }
    
    private lazy var commentsCountLabel: OWBaseLabel = {
        let lbl = OWBaseLabel()
        lbl.font = UIFont.preferred(style: .regular, of: Metrics.commentsFontSize)
        return lbl
    }()
    
    private lazy var sortButton: OWBaseButton = {
        let btn = OWBaseButton()
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
    
    private lazy var onlineViewingUsersView: OWOnlineViewingUsersCounterView = {
       return OWOnlineViewingUsersCounterView()
    }()

    private lazy var bottomHorizontalSeparator: OWBaseView = {
        let separator = OWBaseView()
        separator.backgroundColor = .spSeparator2
        return separator
    }()
    
    private lazy var verticalSeparatorBetweenCommentsAndViewingUsers: OWBaseView = {
        let separator = OWBaseView()
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
    
    fileprivate var viewModel: OWConversationSummaryViewModeling!
    fileprivate var disposeBag: DisposeBag!
    
    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
        applyAccessibility()
    }
    
    private func applyAccessibility() {
        self.accessibilityIdentifier = Metrics.identifier
        commentsCountLabel.accessibilityIdentifier = Metrics.commentsCountLabelIdentifier
        sortButton.accessibilityIdentifier = Metrics.sortButtonIdentifier
        onlineViewingUsersView.accessibilityIdentifier = Metrics.onlineViewingUsersIdentifier
        bottomHorizontalSeparator.accessibilityIdentifier = Metrics.bottomHorizontalSeparatorIdentifier
        verticalSeparatorBetweenCommentsAndViewingUsers.accessibilityIdentifier = Metrics.verticalSeparatorBetweenCommentsAndViewingUsersIdentifier
    }
    
    // Handle dark mode \ light mode change
    func updateColorsAccordingToStyle() {
        backgroundColor = .spBackground0
        commentsCountLabel.textColor = .spForeground4
        commentsCountLabel.backgroundColor = .spBackground0
        sortButton.setTitleColor(.spForeground0, for: .normal)
        sortButton.setImage(UIImage(spNamed: "sortingIcon", supportDarkMode: true), for: .normal)
        bottomHorizontalSeparator.backgroundColor = .spSeparator2
        verticalSeparatorBetweenCommentsAndViewingUsers.backgroundColor = .spSeparator2
    }
    
    func configure(with viewModel: OWConversationSummaryViewModeling) {
        self.viewModel = viewModel
        disposeBag = DisposeBag()
        setupObservers()
    }
    
    // MARK: - Internal methods
    
    private func setupObservers() {
        onlineViewingUsersView.configure(with: viewModel.outputs.onlineViewingUsersVM)
        
        viewModel.outputs.conversationCommentsCountText
            .bind(to: commentsCountLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.outputs.conversationSortVM.outputs.selectedSortOption
            .map{ $0.title }
            .bind(to: sortButton.rx.title())
            .disposed(by: disposeBag)
    }
    
    // MARK: - Actions

    @objc
    private func selectSorting() {
        delegate?.sortingDidTap(self, sender: sortButton)
    }
}

extension SPConversationSummaryView {
    
    private func setupUI() {
        // Setup comments label
        self.addSubview(commentsCountLabel)
        commentsCountLabel.OWSnp.makeConstraints { make in
            // avoide device notch in landscape
            if #available(iOS 11.0, *) {
                make.leading.equalTo(safeAreaLayoutGuide).offset(Metrics.sideOffset)
            } else {
                make.leading.equalToSuperview().offset(Metrics.sideOffset)
            }
            make.centerY.equalToSuperview()
        }
        
        // Setup sort button
        self.addSubview(sortButton)
        sortButton.OWSnp.makeConstraints { make in
            // avoide device notch in landscape
            if #available(iOS 11.0, *) {
                make.trailing.equalTo(safeAreaLayoutGuide).offset(-Metrics.sideOffset)
            } else {
                make.trailing.equalToSuperview().offset(-Metrics.sideOffset)
            }
            make.top.bottom.equalToSuperview()
        }
        
        // Setup bottom horizontal separator
        self.addSubview(bottomHorizontalSeparator)
        bottomHorizontalSeparator.OWSnp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(Metrics.separatorHeight)
        }
        
        // Setup vertical separator between comments and viewingUsers
        self.addSubview(verticalSeparatorBetweenCommentsAndViewingUsers)
        verticalSeparatorBetweenCommentsAndViewingUsers.OWSnp.makeConstraints { make in
            make.leading.equalTo(commentsCountLabel.OWSnp.trailing).offset(Metrics.horizontalMarginBetweenSeparator)
            make.bottom.equalToSuperview().offset(-Metrics.topMarginBetweenSeparator)
            make.top.equalToSuperview().offset(Metrics.topMarginBetweenSeparator)
            make.width.equalTo(Metrics.separatorWidth)
        }
        
        // Setup online viewing users
        self.addSubview(onlineViewingUsersView)
        onlineViewingUsersView.OWSnp.makeConstraints { make in
            make.leading.equalTo(verticalSeparatorBetweenCommentsAndViewingUsers.OWSnp.trailing).offset(Metrics.horizontalMarginBetweenSeparator)
            make.centerY.equalToSuperview()
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
