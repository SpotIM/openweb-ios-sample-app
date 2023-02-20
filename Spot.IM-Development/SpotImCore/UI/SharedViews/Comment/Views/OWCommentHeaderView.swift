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

class OWCommentHeaderView: UIView {

    fileprivate struct Metrics {
        static let avatarSideSize: CGFloat = 39.0
        static let avatarImageViewTrailingOffset: CGFloat = 11.0
        static let fontSize: CGFloat = 16.0
        static let badgeLabelFontSize: CGFloat = 12.0
        static let badgeLeadingPadding: CGFloat = 4
        static let subtitleTopPadding: CGFloat = 6
        static let optionButtonSize: CGFloat = 44
        static let badgeHorizontalInset: CGFloat = 4
        static let badgeVerticalInset: CGFloat = 2

        static let identifier = "comment_header_view_id"
        static let userNameLabelIdentifier = "comment_header_user_name_label_id"
        static let badgeTagLabelIdentifier = "comment_header_user_badge_tag_label_id"
        static let subscriberBadgeViewIdentifier = "comment_header_user_subscriber_badge_view_id"
        static let dateLabelIdentifier = "comment_header_date_label_id"
        static let optionButtonIdentifier = "comment_header_option_button_id"
        static let hiddenMessageLabelIdentifier = "comment_header_hidden_message_label_id"
    }

    fileprivate var viewModel: OWCommentHeaderViewModeling!
    fileprivate var disposeBag: DisposeBag!

    fileprivate lazy var avatarImageView: SPAvatarView = {
        return SPAvatarView()
            .backgroundColor(.clear)
    }()

    fileprivate lazy var userNameLabel: UILabel = {
        return UILabel()
            .userInteractionEnabled(false)
            .textColor(OWColorPalette.shared.color(type: .foreground1Color, themeStyle: .light))
    }()

    fileprivate lazy var badgeTagContainer: UIView = {
        return UIView()
            .border(width: 1, color: OWColorPalette.shared.color(type: .brandColor, themeStyle: .light))
            .corner(radius: 3)
            .isHidden(true)
    }()

    fileprivate lazy var badgeTagLabel: UILabel = {
        return UILabel()
            .font(.preferred(style: .medium, of: Metrics.badgeLabelFontSize))
            .textColor(OWColorPalette.shared.color(type: .brandColor, themeStyle: .light))
    }()

