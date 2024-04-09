//
//  OWCommentView.swift
//  OpenWebSDK
//
//  Created by Alon Shprung on 05/09/2022.
//  Copyright © 2022 OpenWeb. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class OWCommentView: UIView {
    struct Metrics {
        static let horizontalOffset: CGFloat = 16.0
    }

    fileprivate struct InternalMetrics {
        static let leadingOffset: CGFloat = 16.0
        static let commentHeaderVerticalOffset: CGFloat = 12.0
        static let commentStatusBottomPadding: CGFloat = 12.0
        static let commentLabelTopPadding: CGFloat = 10.0
        static let messageContainerTopOffset: CGFloat = 4.0
        static let commentActionsTopPadding: CGFloat = 15.0
        static let optionsImageInset: CGFloat = 22
        static let optionButtonSize: CGFloat = 30
        static let optionButtonIdentifier = "comment_header_option_button_id"
    }

    fileprivate lazy var commentStatusView: OWCommentStatusView = {
        return OWCommentStatusView()
    }()
    fileprivate lazy var blockingOpacityView: UIView = {
        return UIView()
            .backgroundColor(OWColorPalette.shared.color(type: .backgroundColor2, themeStyle: .light))
            .alpha(0.5)
    }()
    fileprivate lazy var commentHeaderView: OWCommentHeaderView = {
        return OWCommentHeaderView()
    }()
    fileprivate lazy var optionButton: UIButton = {
        let image = UIImage(spNamed: "optionsIcon", supportDarkMode: true)
        let leftInset: CGFloat = OWLocalizationManager.shared.textAlignment == .left ? 0 : -InternalMetrics.optionsImageInset
        let rightInset: CGFloat = OWLocalizationManager.shared.textAlignment == .right ? 0 : -InternalMetrics.optionsImageInset
        return UIButton()
            .image(image, state: .normal)
            .imageEdgeInsets(UIEdgeInsets(top: 0, left: leftInset, bottom: 0, right: rightInset))
    }()
    fileprivate lazy var commentLabelsContainerView: OWCommentLabelsContainerView = {
        return OWCommentLabelsContainerView()
    }()
    fileprivate lazy var commentContentView: OWCommentContentView = {
        return OWCommentContentView()
    }()
    fileprivate lazy var commentEngagementView: OWCommentEngagementView = {
        return OWCommentEngagementView()
    }()

    fileprivate var viewModel: OWCommentViewModeling!
    fileprivate var disposedBag = DisposeBag()

    fileprivate var commentHeaderBottomConstraint: OWConstraint? = nil
    fileprivate var commentStatusZeroHeightConstraint: OWConstraint? = nil

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    init() {
        super.init(frame: .zero)
        setupUI()
        applyAccessibility()
    }

    func configure(with viewModel: OWCommentViewModeling) {
        self.disposedBag = DisposeBag()
        self.viewModel = viewModel
        self.commentStatusView.configure(with: viewModel.outputs.commentStatusVM)
        self.commentHeaderView.configure(with: viewModel.outputs.commentHeaderVM)
        self.commentLabelsContainerView.configure(viewModel: viewModel.outputs.commentLabelsContainerVM)
        self.commentContentView.configure(with: viewModel.outputs.contentVM)
        self.commentEngagementView.configure(with: viewModel.outputs.commentEngagementVM)
        self.setupObservers()
    }

    func prepareForReuse() {
        commentHeaderView.prepareForReuse()
        commentLabelsContainerView.prepareForReuse()
        commentEngagementView.prepareForReuse()
        self.optionButton.isHidden = false
    }
}

