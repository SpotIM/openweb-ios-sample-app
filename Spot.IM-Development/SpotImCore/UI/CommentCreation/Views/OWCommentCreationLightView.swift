//
//  OWCommentCreationLightView.swift
//  SpotImCore
//
//  Created by Alon Shprung on 07/06/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class OWCommentCreationLightView: UIView, OWThemeStyleInjectorProtocol {
    fileprivate struct Metrics {
        static let identifier = "comment_creation_light_view_id"

        static let horizontalOffset: CGFloat = 16.0
        static let contentViewHorizontalLandscapeOffset: CGFloat = 66.0
        static let replyToVerticalSpacing: CGFloat = 15.0
        static let topContainerPortraitHeight: CGFloat = 54.0
        static let topContainerLandscapeHeight: CGFloat = 44.0
        static let footerPortraitHeight: CGFloat = 72.0
        static let footerLandscapeHeight: CGFloat = 66.0
        static let replyToFontSize: CGFloat = 15.0
        static let closeButtonSize: CGFloat = 40.0
        static let closeButtonTrailingOffset: CGFloat = 5.0
        static let commentLabelsSpacing: CGFloat = 15.0
        static let closeButtomImageName: String = "closeCrossIconNew"
    }

    fileprivate lazy var titleLabel: UILabel = {
        return UILabel()
            .textColor(OWColorPalette.shared.color(type: .textColor1, themeStyle: .light))
            .numberOfLines(1)
    }()

    fileprivate lazy var closeButton: UIButton = {
        return UIButton()
            .image(UIImage(spNamed: "closeCrossIconNew", supportDarkMode: true), state: .normal)
    }()

    fileprivate lazy var separatorView: UIView = {
        return UIView()
            .backgroundColor(OWColorPalette.shared.color(type: .separatorColor1,
                                                         themeStyle: OWSharedServicesProvider.shared.themeStyleService().currentStyle))
    }()

    fileprivate lazy var topContainerView: UIView = {
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
            make.centerX.equalTo(topContainerView.OWSnp.centerX)
        }

        topContainerView.addSubview(separatorView)
        separatorView.OWSnp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(1)
        }

        return topContainerView
    }()

    fileprivate lazy var replyToLabel: UILabel = {
        return UILabel()
            .font(OWFontBook.shared.font(typography: .bodyText))
            .textColor(OWColorPalette.shared.color(type: .textColor2, themeStyle: .light))
            .numberOfLines(1)
            .enforceSemanticAttribute()
    }()

    fileprivate lazy var replySnippetView: OWCommentCreationReplySnippetView = {
        return OWCommentCreationReplySnippetView(with: self.viewModel.outputs.replySnippetViewModel)
            .enforceSemanticAttribute()
    }()

    fileprivate lazy var contentView: OWCommentCreationContentView = {
        return OWCommentCreationContentView(with: self.viewModel.outputs.commentCreationContentVM)
    }()

    fileprivate lazy var commentReplyCounterView: OWCommentReplyCounterView = {
        return OWCommentReplyCounterView(with: viewModel.outputs.commentCounterViewModel)
    }()

    fileprivate lazy var commentLabelsContainerView: OWCommentLabelsContainerView = {
        return OWCommentLabelsContainerView()
    }()

    fileprivate lazy var footerView: OWCommentCreationFooterView = {
        return OWCommentCreationFooterView(with: self.viewModel.outputs.footerViewModel)
    }()

    fileprivate var replyToLabelHeightConstraint: OWConstraint? = nil
    fileprivate var replySnippetHeightConstraint: OWConstraint? = nil
    fileprivate var commentLabelsContainerHeightConstraint: OWConstraint? = nil
    fileprivate let viewModel: OWCommentCreationLightViewViewModeling
    fileprivate let disposeBag = DisposeBag()

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(viewModel: OWCommentCreationLightViewViewModeling) {
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
    }
}