    fileprivate lazy var subscriberBadgeView: OWUserSubscriberBadgeView = {
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

    fileprivate lazy var hiddenCommentReasonLabel: UILabel = {
        return UILabel()
            .isHidden(true)
            .textColor(OWColorPalette.shared.color(type: .foreground3Color, themeStyle: .light))
            .font(.preferred(style: .italic, of: 17))
            .lineSpacing(3.5)
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupViews()
        applyAccessibility()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with viewModel: OWCommentHeaderViewModeling) {
        self.viewModel = viewModel
        avatarImageView.configure(with: viewModel.outputs.avatarVM)
        subscriberBadgeView.configure(with: viewModel.outputs.subscriberBadgeVM)

        disposeBag = DisposeBag()
        setupObservers()
    }

    func prepareForReuse() {
        self.dateLabel.isHidden = false
        self.optionButton.isHidden = false
        self.userNameLabel.isHidden = false
        self.subtitleLabel.isHidden = false
        self.subscriberBadgeView.isHidden = false

        self.badgeTagContainer.isHidden = true
        self.hiddenCommentReasonLabel.isHidden = true
    }
}

fileprivate extension OWCommentHeaderView {
    func setupViews() {
        addSubview(userNameLabel)
        userNameLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        userNameLabel.OWSnp.makeConstraints { make in
            make.top.equalToSuperview()
        }

        addSubview(avatarImageView)
        avatarImageView.OWSnp.makeConstraints { make in
            make.leading.top.equalToSuperview()
            make.trailing.equalTo(userNameLabel.OWSnp.leading).offset(-Metrics.avatarImageViewTrailingOffset)
            make.size.equalTo(Metrics.avatarSideSize)
        }

        addSubview(badgeTagContainer)
        badgeTagContainer.OWSnp.makeConstraints { make in
            make.centerY.equalTo(userNameLabel.OWSnp.centerY)
            make.leading.equalTo(userNameLabel.OWSnp.trailing).offset(Metrics.badgeLeadingPadding)
        }

        badgeTagContainer.addSubview(badgeTagLabel)
        badgeTagLabel.OWSnp.makeConstraints { make in
            make.top.equalToSuperview().offset(Metrics.badgeVerticalInset)
            make.bottom.equalToSuperview().offset(-Metrics.badgeVerticalInset)
            make.left.equalToSuperview().offset(Metrics.badgeHorizontalInset)
            make.right.equalToSuperview().offset(-Metrics.badgeHorizontalInset)
        }

        addSubview(optionButton)
        optionButton.OWSnp.makeConstraints { make in
            make.size.equalTo(Metrics.optionButtonSize)
            make.centerY.equalTo(userNameLabel)
            make.trailing.equalToSuperview()
        }

        addSubview(subscriberBadgeView)
        subscriberBadgeView.OWSnp.makeConstraints { make in
            make.centerY.equalTo(userNameLabel.OWSnp.centerY)
            make.leading.equalTo(badgeTagContainer.OWSnp.trailing).offset(5.0)
            make.trailing.lessThanOrEqualTo(optionButton.OWSnp.leading)
        }

        addSubview(subtitleLabel)
        subtitleLabel.OWSnp.makeConstraints { make in
            make.top.equalTo(userNameLabel.OWSnp.bottom).offset(Metrics.subtitleTopPadding)
            make.leading.equalTo(userNameLabel)
            make.bottom.equalToSuperview()
        }

        addSubview(dateLabel)
        dateLabel.OWSnp.makeConstraints { make in
            make.top.bottom.equalTo(subtitleLabel)
            make.leading.equalTo(subtitleLabel.OWSnp.trailing)
            make.trailing.lessThanOrEqualTo(optionButton.OWSnp.leading)
        }

        addSubview(hiddenCommentReasonLabel)
        hiddenCommentReasonLabel.OWSnp.makeConstraints { make in
            make.trailing.bottom.equalToSuperview()
            make.centerY.equalTo(avatarImageView.OWSnp.centerY)
            make.leading.equalTo(avatarImageView.OWSnp.trailing).offset(Metrics.avatarImageViewTrailingOffset)
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
            .bind(to: badgeTagContainer.rx.isHidden)
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

        viewModel.outputs.hiddenCommentReasonText
            .bind(to: hiddenCommentReasonLabel.rx.text)
            .disposed(by: disposeBag)

        viewModel.outputs.shouldShowHiddenCommentMessage
            .subscribe(onNext: { [weak self] isHiddenMessage in
                guard let self = self,
                      isHiddenMessage
                else { return }

                self.dateLabel.isHidden = isHiddenMessage
                self.optionButton.isHidden = isHiddenMessage
                self.subscriberBadgeView.isHidden = isHiddenMessage
                self.userNameLabel.isHidden = isHiddenMessage
                self.badgeTagContainer.isHidden = isHiddenMessage
                self.subtitleLabel.isHidden = isHiddenMessage

                self.hiddenCommentReasonLabel.isHidden = !isHiddenMessage
            }).disposed(by: disposeBag)

        OWSharedServicesProvider.shared.themeStyleService()
            .style
            .subscribe(onNext: { [weak self] currentStyle in
                guard let self = self else { return }
                self.userNameLabel.textColor = OWColorPalette.shared.color(type: .foreground1Color, themeStyle: currentStyle)
                self.subtitleLabel.textColor = OWColorPalette.shared.color(type: .foreground3Color, themeStyle: currentStyle)
                self.dateLabel.textColor = OWColorPalette.shared.color(type: .foreground3Color, themeStyle: currentStyle)
                self.hiddenCommentReasonLabel.textColor = OWColorPalette.shared.color(type: .foreground3Color, themeStyle: currentStyle)
            }).disposed(by: disposeBag)
        
        OWColorPalette.shared.colorObservable(type: .brandColor)
            .subscribe(onNext: { [weak self] brandColor in
                guard let self = self else { return }
                self.badgeTagLabel.textColor = brandColor
                self.badgeTagContainer.border(width: 1, color: brandColor)
            })
            .disposed(by: disposeBag)
    }
}

// MARK: Accessibility

fileprivate extension OWCommentHeaderView {
    func applyAccessibility() {
        self.accessibilityIdentifier = Metrics.identifier
        userNameLabel.accessibilityIdentifier = Metrics.userNameLabelIdentifier
        badgeTagContainer.accessibilityIdentifier = Metrics.badgeTagLabelIdentifier
        subscriberBadgeView.accessibilityIdentifier = Metrics.subscriberBadgeViewIdentifier
        dateLabel.accessibilityIdentifier = Metrics.dateLabelIdentifier
        optionButton.accessibilityIdentifier = Metrics.optionButtonIdentifier
        optionButton.accessibilityTraits = .button
        optionButton.accessibilityLabel = LocalizationManager.localizedString(key: "Options menu")
        hiddenCommentReasonLabel.accessibilityIdentifier = Metrics.hiddenMessageLabelIdentifier
    }
}