fileprivate extension OWCommentView {
    func setupUI() {
        self.backgroundColor = .clear

        self.addSubviews(commentStatusView)
        commentStatusView.OWSnp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            commentStatusZeroHeightConstraint = make.height.equalTo(0).constraint
        }

        self.addSubview(blockingOpacityView)
        blockingOpacityView.OWSnp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(commentStatusView.OWSnp.bottom)
        }

        self.addSubview(optionButton)
        optionButton.OWSnp.makeConstraints { make in
            make.size.equalTo(InternalMetrics.optionButtonSize)
            make.top.equalTo(commentStatusView.OWSnp.bottom)
            make.trailing.equalToSuperview()
        }

        self.addSubview(commentHeaderView)
        commentHeaderView.OWSnp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalTo(optionButton.OWSnp.leading)
            make.top.equalTo(commentStatusView.OWSnp.bottom).offset(InternalMetrics.commentStatusBottomPadding)
            commentHeaderBottomConstraint = make.bottom.equalToSuperview().constraint
        }
    }

    func setupCommentContentUI() {
        self.addSubview(commentLabelsContainerView)
        commentLabelsContainerView.OWSnp.makeConstraints { make in
            make.top.equalTo(commentHeaderView.OWSnp.bottom).offset(InternalMetrics.commentLabelTopPadding)
            make.leading.equalToSuperview()
            make.trailing.lessThanOrEqualToSuperview()
        }

        self.addSubview(commentContentView)
        commentContentView.OWSnp.makeConstraints { make in
            make.top.equalTo(commentLabelsContainerView.OWSnp.bottom).offset(InternalMetrics.messageContainerTopOffset)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview().offset(-Metrics.horizontalOffset)
        }

        self.addSubview(commentEngagementView)
        commentEngagementView.OWSnp.makeConstraints { make in
            make.bottom.leading.trailing.equalToSuperview()
            make.top.equalTo(commentContentView.OWSnp.bottom).offset(InternalMetrics.commentActionsTopPadding)
        }
        self.bringSubviewToFront(blockingOpacityView)
        self.bringSubviewToFront(optionButton)
    }

    func setupObservers() {
        viewModel.outputs.shouldHideCommentContent
            .subscribe(onNext: { [weak self] shouldBlockComment in
                guard let self = self else { return }
                if (shouldBlockComment) {
                    self.commentLabelsContainerView.removeFromSuperview()
                    self.commentContentView.removeFromSuperview()
                    self.commentEngagementView.removeFromSuperview()
                } else if (self.commentLabelsContainerView.superview == nil) {
                    self.setupCommentContentUI()
                }
                self.optionButton.isHidden = shouldBlockComment
            }).disposed(by: disposedBag)

        if let commentHeaderBottomConstraint = commentHeaderBottomConstraint {
            viewModel.outputs.shouldHideCommentContent
                .bind(to: commentHeaderBottomConstraint.rx.isActive)
                .disposed(by: disposedBag)
        }

        viewModel.outputs.shouldShowCommentStatus
            .subscribe(onNext: { [weak self] shouldShow in
                OWScheduler.runOnMainThreadIfNeeded {
                    guard let self = self else { return }
                    self.commentHeaderView.OWSnp.updateConstraints { make in
                        make.top.equalTo(self.commentStatusView.OWSnp.bottom).offset(shouldShow ? InternalMetrics.commentStatusBottomPadding : 0)
                    }
                    self.commentStatusView.isHidden = !shouldShow
                    self.commentStatusZeroHeightConstraint?.isActive = !shouldShow
                }
            })
            .disposed(by: disposedBag)

        viewModel.outputs.showBlockingLayoutView
            .map { !$0 }
            .bind(to: blockingOpacityView.rx.isHidden)
            .disposed(by: disposedBag)

        optionButton.rx.tap
            .map { [weak self] in
                return self?.optionButton
            }
            .unwrap()
            .bind(to: viewModel.inputs.tapMore)
            .disposed(by: disposedBag)

        OWSharedServicesProvider.shared.themeStyleService()
            .style
            .subscribe(onNext: { [weak self] currentStyle in
                guard let self = self else { return }

                self.blockingOpacityView.backgroundColor = OWColorPalette.shared.color(type: .backgroundColor2, themeStyle: currentStyle)
                self.optionButton.image(UIImage(spNamed: "optionsIcon", supportDarkMode: true), state: .normal)
            })
            .disposed(by: disposedBag)
    }

    func applyAccessibility() {
        optionButton.accessibilityIdentifier = InternalMetrics.optionButtonIdentifier
        optionButton.accessibilityTraits = .button
        optionButton.accessibilityLabel = OWLocalizationManager.shared.localizedString(key: "OptionsMenu")
    }
}
