//
//  OWCommentCreationRegularView.swift
//  OpenWebSDK
//
//  Created by Alon Shprung on 07/06/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class OWCommentCreationRegularView: UIView, OWThemeStyleInjectorProtocol, OWToastNotificationPresenterProtocol {
    private struct Metrics {
        static let identifier = "comment_creation_regular_view_id"
        static let topContainerIdentifier = "top_container_view_id"
        static let titleLabelIdentifier = "title_label_id"
        static let closeButtonIdentifier = "close_button_id"

        static let seperatorHeight: CGFloat = 1.0
        static let horizontalOffset: CGFloat = 16.0
        static let verticalOffset: CGFloat = 66.0
        static let closeButtonSize: CGFloat = 40.0
        static let closeButtonTrailingOffset: CGFloat = 5.0
        static let topContainerPortraitHeight: CGFloat = 68.0
        static let topContainerLandscapeHeight: CGFloat = 44.0
        static let footerPortraitHeight: CGFloat = 72.0
        static let footerLandscapeHeight: CGFloat = 66.0
        static let commentLabelsSpacing: CGFloat = 15.0
        static let errorToastBottomPadding: CGFloat = 8.0
        static let closeButtomImageName: String = "closeCrossIcon"
    }

    var toastView: OWToastView?

    private lazy var titleLabel: UILabel = {
        return UILabel()
            .font(OWFontBook.shared.font(typography: .bodyText))
            .text(OWLocalize.string("CommentingOn"))
            .textColor(OWColorPalette.shared.color(type: .textColor2, themeStyle: .light))
            .numberOfLines(1)
            .enforceSemanticAttribute()
    }()

    private lazy var closeButton: UIButton = {
        return UIButton()
            .image(UIImage(spNamed: "closeCrossIcon", supportDarkMode: true), state: .normal)
    }()

    private lazy var seperatorView: UIView = {
        return UIView()
            .backgroundColor(OWColorPalette.shared.color(type: .separatorColor2, themeStyle: OWSharedServicesProvider.shared.themeStyleService().currentStyle))
    }()

    private lazy var topContainerView: UIView = {
        let topContainerView = UIView()
            .enforceSemanticAttribute()

        topContainerView.addSubview(closeButton)
        closeButton.OWSnp.makeConstraints { make in
            make.centerY.equalTo(topContainerView.OWSnp.centerY)
            make.trailing.equalToSuperviewSafeArea().offset(-Metrics.closeButtonTrailingOffset)
            make.size.equalTo(Metrics.closeButtonSize)
        }

        topContainerView.addSubview(titleLabel)
        titleLabel.OWSnp.makeConstraints { make in
            make.centerY.equalTo(topContainerView.OWSnp.centerY)
            make.leading.equalToSuperviewSafeArea().offset(Metrics.horizontalOffset)
            make.trailing.equalTo(closeButton.OWSnp.leading).offset(-Metrics.horizontalOffset)
        }

        topContainerView.addSubview(seperatorView)
        seperatorView.OWSnp.makeConstraints { make in
            make.height.equalTo(Metrics.seperatorHeight)
            make.leading.trailing.bottom.equalToSuperview()
        }

        return topContainerView
    }()

    private lazy var articleDescriptionView: OWArticleDescriptionView = {
        return OWArticleDescriptionView(viewModel: self.viewModel.outputs.articleDescriptionViewModel)
            .enforceSemanticAttribute()
    }()

    private lazy var replySnippetView: OWCommentCreationReplySnippetView = {
        return OWCommentCreationReplySnippetView(with: self.viewModel.outputs.replySnippetViewModel)
            .enforceSemanticAttribute()
    }()

    private lazy var contentView: OWCommentCreationContentView = {
        return OWCommentCreationContentView(with: self.viewModel.outputs.commentCreationContentVM)
    }()

    private lazy var commentReplyCounterView: OWCommentReplyCounterView = {
        return OWCommentReplyCounterView(with: viewModel.outputs.commentCounterViewModel)
    }()

    private lazy var commentLabelsContainerView: OWCommentLabelsContainerView = {
        return OWCommentLabelsContainerView()
    }()

    private lazy var footerView: OWCommentCreationFooterView = {
        return OWCommentCreationFooterView(with: self.viewModel.outputs.footerViewModel)
    }()

    private lazy var userMentionView: OWUserMentionView = {
        return OWUserMentionView(viewModel: viewModel.outputs.userMentionVM)
    }()

    private var replySnippetHeightConstraint: OWConstraint?
    private var articleDescriptionHeightConstraint: OWConstraint?
    private var commentLabelsContainerHeightConstraint: OWConstraint?
    private let viewModel: OWCommentCreationRegularViewViewModeling
    private let disposeBag = DisposeBag()

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(viewModel: OWCommentCreationRegularViewViewModeling) {
        self.viewModel = viewModel
        super.init(frame: .zero)

        let commentLabelsContainerVM = viewModel.outputs.commentLabelsContainerVM
        commentLabelsContainerView.configure(viewModel: commentLabelsContainerVM)
        footerView.configureCommentLabels(viewModel: commentLabelsContainerVM)

        setupViews()
        setupObservers()
        applyAccessibility()
    }

    private func applyAccessibility() {
        self.accessibilityIdentifier = Metrics.identifier
        self.topContainerView.accessibilityIdentifier = Metrics.topContainerIdentifier
        self.titleLabel.accessibilityIdentifier = Metrics.titleLabelIdentifier
        self.closeButton.accessibilityIdentifier = Metrics.closeButtonIdentifier
    }
}