fileprivate extension OWCommentCreationLightView {
    func setupViews() {
        self.enforceSemanticAttribute()
        self.useAsThemeStyleInjector()

        self.addSubview(topContainerView)
        topContainerView.OWSnp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(Metrics.topContainerPortraitHeight)
        }

        if viewModel.outputs.shouldShowReplySnippet {
            self.addSubviews(replyToLabel)
            replyToLabel.OWSnp.makeConstraints { make in
                make.top.equalTo(topContainerView.OWSnp.bottom).offset(Metrics.replyToVerticalSpacing)
                make.leading.trailing.equalToSuperview().inset(Metrics.horizontalOffset)
                replyToLabelHeightConstraint = make.height.equalTo(0).constraint
            }

            self.addSubview(replySnippetView)
            replySnippetView.OWSnp.makeConstraints { make in
                make.top.equalTo(replyToLabel.OWSnp.bottom).offset(Metrics.replyToVerticalSpacing)
                make.leading.trailing.equalToSuperview()
                replySnippetHeightConstraint = make.height.equalTo(0).constraint
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
            make.leading.trailing.equalToSuperviewSafeArea().inset(0)
            make.top.equalTo(viewModel.outputs.shouldShowReplySnippet ? replySnippetView.OWSnp.bottom : topContainerView.OWSnp.bottom)
            make.bottom.equalTo(commentReplyCounterView.OWSnp.top)
        }
    }

    func setupObservers() {
        OWSharedServicesProvider.shared.themeStyleService()
            .style
            .subscribe(onNext: { [weak self] currentStyle in
                guard let self = self else { return }
                self.topContainerView.backgroundColor = OWColorPalette.shared.color(type: .backgroundColor2, themeStyle: currentStyle)
                self.contentView.backgroundColor = OWColorPalette.shared.color(type: .backgroundColor2, themeStyle: currentStyle)
                self.footerView.backgroundColor = OWColorPalette.shared.color(type: .backgroundColor2, themeStyle: currentStyle)
                self.titleLabel.textColor = OWColorPalette.shared.color(type: .textColor1, themeStyle: currentStyle)
                self.closeButton.image(UIImage(spNamed: Metrics.closeButtomImageName, supportDarkMode: true), state: .normal)
                self.separatorView.backgroundColor = OWColorPalette.shared.color(type: .separatorColor1, themeStyle: currentStyle)
                self.replyToLabel.textColor = OWColorPalette.shared.color(type: .textColor2, themeStyle: currentStyle)
            })
            .disposed(by: disposeBag)

        OWSharedServicesProvider.shared.appLifeCycle()
            .didChangeContentSizeCategory
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.titleLabel.font = OWFontBook.shared.font(typography: .titleSmall)
                self.replyToLabel.font = OWFontBook.shared.font(typography: .bodyText)
            })
            .disposed(by: disposeBag)

        closeButton.rx.tap
            .bind(to: viewModel.inputs.closeButtonTap)
            .disposed(by: disposeBag)

        Observable.combineLatest(viewModel.outputs.titleText,
                                 viewModel.outputs.replyToAttributedString.startWith(NSAttributedString()),
                                 OWSharedServicesProvider.shared.orientationService().orientation) { titleText, replyToAttributedString, currentOrientation -> NSAttributedString in

            switch self.viewModel.outputs.commentType {
            case .replyToComment:
                if currentOrientation == .landscape {
                    return replyToAttributedString
                }
            default:
                break
            }
            return titleText
        }
            .bind(to: titleLabel.rx.attributedText)
            .disposed(by: disposeBag)

        viewModel.outputs.replyToAttributedString
            .bind(to: replyToLabel.rx.attributedText)
            .disposed(by: disposeBag)

        // Handle orientation change
        OWSharedServicesProvider.shared.orientationService()
            .orientation
            .subscribe(onNext: { [weak self] currentOrientation in
                guard let self = self else { return }
                let isLandscape = currentOrientation == .landscape

                // Header
                self.topContainerView.OWSnp.updateConstraints { make in
                    make.height.equalTo(isLandscape ? Metrics.topContainerLandscapeHeight : Metrics.topContainerPortraitHeight)
                }

                // Reply snippet
                if viewModel.outputs.shouldShowReplySnippet {
                    self.replyToLabelHeightConstraint?.isActive = isLandscape
                    self.replyToLabel.isHidden = isLandscape
                    self.replyToLabel.OWSnp.updateConstraints { make in
                        make.top.equalTo(self.topContainerView.OWSnp.bottom).offset(isLandscape ? 0 : Metrics.replyToVerticalSpacing)
                    }

                    self.replySnippetHeightConstraint?.isActive = isLandscape
                    self.replySnippetView.isHidden = isLandscape
                    replySnippetView.OWSnp.updateConstraints { make in
                        make.top.equalTo(self.replyToLabel.OWSnp.bottom).offset(isLandscape ? 0 : Metrics.replyToVerticalSpacing)
                    }
                }

                // Content
                self.contentView.OWSnp.updateConstraints { make in
                    make.leading.trailing.equalToSuperviewSafeArea().inset(isLandscape ? Metrics.contentViewHorizontalLandscapeOffset : 0)
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
