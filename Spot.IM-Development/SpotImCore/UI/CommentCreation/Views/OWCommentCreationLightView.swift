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
        static let horizontalOffset: CGFloat = 16.0
        static let replyToVerticalSpacing: CGFloat = 15.0
        static let topContainerHeight: CGFloat = 54.0
        static let replyToFontSize: CGFloat = 15.0
        static let closeButtonSize: CGFloat = 40.0
        static let closeButtonTrailingOffset: CGFloat = 5.0
        static let footerHeight: CGFloat = 72.0
        static let commentLabelsSpacing: CGFloat = 15.0

        static let identifier = "comment_creation_light_view_id"
    }

    fileprivate lazy var titleLabel: UILabel = {
        return UILabel()
            .font(OWFontBook.shared.font(typography: .titleSmall))
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
            make.trailing.equalToSuperview().offset(-Metrics.closeButtonTrailingOffset)
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

    fileprivate let viewModel: OWCommentCreationLightViewViewModeling
    fileprivate let disposeBag = DisposeBag()

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(viewModel: OWCommentCreationLightViewViewModeling) {
        self.viewModel = viewModel
        super.init(frame: .zero)

        commentLabelsContainerView.configure(viewModel: viewModel.outputs.commentLabelsContainerVM)

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

        OWSharedServicesProvider.shared.themeStyleService()
            .style
            .subscribe(onNext: { [weak self] currentStyle in
                guard let self = self else { return }

                self.titleLabel.textColor = OWColorPalette.shared.color(type: .textColor1, themeStyle: currentStyle)
                self.closeButton.image(UIImage(spNamed: "closeCrossIconNew", supportDarkMode: true), state: .normal)
                self.separatorView.backgroundColor = OWColorPalette.shared.color(type: .separatorColor1, themeStyle: currentStyle)
                self.replyToLabel.textColor = OWColorPalette.shared.color(type: .textColor2, themeStyle: currentStyle)
            })
            .disposed(by: disposeBag)

        self.addSubview(topContainerView)
        topContainerView.OWSnp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(Metrics.topContainerHeight)
        }

        if viewModel.outputs.shouldShowReplySnippet {
            self.addSubviews(replyToLabel)
            replyToLabel.OWSnp.makeConstraints { make in
                make.top.equalTo(topContainerView.OWSnp.bottom).offset(Metrics.replyToVerticalSpacing)
                make.leading.trailing.equalToSuperview().inset(Metrics.horizontalOffset)
            }

            self.addSubview(replySnippetView)
            replySnippetView.OWSnp.makeConstraints { make in
                make.top.equalTo(replyToLabel.OWSnp.bottom).offset(Metrics.replyToVerticalSpacing)
                make.leading.trailing.equalToSuperview()
            }
        }

        self.addSubview(footerView)
        footerView.OWSnp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(Metrics.footerHeight)
        }

        self.addSubview(commentLabelsContainerView)
        commentLabelsContainerView.OWSnp.makeConstraints { make in
            make.bottom.equalTo(footerView.OWSnp.top).offset(-Metrics.commentLabelsSpacing)
            make.leading.equalToSuperview().offset(Metrics.commentLabelsSpacing)
            make.trailing.lessThanOrEqualToSuperview()
        }

        self.addSubview(commentReplyCounterView)
        commentReplyCounterView.OWSnp.makeConstraints { make in
            make.bottom.equalTo(commentLabelsContainerView.OWSnp.top)
            make.trailing.equalToSuperview().offset(-Metrics.horizontalOffset)
        }

        self.addSubview(contentView)
        contentView.OWSnp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(viewModel.outputs.shouldShowReplySnippet ? replySnippetView.OWSnp.bottom : topContainerView.OWSnp.bottom)
            make.bottom.equalTo(commentReplyCounterView.OWSnp.top)
        }
    }

    func setupObservers() {
        closeButton.rx.tap
            .bind(to: viewModel.inputs.closeButtonTap)
            .disposed(by: disposeBag)

        viewModel.outputs.titleText
            .bind(to: titleLabel.rx.text)
            .disposed(by: disposeBag)

        viewModel.outputs.replyToAttributedString
            .bind(to: replyToLabel.rx.attributedText)
            .disposed(by: disposeBag)
    }
}