private extension OWCommentCreationRegularView {
    func setupViews() {
        self.enforceSemanticAttribute()
        self.useAsThemeStyleInjector()

        self.addSubview(topContainerView)
        topContainerView.OWSnp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(Metrics.topContainerPortraitHeight)
        }

        if viewModel.outputs.shouldShowReplySnippet {
            self.addSubview(replySnippetView)
            replySnippetView.OWSnp.makeConstraints { make in
                make.top.equalTo(topContainerView.OWSnp.bottom)
                make.leading.trailing.equalToSuperview()
                replySnippetHeightConstraint = make.height.equalTo(0).constraint
            }
        } else {
            self.addSubview(articleDescriptionView)
            articleDescriptionView.OWSnp.makeConstraints { make in
                make.top.equalTo(topContainerView.OWSnp.bottom)
                make.leading.trailing.equalToSuperview()
                articleDescriptionHeightConstraint = make.height.equalTo(0).constraint
            }
        }

        self.addSubview(footerView)
        footerView.OWSnp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(Metrics.footerPortraitHeight)
        }

        self.addSubview(commentLabelsContainerView)
        commentLabelsContainerView.OWSnp.makeConstraints { make in
            make.bottom.equalTo(footerView.OWSnp.top).offset(-Metrics.commentLabelsSpacing)
            make.leading.equalToSuperview().offset(Metrics.commentLabelsSpacing)
            make.trailing.lessThanOrEqualToSuperview()
            commentLabelsContainerHeightConstraint = make.height.equalTo(0).constraint
        }

        self.addSubview(commentReplyCounterView)
        commentReplyCounterView.OWSnp.makeConstraints { make in
            make.bottom.equalTo(commentLabelsContainerView.OWSnp.top)
            make.trailing.equalToSuperview().offset(-Metrics.horizontalOffset)
        }

        self.addSubview(contentView)
        contentView.OWSnp.makeConstraints { make in
            make.leading.trailing.equalToSuperviewSafeArea()
            make.top.equalTo(viewModel.outputs.shouldShowReplySnippet ? replySnippetView.OWSnp.bottom : articleDescriptionView.OWSnp.bottom)
            make.bottom.equalTo(commentReplyCounterView.OWSnp.top)
        }

        self.addSubview(userMentionView)
        userMentionView.OWSnp.makeConstraints { make in
            make.leading.trailing.equalToSuperviewSafeArea()
            make.bottom.equalTo(footerView.OWSnp.top)
            make.top.greaterThanOrEqualTo(contentView.OWSnp.top)
        }
    }

    func setupObservers() {
        viewModel.outputs.displayToastCalled
            .subscribe(onNext: { [weak self] combinedData in
                guard var self else { return }
                var requiredData = combinedData.presentData.data
                requiredData.bottomPadding = self.footerView.frame.size.height + Metrics.errorToastBottomPadding
                let completions: [OWToastCompletion: PublishSubject<Void>?] = [.action: combinedData.actionCompletion,
                                                                               .dismiss: self.viewModel.inputs.dismissToast]
                self.presentToast(requiredData: requiredData, completions: completions, disposeBag: self.disposeBag)
                self.bringSubviewToFront(self.footerView)
            })
            .disposed(by: disposeBag)

        viewModel.outputs.hideToast
            .subscribe(onNext: { [weak self] in
                self?.dismissToast()
            })
            .disposed(by: disposeBag)

        OWSharedServicesProvider.shared.themeStyleService()
            .style
            .subscribe(onNext: { [weak self] currentStyle in
                guard let self else { return }
                self.topContainerView.backgroundColor = OWColorPalette.shared.color(type: .backgroundColor2, themeStyle: currentStyle)
                self.contentView.backgroundColor = OWColorPalette.shared.color(type: .backgroundColor2, themeStyle: currentStyle)
                self.footerView.backgroundColor = OWColorPalette.shared.color(type: .backgroundColor2, themeStyle: currentStyle)
                self.titleLabel.textColor = OWColorPalette.shared.color(type: .textColor2, themeStyle: currentStyle)
                self.closeButton.image(UIImage(spNamed: Metrics.closeButtomImageName, supportDarkMode: true), state: .normal)
            })
            .disposed(by: disposeBag)

        closeButton.rx.tap
            .bind(to: viewModel.inputs.closeButtonTap)
            .disposed(by: disposeBag)

        viewModel.outputs.titleAttributedString
            .bind(to: titleLabel.rx.attributedText)
            .disposed(by: disposeBag)

        OWSharedServicesProvider.shared.appLifeCycle()
            .didChangeContentSizeCategory
            .subscribe(onNext: { [weak self] _ in
                guard let self else { return }
                self.titleLabel.font = OWFontBook.shared.font(typography: .bodyText)
            })
            .disposed(by: disposeBag)

        // Handle orientation change
        OWSharedServicesProvider.shared.orientationService()
            .orientation
            .subscribe(onNext: { [weak self] currentOrientation in
                guard let self else { return }
                let isLandscape = currentOrientation == .landscape

                // Header
                self.topContainerView.OWSnp.updateConstraints { make in
                    make.height.equalTo(isLandscape ? Metrics.topContainerLandscapeHeight : Metrics.topContainerPortraitHeight)
                }
                self.seperatorView.isHidden = !isLandscape

                // Title
                switch self.viewModel.outputs.commentType {
                case .edit, .comment:
                    self.titleLabel.isHidden = isLandscape
                case .replyToComment:
                    break
                }

                // Reply snippet, article description
                self.articleDescriptionHeightConstraint?.isActive = isLandscape
                self.articleDescriptionView.isHidden = isLandscape
                self.replySnippetHeightConstraint?.isActive = isLandscape
                self.replySnippetView.isHidden = isLandscape

                // Content
                self.contentView.OWSnp.updateConstraints { make in
                    make.leading.trailing.equalToSuperviewSafeArea().inset(isLandscape ? Metrics.verticalOffset : 0)
                }

                // Footer
                self.footerView.OWSnp.updateConstraints { make in
                    make.height.equalTo(isLandscape ? Metrics.footerLandscapeHeight : Metrics.footerPortraitHeight)
                }

                // Labels
                self.commentLabelsContainerView.OWSnp.updateConstraints { make in
                    make.bottom.equalTo(self.footerView.OWSnp.top).inset(isLandscape ? 0 : -Metrics.commentLabelsSpacing)
                }
                self.commentLabelsContainerView.isHidden = isLandscape
                self.commentLabelsContainerHeightConstraint?.isActive = isLandscape
            })
            .disposed(by: disposeBag)
    }
}
