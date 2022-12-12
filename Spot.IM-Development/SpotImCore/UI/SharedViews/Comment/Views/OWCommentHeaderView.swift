//
//  OWCommentHeaderView.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 07/12/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class OWCommentHeaderView: UIView {
    
    fileprivate struct Metrics {
        static let topOffset: CGFloat = 14.0
        static let topCollapsedOffset: CGFloat = 38.0
        static let leadingOffset: CGFloat = 16.0
        static let userViewHeight: CGFloat = 44.0
        static let userViewExpandedHeight: CGFloat = 69.0
        static let avatarSideSize: CGFloat = 39.0
        static let avatarImageViewTrailingOffset: CGFloat = 11.0
        static let usernameFontSize: CGFloat = 16.0
        static let badgeLabelFontSize: CGFloat = 12.0
        static let badgeLeadingPadding: CGFloat = 4
        
        static let identifier = "comment_header_view_id"
        static let userNameLabelIdentifier = "comment_header_user_name_label_id"
        static let badgeTagLabelIdentifier = "comment_header_user_badge_tag_label_id"
//        static let moreButtonIdentifier = "user_name_view_more_button_id"
//        static let dateLabelIdentifier = "user_name_view_date_label_id"
//        static let deletedMessageLabelIdentifier = "user_name_view_deleted_message_label_id"
//        static let subscriberBadgeViewIdentifier = "user_name_view_subscriber_badge_view_id"
    }
    
    fileprivate var viewModel: OWCommentHeaderViewModeling!
    fileprivate var disposeBag: DisposeBag!
        
    fileprivate let avatarImageView: SPAvatarView = SPAvatarView()
    fileprivate lazy var userNameLabel: UILabel = {
        return UILabel()
            .userInteractionEnabled(false)
            .textColor(OWColorPalette.shared.color(type: .foreground1Color, themeStyle: .light))
    }()
    fileprivate lazy var badgeTagLabel: UILabel = {
        return UILabel()
            .font(.preferred(style: .medium, of: Metrics.badgeLabelFontSize))
            .border(width: 1, color: .brandColor)
            .corner(radius: 3)
            .textColor(.brandColor)
            // TODO: inset!
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
        applyAccessibility()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with model: OWCommentHeaderViewModeling) {
        self.viewModel = model
        avatarImageView.configure(with: viewModel.outputs.avatarVM)
        
        disposeBag = DisposeBag()
        setupObservers()
//        userNameView.configure(with: viewModel.outputs.userNameVM)

//        let userViewHeight = model.usernameViewHeight()
//        userNameView.OWSnp.updateConstraints { make in
//            make.height.equalTo(userViewHeight)
//        }
    }
    
    func setDelegate(_ delegate: SPCommentCellDelegate?) {
        guard let delegate = delegate,
              let vm = self.viewModel
        else { return }
//        vm.inputs.setDelegate(delegate)
    }
    
    // Handle dark mode \ light mode change
    func updateColorsAccordingToStyle() {
        backgroundColor = .spBackground0
//        userNameView.updateColorsAccordingToStyle()
        avatarImageView.updateColorsAccordingToStyle()
    }
}

fileprivate extension OWCommentHeaderView {
    func setupViews() {
        addSubviews(avatarImageView, userNameLabel, badgeTagLabel)
        
        // Setup avatar
        avatarImageView.OWSnp.makeConstraints { make in
            make.leading.top.equalToSuperview()
            make.trailing.equalTo(userNameLabel.OWSnp.leading).offset(-Metrics.avatarImageViewTrailingOffset)
            make.size.equalTo(Metrics.avatarSideSize)
        }
        
        // Setup user name view
        userNameLabel.OWSnp.makeConstraints { make in
            make.top.equalToSuperview()
        }
        
        badgeTagLabel.OWSnp.makeConstraints { make in
            make.centerY.equalTo(userNameLabel.OWSnp.centerY)
            make.leading.equalTo(userNameLabel.OWSnp.trailing).offset(Metrics.badgeLeadingPadding)
        }
    }
    
    func setupObservers() {
        viewModel.outputs.nameText
            .bind(to: userNameLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.outputs.nameTextStyle
            .subscribe(onNext: { [weak self] style in
                guard let self = self else { return }
                self.userNameLabel.font(
                    .preferred(style: style, of: Metrics.usernameFontSize)
                )
            }).disposed(by: disposeBag)
        
        viewModel.outputs.badgeTitle
            .bind(to: badgeTagLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.outputs.badgeTitle
            .map { $0.isEmpty }
            .bind(to: badgeTagLabel.rx.isHidden)
            .disposed(by: disposeBag)
        
        OWSharedServicesProvider.shared.themeStyleService()
            .style
            .subscribe(onNext: { [weak self] currentStyle in
                guard let self = self else { return }
                self.userNameLabel.textColor = OWColorPalette.shared.color(type: .foreground1Color, themeStyle: currentStyle)
            }).disposed(by: disposeBag)
    }
}

// MARK: Accessibility

extension OWCommentHeaderView {
    func applyAccessibility() {
        self.accessibilityIdentifier = Metrics.identifier
        userNameLabel.accessibilityIdentifier = Metrics.userNameLabelIdentifier
        badgeTagLabel.accessibilityIdentifier = Metrics.badgeTagLabelIdentifier
//        moreButton.accessibilityIdentifier = Metrics.moreButtonIdentifier
//        dateLabel.accessibilityIdentifier = Metrics.dateLabelIdentifier
//        hiddenCommentReasonLabel.accessibilityIdentifier = Metrics.deletedMessageLabelIdentifier
//        subscriberBadgeView.accessibilityIdentifier = Metrics.subscriberBadgeViewIdentifier
//
//        moreButton.accessibilityTraits = .button
//        moreButton.accessibilityLabel = LocalizationManager.localizedString(key: "Options menu")
    }
}
