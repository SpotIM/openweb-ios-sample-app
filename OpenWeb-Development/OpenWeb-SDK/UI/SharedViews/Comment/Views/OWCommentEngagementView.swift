//
//  OWCommentEngagementView.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 27/12/2022.
//  Copyright © 2022 OpenWeb. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class OWCommentEngagementView: UIView {

    fileprivate struct Metrics {
        static let baseOffset: CGFloat = 14
        static let dotDividerSize: CGFloat = 3

        static let identifier = "comment_actions_view_id"
        static let replyButtonIdentifier = "comment_actions_view_reply_button_id"
        static let shareButtonIdentifier = "comment_actions_view_share_button_id"
    }

    fileprivate var viewModel: OWCommentEngagementViewModeling!
    fileprivate var disposeBag: DisposeBag = DisposeBag()

    fileprivate var replyZeroWidthConstraint: OWConstraint? = nil

    fileprivate lazy var replyButton: UIButton = {
        return UIButton()
            .setTitle(OWLocalizationManager.shared.localizedString(key: "Reply"), state: .normal)
            .textColor(OWColorPalette.shared.color(type: .textColor2, themeStyle: .light))
            .font(OWFontBook.shared.font(typography: .footnoteText))
            .wrapContent()
    }()

    fileprivate lazy var replyDotDivider: UIView = {
        return UIView()
            .corner(radius: Metrics.dotDividerSize/2)
            .backgroundColor(OWColorPalette.shared.color(type: .separatorColor1, themeStyle: .light))
    }()

    fileprivate lazy var votingView: OWCommentRatingView = {
        return OWCommentRatingView()
    }()

    fileprivate lazy var votingDotDivider: UIView = {
        return UIView()
            .corner(radius: Metrics.dotDividerSize/2)
            .backgroundColor(OWColorPalette.shared.color(type: .separatorColor1, themeStyle: .light))
    }()

    fileprivate lazy var shareButton: UIButton = {
        return UIButton()
            .setTitle(OWLocalizationManager.shared.localizedString(key: "Share"), state: .normal)
            .textColor(OWColorPalette.shared.color(type: .textColor2, themeStyle: .light))
            .font(OWFontBook.shared.font(typography: .footnoteText))
            .wrapContent()
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

fileprivate extension OWCommentEngagementView {
    func setupUI() {
        self.enforceSemanticAttribute()
        self.addSubviews(replyButton, votingView)

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
            make.leading.equalTo(replyDotDivider.OWSnp.trailing).offset(Metrics.baseOffset)
        }

        self.addSubview(votingDotDivider)
        votingDotDivider.OWSnp.makeConstraints { make in
            make.size.equalTo(Metrics.dotDividerSize)
            make.centerY.equalToSuperview()
            make.leading.equalTo(votingView.OWSnp.trailing).offset(Metrics.baseOffset)
        }

        self.addSubview(shareButton)
        shareButton.OWSnp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.equalTo(votingDotDivider.OWSnp.trailing).offset(Metrics.baseOffset)
            make.trailing.lessThanOrEqualToSuperview()
        }
    }

    func setupObservers() {
        replyButton.rx.tap
            .bind(to: viewModel.inputs.replyClicked)
            .disposed(by: disposeBag)

        shareButton.rx.tap
            .bind(to: viewModel.inputs.shareClicked)
            .disposed(by: disposeBag)

        viewModel.outputs.showReplyButton
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] showReply in
                guard let self = self else { return }
                self.replyButton.isHidden = !showReply
                self.replyDotDivider.isHidden = !showReply
                self.replyZeroWidthConstraint?.isActive = !showReply
                self.replyDotDivider.OWSnp.updateConstraints { make in
                    make.size.equalTo(showReply ? Metrics.dotDividerSize : 0)
                    make.leading.equalTo(self.replyButton.OWSnp.trailing).offset(showReply ? Metrics.baseOffset : 0)
                }
                self.votingView.OWSnp.updateConstraints { make in
                    make.leading.equalTo(self.replyDotDivider.OWSnp.trailing).offset(showReply ? Metrics.baseOffset : 0)
                }
            })
            .disposed(by: disposeBag)

        OWSharedServicesProvider.shared.themeStyleService()
            .style
            .subscribe(onNext: { [weak self] currentStyle in
                guard let self = self else { return }
                self.replyButton.setTitleColor(OWColorPalette.shared.color(type: .textColor2, themeStyle: currentStyle), for: .normal)
                self.shareButton.setTitleColor(OWColorPalette.shared.color(type: .textColor2, themeStyle: currentStyle), for: .normal)
                self.replyDotDivider.backgroundColor = OWColorPalette.shared.color(type: .separatorColor1, themeStyle: currentStyle)
                self.votingDotDivider.backgroundColor = OWColorPalette.shared.color(type: .separatorColor1, themeStyle: currentStyle)
            }).disposed(by: disposeBag)

        OWSharedServicesProvider.shared.appLifeCycle()
            .didChangeContentSizeCategory
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.replyButton.titleLabel?.font = OWFontBook.shared.font(typography: .footnoteText)
                self.shareButton.titleLabel?.font = OWFontBook.shared.font(typography: .footnoteText)
            })
            .disposed(by: disposeBag)
    }
}
