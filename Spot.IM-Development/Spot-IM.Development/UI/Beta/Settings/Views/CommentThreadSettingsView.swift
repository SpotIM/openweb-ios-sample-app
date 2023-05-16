//
//  IAUSettingsView.swift
//  Spot-IM.Development
//
//  Created by Refael Sommer on 09/05/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import UIKit
import RxSwift

#if NEW_API

class CommentThreadSettingsView: UIView {

    fileprivate struct Metrics {
        static let identifier = "comment_thread_settings_view_id"
        static let textFieldOpenCommentIdIdentifier = "comment_thread_settings_view_open_comment_id_id"
        static let verticalOffset: CGFloat = 40
        static let horizontalOffset: CGFloat = 10
    }

    fileprivate lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = Metrics.verticalOffset
        return stackView
    }()

    fileprivate lazy var titleLabel: UILabel = {
        var titleLabel = UILabel()
        titleLabel.text = viewModel.outputs.title
        titleLabel.font = FontBook.secondaryHeadingBold
        return titleLabel
    }()

    fileprivate lazy var textFieldOpenCommentId: TextFieldSetting = {
        let txtField = TextFieldSetting(title: viewModel.outputs.openCommentIdTitle,
                                        accessibilityPrefixId: Metrics.textFieldOpenCommentIdIdentifier,
                                        font: FontBook.paragraph)
        return txtField
    }()

    fileprivate let viewModel: CommentThreadSettingsViewModeling
    fileprivate let disposeBag = DisposeBag()

    init(viewModel: CommentThreadSettingsViewModeling) {
        self.viewModel = viewModel
        super.init(frame: CGRect.zero)
        setupViews()
        applyAccessibility()
        setupObservers()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

fileprivate extension CommentThreadSettingsView {
    func applyAccessibility() {
        self.accessibilityIdentifier = Metrics.identifier
        textFieldOpenCommentId.accessibilityIdentifier = Metrics.textFieldOpenCommentIdIdentifier
    }

    func setupViews() {
        self.backgroundColor = ColorPalette.shared.color(type: .background)

        // Add a StackView so that hidden controlls constraints will be removed
        self.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.leading.trailing.equalTo(self).inset(Metrics.horizontalOffset)
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
        }

        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(textFieldOpenCommentId)
    }

    func setupObservers() {
        viewModel.outputs.openCommentId
            .bind(to: textFieldOpenCommentId.rx.textFieldText)
            .disposed(by: disposeBag)

        textFieldOpenCommentId.rx.textFieldText
            .unwrap()
            .bind(to: viewModel.inputs.openCommentIdSelected)
            .disposed(by: disposeBag)
    }
}

#endif
