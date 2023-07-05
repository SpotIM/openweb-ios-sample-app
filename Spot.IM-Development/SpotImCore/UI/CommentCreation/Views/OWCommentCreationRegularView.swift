//
//  OWCommentCreationRegularView.swift
//  SpotImCore
//
//  Created by Alon Shprung on 07/06/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class OWCommentCreationRegularView: UIView, OWThemeStyleInjectorProtocol {
    fileprivate struct Metrics {
        static let identifier = "comment_creation_regular_view_id"

        static let replyCounterTrailingOffset = 16.0
    }

    fileprivate lazy var titleLabel: UILabel = {
        return UILabel()
            .font(OWFontBook.shared.font(style: .regular, size: 15.0))
            .textColor(OWColorPalette.shared.color(type: .textColor2, themeStyle: .light))
            .numberOfLines(1)
            .enforceSemanticAttribute()
    }()

    fileprivate lazy var closeButton: UIButton = {
        return UIButton()
            .image(UIImage(spNamed: "closeCrossIcon", supportDarkMode: true), state: .normal)
    }()

    fileprivate lazy var topContainerView: UIView = {
        let topContainerView = UIView()

        topContainerView.addSubview(closeButton)
        closeButton.OWSnp.makeConstraints { make in
            make.centerY.equalTo(topContainerView.OWSnp.centerY)
            make.trailing.equalToSuperview().offset(-5.0)
            make.size.equalTo(40.0)
        }

        topContainerView.addSubview(titleLabel)
        titleLabel.OWSnp.makeConstraints { make in
            make.centerY.equalTo(topContainerView.OWSnp.centerY)
            make.leading.equalToSuperview().offset(16.0)
            make.trailing.equalTo(closeButton.OWSnp.leading).offset(-16.0)
        }

        return topContainerView
    }()

    fileprivate lazy var articleDescriptionView: OWArticleDescriptionView = {
        return OWArticleDescriptionView(viewModel: self.viewModel.outputs.articleDescriptionViewModel)
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

    fileprivate let viewModel: OWCommentCreationRegularViewViewModeling
    fileprivate let disposeBag = DisposeBag()

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(viewModel: OWCommentCreationRegularViewViewModeling) {
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

fileprivate extension OWCommentCreationRegularView {
    func setupViews() {
        self.useAsThemeStyleInjector()

        OWSharedServicesProvider.shared.themeStyleService()
            .style
            .subscribe(onNext: { [weak self] currentStyle in
                guard let self = self else { return }

                self.titleLabel.textColor = OWColorPalette.shared.color(type: .textColor2, themeStyle: currentStyle)
                self.closeButton.image(UIImage(spNamed: "closeCrossIcon", supportDarkMode: true), state: .normal)
            })
            .disposed(by: disposeBag)

        self.addSubview(topContainerView)
        topContainerView.OWSnp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(68.0)
        }

        self.addSubview(articleDescriptionView)
        articleDescriptionView.OWSnp.makeConstraints { make in
            make.top.equalTo(topContainerView.OWSnp.bottom)
            make.leading.trailing.equalToSuperview()
        }

        self.addSubview(footerView)
        footerView.OWSnp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(72.0)
        }

        self.addSubview(commentLabelsContainerView)
        commentLabelsContainerView.OWSnp.makeConstraints { make in
            make.bottom.equalTo(footerView.OWSnp.top).offset(-15.0)
            make.leading.equalToSuperview().offset(15.0)
            make.trailing.lessThanOrEqualToSuperview()
        }

        self.addSubview(commentReplyCounterView)
        commentReplyCounterView.OWSnp.makeConstraints { make in
            make.bottom.equalTo(commentLabelsContainerView.OWSnp.top)
            make.trailing.equalToSuperview().offset(-Metrics.replyCounterTrailingOffset)
        }

        self.addSubview(contentView)
        contentView.OWSnp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(articleDescriptionView.OWSnp.bottom)
            make.bottom.equalTo(commentReplyCounterView.OWSnp.top)
        }
    }

    func setupObservers() {
        closeButton.rx.tap
            .bind(to: viewModel.inputs.closeButtonTap)
            .disposed(by: disposeBag)

        viewModel.outputs.titleAttributedString
            .bind(to: titleLabel.rx.attributedText)
            .disposed(by: disposeBag)
    }
}
