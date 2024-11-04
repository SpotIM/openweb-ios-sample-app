//
//  OWCommentEngagementView.swift
//  OpenWebSDK
//
//  Created by  Nogah Melamed on 27/12/2022.
//  Copyright © 2022 OpenWeb. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class OWCommentEngagementView: UIView {

    private struct Metrics {
        static let baseOffset: CGFloat = 14
        static let dotDividerSize: CGFloat = 3
        static let shareButtonSize: CGFloat = 24

        static let identifier = "comment_actions_view_id"
        static let replyButtonIdentifier = "comment_actions_view_reply_button_id"
        static let shareButtonIdentifier = "comment_actions_view_share_button_id"
    }

    private var viewModel: OWCommentEngagementViewModeling!
    private var disposeBag: DisposeBag = DisposeBag()

    private var replyZeroWidthConstraint: OWConstraint?
    private var votingTrailingConstraint: OWConstraint?
    private var votingLeadingConstraint: OWConstraint?
    private var shareLeadingWithVotingConstraint: OWConstraint?
    private var shareLeadingWithReplyConstraint: OWConstraint?

    private lazy var replyButton: UIButton = {
        return UIButton()
            .setTitle(OWLocalizationManager.shared.localizedString(key: "Reply"), state: .normal)
            .wrapContent()
    }()

    private lazy var replyDotDivider: UIView = {
        return UIView()
            .corner(radius: Metrics.dotDividerSize / 2)
            .backgroundColor(OWColorPalette.shared.color(type: .separatorColor1, themeStyle: .light))
    }()

    private lazy var votingView: OWCommentRatingView = {
        return OWCommentRatingView()
    }()

    private lazy var votingDotDivider: UIView = {
        return UIView()
            .corner(radius: Metrics.dotDividerSize / 2)
            .backgroundColor(OWColorPalette.shared.color(type: .separatorColor1, themeStyle: .light))
    }()

    private lazy var shareButton: UIButton = {
        return UIButton()
            .hugContent(axis: .horizontal)
            .setTitle(OWLocalizationManager.shared.localizedString(key: "Share"), state: .normal)
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        applyAccessibility()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func applyAccessibility() {
        self.accessibilityIdentifier = Metrics.identifier
        replyButton.accessibilityIdentifier = Metrics.replyButtonIdentifier
        shareButton.accessibilityIdentifier = Metrics.shareButtonIdentifier
    }

    func configure(with viewModel: OWCommentEngagementViewModeling) {
        self.viewModel = viewModel
        disposeBag = DisposeBag()
        votingView.configure(with: viewModel.outputs.votingVM)
        setupObservers()
    }

    func prepareForReuse() {
        votingView.prepareForReuse()
    }
}

private extension OWCommentEngagementView {
    func setupUI() {
        self.enforceSemanticAttribute()
        self.addSubview(replyButton)
        self.addSubview(votingView)

        replyButton.OWSnp.makeConstraints { make in
            make.centerY.leading.equalToSuperview()
            replyZeroWidthConstraint = make.width.equalTo(0).constraint
        }
        replyZeroWidthConstraint?.isActive = false

        self.addSubview(replyDotDivider)
        replyDotDivider.OWSnp.makeConstraints { make in
            make.size.equalTo(Metrics.dotDividerSize)
            make.centerY.equalToSuperview()
            make.leading.equalTo(replyButton.OWSnp.trailing).offset(Metrics.baseOffset)
        }

        votingView.OWSnp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            votingLeadingConstraint = make.leading.equalTo(replyDotDivider.OWSnp.trailing).offset(Metrics.baseOffset).constraint
            votingTrailingConstraint = make.trailing.equalToSuperview().constraint
        }
        votingLeadingConstraint?.isActive = true
        votingTrailingConstraint?.isActive = false

        self.addSubview(votingDotDivider)
        votingDotDivider.OWSnp.makeConstraints { make in
            make.size.equalTo(Metrics.dotDividerSize)
            make.centerY.equalToSuperview()
            make.leading.equalTo(votingView.OWSnp.trailing).offset(Metrics.baseOffset)
        }

