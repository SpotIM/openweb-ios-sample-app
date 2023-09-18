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
        static let avatarSideSize: CGFloat = 36.0
        static let avatarImageViewTrailingOffset: CGFloat = 8.0
        static let subscriberVerticalPadding: CGFloat = 7
        static let optionButtonSize: CGFloat = 20
        static let badgeHorizontalInset: CGFloat = 4
        static let commentReasonLabelFontSize: CGFloat = 17
        static let commentReasonLabelLineSpacing: CGFloat = 3.5

        static let identifier = "comment_header_view_id"
        static let userNameLabelIdentifier = "comment_header_user_name_label_id"
        static let userNameSubtitleLabelIdentifier = "comment_header_user_name_subtitle_label_id"
        static let badgeTagContainerIdentifier = "comment_header_user_badge_tag_container_id"
        static let badgeTagLabelIdentifier = "comment_header_user_badge_tag_label_id"
        static let subscriberBadgeViewIdentifier = "comment_header_user_subscriber_badge_view_id"
        static let dateLabelIdentifier = "comment_header_date_label_id"
        static let optionButtonIdentifier = "comment_header_option_button_id"
        static let hiddenMessageLabelIdentifier = "comment_header_hidden_message_label_id"
    }

    fileprivate var viewModel: OWCommentHeaderViewModeling!
    fileprivate var disposeBag: DisposeBag!

    fileprivate lazy var avatarImageView: OWAvatarView = {
        return OWAvatarView()
            .backgroundColor(.clear)
    }()

    fileprivate lazy var userNameLabel: UILabel = {
        let userNameLabel = UILabel()
            .userInteractionEnabled(true)
            .textColor(OWColorPalette.shared.color(type: .textColor3, themeStyle: .light))
            .font(OWFontBook.shared.font(typography: .footnoteContext))
            .clipsToBounds(true)
        userNameLabel.addGestureRecognizer(userNameTapGesture)
        return userNameLabel
    }()

    fileprivate lazy var userNameTapGesture: UITapGestureRecognizer = {
        return UITapGestureRecognizer()
    }()

    fileprivate lazy var badgeTagContainer: UIView = {
        return UIView()
            .border(width: 1, color: OWColorPalette.shared.color(type: .brandColor, themeStyle: .light))
            .corner(radius: 3)
            .isHidden(true)
    }()

    fileprivate lazy var badgeTagLabel: UILabel = {
        return UILabel()
            .font(OWFontBook.shared.font(typography: .infoCaption))
            .textColor(OWColorPalette.shared.color(type: .brandColor, themeStyle: .light))
    }()

    fileprivate lazy var subscriberBadgeView: OWSubscriberIconView = {
        return OWSubscriberIconView()
    }()

    fileprivate lazy var subtitleLabel: UILabel = {
        return UILabel()
            .font(OWFontBook.shared.font(typography: .metaText))
            .textColor(OWColorPalette.shared.color(type: .textColor2, themeStyle: .light))
            .userInteractionEnabled(false)
    }()

    fileprivate lazy var seperatorBetweenSubtitleAndDateLabel: UILabel = {
        return UILabel()
            .text(" · ")
            .font(OWFontBook.shared.font(typography: .metaText))
            .textColor(OWColorPalette.shared.color(type: .textColor2, themeStyle: .light))
            .userInteractionEnabled(false)
    }()

    fileprivate lazy var dateLabel: UILabel = {
        return UILabel()
            .font(OWFontBook.shared.font(typography: .metaText))
            .textColor(OWColorPalette.shared.color(type: .textColor2, themeStyle: .light))
            .userInteractionEnabled(false)
            .enforceSemanticAttribute()
    }()

    fileprivate lazy var optionButton: UIButton = {
        let image = UIImage(spNamed: "optionsIcon", supportDarkMode: true)
        return UIButton()
            .image(image, state: .normal)
            .imageEdgeInsets(UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -8))
    }()

    fileprivate lazy var hiddenCommentReasonLabel: UILabel = {
        return UILabel()
            .isHidden(true)
            .textColor(OWColorPalette.shared.color(type: .textColor2, themeStyle: .light))
            .font(OWFontBook.shared.font(typography: .bodySpecial))
            .lineSpacing(Metrics.commentReasonLabelLineSpacing)
            .enforceSemanticAttribute()
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
        self.seperatorBetweenSubtitleAndDateLabel.isHidden = false
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
        self.enforceSemanticAttribute()

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

        addSubview(subscriberBadgeView)
        subscriberBadgeView.OWSnp.makeConstraints { make in
            make.centerY.equalTo(userNameLabel.OWSnp.centerY)
            make.leading.equalTo(userNameLabel.OWSnp.trailing).offset(Metrics.subscriberVerticalPadding)
        }

        addSubview(optionButton)
        optionButton.OWSnp.makeConstraints { make in
            make.size.equalTo(Metrics.optionButtonSize)
            make.centerY.equalTo(userNameLabel)
            make.trailing.equalToSuperview()
        }

        addSubview(badgeTagContainer)
        badgeTagContainer.OWSnp.makeConstraints { make in
            make.centerY.equalTo(userNameLabel.OWSnp.centerY)
            make.leading.equalTo(subscriberBadgeView.OWSnp.trailing).offset(Metrics.subscriberVerticalPadding)
            make.trailing.lessThanOrEqualTo(optionButton.OWSnp.leading)
        }

        badgeTagContainer.addSubview(badgeTagLabel)
        badgeTagLabel.OWSnp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.left.equalToSuperview().offset(Metrics.badgeHorizontalInset)
            make.right.equalToSuperview().offset(-Metrics.badgeHorizontalInset)
        }

        addSubview(subtitleLabel)
        subtitleLabel.OWSnp.makeConstraints { make in
            make.top.equalTo(userNameLabel.OWSnp.bottom)
            make.leading.equalTo(userNameLabel)
            make.bottom.equalToSuperview()
        }

        addSubview(seperatorBetweenSubtitleAndDateLabel)
        seperatorBetweenSubtitleAndDateLabel.OWSnp.makeConstraints { make in
            make.top.bottom.equalTo(subtitleLabel)
            make.leading.equalTo(subtitleLabel.OWSnp.trailing)
        }

        addSubview(dateLabel)
        dateLabel.OWSnp.makeConstraints { make in
            make.top.bottom.equalTo(subtitleLabel)
            make.leading.equalTo(seperatorBetweenSubtitleAndDateLabel.OWSnp.trailing)
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
        userNameTapGesture.rx.event
            .voidify()
            .bind(to: viewModel.inputs.tapUserName)
            .disposed(by: disposeBag)

        viewModel.outputs.nameText
            .bind(to: userNameLabel.rx.text)
            .disposed(by: disposeBag)

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

        optionButton.rx.tap
            .map { [weak self] in
                return self?.optionButton
            }
            .unwrap()
            .bind(to: viewModel.inputs.tapMore)
            .disposed(by: disposeBag)

        viewModel.outputs.shouldShowSubtitleSeperator
            .map { !$0 }
            .bind(to: seperatorBetweenSubtitleAndDateLabel.rx.isHidden)
            .disposed(by: disposeBag)

        viewModel.outputs.shouldShowSubtitleSeperator
            .map { $0 ? " · " : ""}
            .bind(to: seperatorBetweenSubtitleAndDateLabel.rx.text)
            .disposed(by: disposeBag)

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
                self.seperatorBetweenSubtitleAndDateLabel.isHidden = isHiddenMessage

                self.hiddenCommentReasonLabel.isHidden = !isHiddenMessage
            }).disposed(by: disposeBag)

        viewModel.outputs.subscriberBadgeVM
            .outputs.isSubscriber
            .subscribe(onNext: { [weak self] isVisible in
                guard let self = self else { return }
                self.subscriberBadgeView.OWSnp.updateConstraints { make in
                    make.leading.equalTo(self.userNameLabel.OWSnp.trailing).offset(isVisible ? Metrics.subscriberVerticalPadding : 0)
                }
            })
            .disposed(by: disposeBag)

        OWSharedServicesProvider.shared.themeStyleService()
            .style
            .subscribe(onNext: { [weak self] currentStyle in
                guard let self = self else { return }
                self.userNameLabel.textColor = OWColorPalette.shared.color(type: .textColor3, themeStyle: currentStyle)
                self.subtitleLabel.textColor = OWColorPalette.shared.color(type: .textColor2, themeStyle: currentStyle)
                self.seperatorBetweenSubtitleAndDateLabel.textColor = OWColorPalette.shared.color(type: .textColor2, themeStyle: currentStyle)
                self.dateLabel.textColor = OWColorPalette.shared.color(type: .textColor2, themeStyle: currentStyle)
                self.hiddenCommentReasonLabel.textColor = OWColorPalette.shared.color(type: .textColor2, themeStyle: currentStyle)
                self.optionButton.image(UIImage(spNamed: "optionsIcon", supportDarkMode: true), state: .normal)
            })
            .disposed(by: disposeBag)

        Observable.combineLatest(OWSharedServicesProvider.shared.themeStyleService().style, OWColorPalette.shared.colorDriver)
            .subscribe(onNext: { [weak self] (style, colorMapper) -> Void in
                guard let self = self else { return }
                if let owBrandColor = colorMapper[.brandColor] {
                    let brandColor = owBrandColor.color(forThemeStyle: style)
                    self.badgeTagLabel.textColor = brandColor
                    self.badgeTagContainer.border(width: 1, color: brandColor)
                }
            })
            .disposed(by: disposeBag)

        OWSharedServicesProvider.shared.appLifeCycle()
            .didChangeContentSizeCategory
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.userNameLabel.font = OWFontBook.shared.font(typography: .footnoteContext)
                self.badgeTagLabel.font = OWFontBook.shared.font(typography: .infoCaption)
                self.subtitleLabel.font = OWFontBook.shared.font(typography: .metaText)
                self.seperatorBetweenSubtitleAndDateLabel.font = OWFontBook.shared.font(typography: .metaText)
                self.dateLabel.font = OWFontBook.shared.font(typography: .metaText)
                self.hiddenCommentReasonLabel.font = OWFontBook.shared.font(typography: .bodySpecial)
            })
            .disposed(by: disposeBag)
    }
}

// MARK: Accessibility

fileprivate extension OWCommentHeaderView {
    func applyAccessibility() {
        self.accessibilityIdentifier = Metrics.identifier
        userNameLabel.accessibilityIdentifier = Metrics.userNameLabelIdentifier
        badgeTagContainer.accessibilityIdentifier = Metrics.badgeTagContainerIdentifier
        badgeTagLabel.accessibilityIdentifier = Metrics.badgeTagLabelIdentifier
        subscriberBadgeView.accessibilityIdentifier = Metrics.subscriberBadgeViewIdentifier
        dateLabel.accessibilityIdentifier = Metrics.dateLabelIdentifier
        optionButton.accessibilityIdentifier = Metrics.optionButtonIdentifier
        optionButton.accessibilityTraits = .button
        optionButton.accessibilityLabel = OWLocalizationManager.shared.localizedString(key: "Options menu")
        hiddenCommentReasonLabel.accessibilityIdentifier = Metrics.hiddenMessageLabelIdentifier
        subtitleLabel.accessibilityIdentifier = Metrics.userNameSubtitleLabelIdentifier
    }
}
