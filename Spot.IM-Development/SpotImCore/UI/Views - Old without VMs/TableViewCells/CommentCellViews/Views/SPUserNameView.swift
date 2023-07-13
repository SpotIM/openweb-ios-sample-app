//
//  UserNameView.swift
//  Spot.IM-Core
//
//  Created by Andriy Fedin on 27/09/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

internal final class SPUserNameView: SPBaseView {

    enum ContentType {
        case comment, reply
    }

    fileprivate struct Metrics {
        static let fontSize: CGFloat = 16.0
        static let labelFontSize: CGFloat = 12.0
        static let usernameTrailingPadding: CGFloat = 25.0
        static let badgeLeadingPadding: CGFloat = 4
        static let badgeHorizontalInset: CGFloat = 4
        static let badgeVerticalInset: CGFloat = 2
        static let subtitleTopPadding: CGFloat = 6
        static let identifier = "user_name_view_id"
        static let userNameLabelIdentifier = "user_name_view_user_name_label_id"
        static let badgeTagLabelIdentifier = "user_name_view_badge_tag_label_id"
        static let moreButtonIdentifier = "user_name_view_more_button_id"
        static let dateLabelIdentifier = "user_name_view_date_label_id"
        static let deletedMessageLabelIdentifier = "user_name_view_deleted_message_label_id"
        static let subscriberBadgeViewIdentifier = "user_name_view_subscriber_badge_view_id"
    }

    fileprivate var viewModel: SPUserNameViewModeling!
    fileprivate var disposeBag: DisposeBag!

    private let userNameLabel: SPBaseLabel = .init()
    private let badgeTagLabel: SPBaseLabel = .init()
    private let nameAndBadgeStackview = UIStackView()
    private let subtitleLabel: SPBaseLabel = .init()
    private let dateLabel: SPBaseLabel = .init()
    private lazy var moreButton: SPBaseButton = {
        let btn = SPBaseButton()
        return btn
    }()
    private lazy var hiddenCommentReasonLabel: SPBaseLabel = {
        let lbl = SPBaseLabel()
        return lbl
    }()
    private lazy var subscriberBadgeView: OWUserSubscriberBadgeView = {
        return OWUserSubscriberBadgeView()
    }()

    private var subtitleToNameConstraint: NSLayoutConstraint?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        applyAccessibility()
    }

    // Handle dark mode \ light mode change
    func updateColorsAccordingToStyle() {
        backgroundColor = .spBackground0
        userNameLabel.textColor = .spForeground1
        userNameLabel.backgroundColor = .spBackground0
        moreButton.backgroundColor = .spBackground0
        badgeTagLabel.backgroundColor = .spBackground0
        subtitleLabel.textColor = .spForeground3
        subtitleLabel.backgroundColor = .spBackground0
        dateLabel.textColor = .spForeground3
        dateLabel.backgroundColor = .spBackground0
        hiddenCommentReasonLabel.backgroundColor = .spBackground0
    }

    func configure(with viewModel: SPUserNameViewModeling) {
        self.viewModel = viewModel
        disposeBag = DisposeBag()

        subscriberBadgeView.configure(with: viewModel.outputs.subscriberBadgeVM)

        setupObservers()
    }
}

fileprivate extension SPUserNameView {
    func setupViews() {
        addSubviews(hiddenCommentReasonLabel,
                    userNameLabel,
                    badgeTagLabel,
                    moreButton,
                    subtitleLabel,
                    dateLabel,
                    nameAndBadgeStackview,
                    subscriberBadgeView)

        // Setup deleted label

        hiddenCommentReasonLabel.OWSnp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        // Setup name and badge stack view

        nameAndBadgeStackview.addArrangedSubview(userNameLabel)
        nameAndBadgeStackview.addArrangedSubview(badgeTagLabel)
        nameAndBadgeStackview.axis = .horizontal
        nameAndBadgeStackview.alignment = .leading
        nameAndBadgeStackview.spacing = Metrics.badgeLeadingPadding

        badgeTagLabel.font = .spPreferred(style: .medium, of: Metrics.labelFontSize)
        badgeTagLabel.layer.borderWidth = 1
        badgeTagLabel.layer.cornerRadius = 3
        badgeTagLabel.insets = UIEdgeInsets(top: Metrics.badgeVerticalInset, left: Metrics.badgeHorizontalInset, bottom: Metrics.badgeVerticalInset, right: Metrics.badgeHorizontalInset)
        badgeTagLabel.layer.masksToBounds = true
        badgeTagLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        badgeTagLabel.textColor = .brandColor
        badgeTagLabel.layer.borderColor = UIColor.brandColor.cgColor

        userNameLabel.setContentCompressionResistancePriority(.required, for: .vertical)

        nameAndBadgeStackview.OWSnp.makeConstraints { make in
            make.top.leading.equalToSuperview()
            make.trailing.lessThanOrEqualToSuperview().offset(-Metrics.usernameTrailingPadding)
        }
        userNameLabel.isUserInteractionEnabled = true

        // Setup subscriber badge

        self.addSubviews(subscriberBadgeView)
        subscriberBadgeView.OWSnp.makeConstraints { make in
            make.top.equalTo(nameAndBadgeStackview)
            make.leading.equalTo(nameAndBadgeStackview.OWSnp.trailing).offset(5.0)
        }

        // Setup more button

        let image = UIImage(spNamed: "menu_icon", supportDarkMode: true)
        moreButton.setImage(image, for: .normal)
        moreButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -8)
        moreButton.OWSnp.makeConstraints { make in
            make.size.equalTo(44.0)
            make.centerY.equalTo(userNameLabel)
            make.trailing.equalToSuperview()
        }

        // Setup subtitle label

        subtitleLabel.font = .spPreferred(style: .regular, of: Metrics.fontSize)
        subtitleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        subtitleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        subtitleLabel.isUserInteractionEnabled = false
        subtitleLabel.OWSnp.makeConstraints { make in
            make.top.equalTo(nameAndBadgeStackview.OWSnp.bottom).offset(Metrics.subtitleTopPadding)
            make.leading.equalTo(userNameLabel)
            make.trailing.equalTo(dateLabel.OWSnp.leading)
        }

        // Setup date label
        dateLabel.font = .spPreferred(style: .regular, of: Metrics.fontSize)
        dateLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        dateLabel.isUserInteractionEnabled = false
        dateLabel.OWSnp.makeConstraints { make in
            make.top.equalTo(subtitleLabel)
            make.trailing.lessThanOrEqualTo(moreButton.OWSnp.leading)
        }

        // Update colors

        self.updateColorsAccordingToStyle()
    }

    func getHidenCommentReasonString(with message: String) -> NSAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.firstLineHeadIndent = 0
        paragraphStyle.lineSpacing = 3.5
        paragraphStyle.spUpdateAlignment()

        var attributes: [NSAttributedString.Key: Any]
        attributes = [
            .foregroundColor: UIColor.spForeground3,
            .font: UIFont.spPreferred(style: .italic, of: 17.0),
            .paragraphStyle: paragraphStyle
        ]

        return NSAttributedString(
            string: message,
            attributes: attributes
        )
    }
}