        self.addSubview(shareButton)
        shareButton.OWSnp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            shareLeadingWithVotingConstraint = make.leading.equalTo(votingDotDivider.OWSnp.trailing).offset(Metrics.baseOffset).constraint
            shareLeadingWithReplyConstraint = make.leading.equalTo(replyDotDivider.OWSnp.trailing).offset(Metrics.baseOffset).constraint
            make.trailing.lessThanOrEqualToSuperview()
        }
        shareLeadingWithReplyConstraint?.isActive = false
        shareLeadingWithVotingConstraint?.isActive = true
    }

    func setupObservers() {
        viewModel.outputs.shareButtonStyle
            .subscribe(onNext: { [weak self] shareButtonStyle in
                guard let self else { return }
                switch shareButtonStyle {
                case .text:
                    self.shareButton
                        .setTitle(OWLocalizationManager.shared.localizedString(key: "Share"), state: .normal)
                        .setImage(nil, for: .normal)
                case .icon:
                    self.shareButton
                        .setTitle(nil, state: .normal)
                        .setImage(UIImage(spNamed: "shareButtonIcon"), for: .normal)
                }
            })
            .disposed(by: disposeBag)

        viewModel.outputs.votesPosition
            .subscribe(onNext: { [weak self] position in
                guard let self else { return }
                OWScheduler.runOnMainThreadIfNeeded {
                    switch position {
                    case .default:
                        self.votingDotDivider.isHidden = false
                        self.shareLeadingWithReplyConstraint?.isActive = false
                        self.shareLeadingWithVotingConstraint?.isActive = true
                        self.votingLeadingConstraint?.isActive = true
                        self.votingTrailingConstraint?.isActive = false
                    case .endBottom:
                        self.votingDotDivider.isHidden = true
                        self.shareLeadingWithReplyConstraint?.isActive = true
                        self.shareLeadingWithVotingConstraint?.isActive = false
                        self.votingLeadingConstraint?.isActive = false
                        self.votingTrailingConstraint?.isActive = true
                    }
                }
            })
            .disposed(by: disposeBag)

        replyButton.rx.tap
            .bind(to: viewModel.inputs.replyClicked)
            .disposed(by: disposeBag)

        shareButton.rx.tap
            .bind(to: viewModel.inputs.shareClicked)
            .disposed(by: disposeBag)

        viewModel.outputs.showReplyButton
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] showReply in
                guard let self else { return }
                self.replyButton.isHidden = !showReply
                self.replyDotDivider.isHidden = !showReply
                self.replyZeroWidthConstraint?.isActive = !showReply
                self.replyDotDivider.OWSnp.updateConstraints { make in
                    make.size.equalTo(showReply ? Metrics.dotDividerSize : 0)
                    make.leading.equalTo(self.replyButton.OWSnp.trailing).offset(showReply ? Metrics.baseOffset : 0)
                }
                shareLeadingWithReplyConstraint?.update(offset: (showReply ? Metrics.baseOffset : 0))
            })
            .disposed(by: disposeBag)

        OWSharedServicesProvider.shared.themeStyleService()
            .style
            .withLatestFrom(viewModel.outputs.commentActionsColor) { ($0, $1) }
            .subscribe(onNext: { [weak self] currentStyle, commentActionsColor in
                guard let self else { return }
                self.replyDotDivider.backgroundColor = OWColorPalette.shared.color(type: .separatorColor1, themeStyle: currentStyle)
                self.votingDotDivider.backgroundColor = OWColorPalette.shared.color(type: .separatorColor1, themeStyle: currentStyle)
                switch commentActionsColor {
                case .default:
                    self.replyButton.setTitleColor(OWColorPalette.shared.color(type: .textColor2, themeStyle: currentStyle), for: .normal)
                    self.shareButton.setTitleColor(OWColorPalette.shared.color(type: .textColor2, themeStyle: currentStyle), for: .normal)
                    self.shareButton.tintColor = OWColorPalette.shared.color(type: .textColor2, themeStyle: currentStyle)
                case .brandColor:
                    self.replyButton.setTitleColor(OWColorPalette.shared.color(type: .brandColor, themeStyle: currentStyle), for: .normal)
                    self.shareButton.setTitleColor(OWColorPalette.shared.color(type: .brandColor, themeStyle: currentStyle), for: .normal)
                    self.shareButton.tintColor = OWColorPalette.shared.color(type: .brandColor, themeStyle: currentStyle)
                }
            }).disposed(by: disposeBag)

        let setButtonsFont = { [weak self] (commentActionsFontStyle: OWCommentActionsFontStyle) in
            guard let self else { return }
            switch commentActionsFontStyle {
            case .default:
                self.replyButton.titleLabel?.font = OWFontBook.shared.font(typography: .footnoteText)
                self.shareButton.titleLabel?.font = OWFontBook.shared.font(typography: .footnoteText)
            case .semiBold:
                self.replyButton.titleLabel?.font = OWFontBook.shared.font(typography: .footnoteContext)
                self.shareButton.titleLabel?.font = OWFontBook.shared.font(typography: .footnoteContext)
            }
        }

        viewModel.outputs.commentActionsFontStyle
            .subscribe(onNext: { commentActionsFontStyle in
                setButtonsFont(commentActionsFontStyle)
            })
            .disposed(by: disposeBag)

        OWSharedServicesProvider.shared.appLifeCycle()
            .didChangeContentSizeCategory
            .withLatestFrom(viewModel.outputs.commentActionsFontStyle)
            .subscribe(onNext: { commentActionsFontStyle in
                setButtonsFont(commentActionsFontStyle)
            })
            .disposed(by: disposeBag)
    }
}
