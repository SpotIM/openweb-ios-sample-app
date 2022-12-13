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
        static let fontSize: CGFloat = 16.0
        static let badgeLabelFontSize: CGFloat = 12.0
        static let badgeLeadingPadding: CGFloat = 4
        static let subtitleTopPadding: CGFloat = 6
        static let optionButtonSize: CGFloat = 44
        
        static let identifier = "comment_header_view_id"
        static let userNameLabelIdentifier = "comment_header_user_name_label_id"
        static let badgeTagLabelIdentifier = "comment_header_user_badge_tag_label_id"
        static let subscriberBadgeViewIdentifier = "comment_header_user_subscriber_badge_view_id"
        static let dateLabelIdentifier = "comment_header_date_label_id"
        static let optionButtonIdentifier = "comment_header_option_button_id"
        
//        static let deletedMessageLabelIdentifier = "user_name_view_deleted_message_label_id"
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
    private lazy var subscriberBadgeView: OWUserSubscriberBadgeView = {
        return OWUserSubscriberBadgeView()
    }()
    fileprivate lazy var subtitleLabel: UILabel = {
        return UILabel()
            .font(.preferred(style: .medium, of: Metrics.fontSize))
            .textColor(OWColorPalette.shared.color(type: .foreground3Color, themeStyle: .light))
            .userInteractionEnabled(false)
    }()
    fileprivate lazy var dateLabel: UILabel = {
        return UILabel()
            .font(.preferred(style: .medium, of: Metrics.fontSize))
            .textColor(OWColorPalette.shared.color(type: .foreground3Color, themeStyle: .light))
            .userInteractionEnabled(false)
    }()
    fileprivate lazy var optionButton: UIButton = {
        let image = UIImage(spNamed: "menu_icon", supportDarkMode: true)
        return UIButton()
            .image(image, state: .normal)
            .imageEdgeInsets(UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -8))
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
        subscriberBadgeView.configure(with: viewModel.outputs.subscriberBadgeVM)
        
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
}

fileprivate extension OWCommentHeaderView {
    func setupViews() {
        addSubviews(avatarImageView, userNameLabel, badgeTagLabel, subscriberBadgeView, subtitleLabel, dateLabel, optionButton)
        
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
        
        subscriberBadgeView.OWSnp.makeConstraints { make in
            make.centerY.equalTo(userNameLabel.OWSnp.centerY)
            make.leading.equalTo(badgeTagLabel.OWSnp.trailing).offset(5.0)
        }
        
        subtitleLabel.OWSnp.makeConstraints { make in
            make.top.equalTo(userNameLabel.OWSnp.bottom).offset(Metrics.subtitleTopPadding)
            make.leading.equalTo(userNameLabel)
//            make.trailing.equalTo(dateLabel.OWSnp.leading)
        }
        
        dateLabel.OWSnp.makeConstraints { make in
            make.top.equalTo(subtitleLabel)
            make.leading.equalTo(subtitleLabel.OWSnp.trailing)
            make.trailing.lessThanOrEqualTo(optionButton.OWSnp.leading)
        }
        
        optionButton.OWSnp.makeConstraints { make in
            make.size.equalTo(Metrics.optionButtonSize)
            make.centerY.equalTo(userNameLabel)
            make.trailing.equalToSuperview()
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
                    .preferred(style: style, of: Metrics.fontSize)
                )
            }).disposed(by: disposeBag)
        
        viewModel.outputs.badgeTitle
            .bind(to: badgeTagLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.outputs.badgeTitle
            .map { $0.isEmpty }
            .bind(to: badgeTagLabel.rx.isHidden)
            .disposed(by: disposeBag)
        
        viewModel.outputs.subtitleText
            .bind(to: subtitleLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.outputs.dateText
            .bind(to: dateLabel.rx.text)
            .disposed(by: disposeBag)
        
        optionButton.rx.tap.subscribe(onNext: { [weak self] _ in
            guard let self = self else { return }
            self.viewModel.inputs.tapMore.onNext(self.optionButton)
            // TODO: handle tap!
        }).disposed(by: disposeBag)
        
        
        
        OWSharedServicesProvider.shared.themeStyleService()
            .style
            .subscribe(onNext: { [weak self] currentStyle in
                guard let self = self else { return }
                self.userNameLabel.textColor = OWColorPalette.shared.color(type: .foreground1Color, themeStyle: currentStyle)
                self.subtitleLabel.textColor = OWColorPalette.shared.color(type: .foreground3Color, themeStyle: currentStyle)
            }).disposed(by: disposeBag)
    }
}

// MARK: Accessibility

extension OWCommentHeaderView {
    func applyAccessibility() {
        self.accessibilityIdentifier = Metrics.identifier
        userNameLabel.accessibilityIdentifier = Metrics.userNameLabelIdentifier
        badgeTagLabel.accessibilityIdentifier = Metrics.badgeTagLabelIdentifier
        subscriberBadgeView.accessibilityIdentifier = Metrics.subscriberBadgeViewIdentifier
        dateLabel.accessibilityIdentifier = Metrics.dateLabelIdentifier
        optionButton.accessibilityIdentifier = Metrics.optionButtonIdentifier
        optionButton.accessibilityTraits = .button
        optionButton.accessibilityLabel = LocalizationManager.localizedString(key: "Options menu")
        
//
        
//        hiddenCommentReasonLabel.accessibilityIdentifier = Metrics.deletedMessageLabelIdentifier
        
//

    }
}