fileprivate extension SPUserNameView {
    func setupObservers() {
        let tapGesture = UITapGestureRecognizer()
        userNameLabel.addGestureRecognizer(tapGesture)

        tapGesture.rx.event.voidify()
        .bind(to: viewModel.inputs.tapUserName)
        .disposed(by: disposeBag)

        moreButton.rx.tap.subscribe(onNext: { [weak self] _ in
            guard let self = self else { return }
            self.viewModel.inputs.tapMore.onNext(self.moreButton)
        }).disposed(by: disposeBag)

        viewModel.outputs.subtitleText
            .bind(to: subtitleLabel.rx.text)
            .disposed(by: disposeBag)

        viewModel.outputs.dateText
            .bind(to: dateLabel.rx.text)
            .disposed(by: disposeBag)

        viewModel.outputs.badgeTitle
            .bind(to: badgeTagLabel.rx.text)
            .disposed(by: disposeBag)

        viewModel.outputs.badgeTitle
            .map { $0.isEmpty }
            .bind(to: badgeTagLabel.rx.isHidden)
            .disposed(by: disposeBag)

        viewModel.outputs.badgeTitle
            .subscribe(onNext: { [weak self] title in
                guard let self = self else { return }
                self.subtitleToNameConstraint?.isActive = !title.isEmpty
            })
            .disposed(by: disposeBag)

        viewModel.outputs.shouldShowDeletedOrReportedMessage
            .subscribe(onNext: { [weak self] shouldShow in
                guard let self = self else { return }
                self.dateLabel.isHidden = shouldShow
                self.moreButton.isHidden = shouldShow
                self.subscriberBadgeView.isHidden = shouldShow
                self.nameAndBadgeStackview.isHidden = shouldShow
                self.subtitleLabel.isHidden = shouldShow

                self.hiddenCommentReasonLabel.isHidden = !shouldShow

            }).disposed(by: disposeBag)

        viewModel.outputs.nameText
            .bind(to: userNameLabel.rx.text)
            .disposed(by: disposeBag)

        viewModel.outputs.nameTextStyle
            .subscribe(onNext: { [weak self] style in
                guard let self = self else { return }
                self.userNameLabel.font(
                    .spPreferred(style: style, of: Metrics.fontSize)
                )
            }).disposed(by: disposeBag)

        viewModel.outputs.isUsernameOneRow
            .subscribe(onNext: { [weak self] isOneRow in
                guard let self = self else { return }
                self.nameAndBadgeStackview.axis = isOneRow ? .horizontal : .vertical
            }).disposed(by: disposeBag)

        viewModel.outputs.hiddenCommentReasonText
            .subscribe(onNext: { [weak self] text in
                guard let self = self else { return }
                self.hiddenCommentReasonLabel.attributedText =
                self.getHidenCommentReasonString(with: text)
            }).disposed(by: disposeBag)
    }
}

// MARK: Accessibility

extension SPUserNameView {
    func applyAccessibility() {
        self.accessibilityIdentifier = Metrics.identifier
        userNameLabel.accessibilityIdentifier = Metrics.userNameLabelIdentifier
        badgeTagLabel.accessibilityIdentifier = Metrics.badgeTagLabelIdentifier
        moreButton.accessibilityIdentifier = Metrics.moreButtonIdentifier
        dateLabel.accessibilityIdentifier = Metrics.dateLabelIdentifier
        hiddenCommentReasonLabel.accessibilityIdentifier = Metrics.deletedMessageLabelIdentifier
        subscriberBadgeView.accessibilityIdentifier = Metrics.subscriberBadgeViewIdentifier

        moreButton.accessibilityTraits = .button
        moreButton.accessibilityLabel = SPLocalizationManager.localizedString(key: "Options menu")
    }
}
