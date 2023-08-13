//
//  OWCommentCreationContentView.swift
//  SpotImCore
//
//  Created by Alon Shprung on 03/07/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

class OWCommentCreationContentView: UIView {
    fileprivate struct Metrics {
        static let identifier = "comment_cretion_content_id"
        static let textInputIdentifier = "comment_cretion_content_text_id"

        static let placeholderLabelTopOffset: CGFloat = 8.0
        static let placeholderLabelLeadingOffset: CGFloat = 6.0
        static let horizontalOffset: CGFloat = 16.0
        static let verticalOffset: CGFloat = 12.0
        static let avatarSize: CGFloat = 40.0
        static let avatarToInputSpacing: CGFloat = 13.0
    }

    fileprivate let disposeBag = DisposeBag()
    fileprivate let viewModel: OWCommentCreationContentViewModeling

    fileprivate lazy var avatarView: OWAvatarView = {
        return OWAvatarView()
    }()

    fileprivate lazy var placeholderLabel: UILabel = {
        return UILabel()
            .font(OWFontBook.shared.font(typography: .bodyText))
            .textColor(OWColorPalette.shared.color(type: .textColor6, themeStyle: .light))
    }()

    fileprivate lazy var textInput: UITextView = {
        var textView = UITextView()
            .backgroundColor(.clear)
            .font(OWFontBook.shared.font(typography: .bodyText))
            .textColor(OWColorPalette.shared.color(type: .textColor3, themeStyle: .light))
            .textAlignment(OWLocalizationManager.shared.textAlignment)
            .textContainerInset(.zero)
            .tintColor(OWColorPalette.shared.color(type: .cursorColor, themeStyle: .light))
            .isScrollEnabled(false)

        textView.becomeFirstResponder()

        return textView
    }()

    fileprivate lazy var scrollView: UIScrollView = {
        let scroll = UIScrollView()
            .enforceSemanticAttribute()

        scroll.isUserInteractionEnabled = true

        scroll.contentLayoutGuide.OWSnp.makeConstraints { make in
            make.width.equalTo(scroll)
        }

        scroll.addSubview(avatarView)
        avatarView.OWSnp.makeConstraints { make in
            make.top.equalToSuperview().offset(Metrics.verticalOffset)
            make.leading.equalTo(scroll.contentLayoutGuide).offset(Metrics.horizontalOffset)
            make.size.equalTo(Metrics.avatarSize)
        }

        scroll.addSubview(textInput)
        textInput.OWSnp.makeConstraints { make in
            make.leading.equalTo(avatarView.OWSnp.trailing).offset(Metrics.avatarToInputSpacing)
            make.trailing.equalTo(scroll.contentLayoutGuide).offset(-Metrics.horizontalOffset)
            make.top.bottom.equalToSuperview().inset(Metrics.verticalOffset)
        }

        scroll.addSubview(placeholderLabel)
        placeholderLabel.OWSnp.makeConstraints { make in
            make.top.equalTo(textInput.OWSnp.top)
            make.leading.equalTo(textInput.OWSnp.leading).offset(Metrics.placeholderLabelLeadingOffset)
        }

        return scroll
    }()

    init(with viewModel: OWCommentCreationContentViewModeling) {
        self.viewModel = viewModel
        super.init(frame: .zero)

        avatarView.configure(with: viewModel.outputs.avatarViewVM)

        setupUI()
        setupObservers()
        applyAccessibility()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

fileprivate extension OWCommentCreationContentView {
    func setupUI() {
        self.enforceSemanticAttribute()

        addSubview(scrollView)
        scrollView.OWSnp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    func setupObservers() {
        OWSharedServicesProvider.shared.themeStyleService()
            .style
            .subscribe(onNext: { [weak self] currentStyle in
                guard let self = self else { return }
                self.textInput.textColor = OWColorPalette.shared.color(type: .textColor3, themeStyle: currentStyle)
                self.textInput.tintColor = OWColorPalette.shared.color(type: .cursorColor, themeStyle: currentStyle)
                self.placeholderLabel.textColor = OWColorPalette.shared.color(type: .textColor6, themeStyle: currentStyle)
            }).disposed(by: disposeBag)

        viewModel.outputs.commentTextOutput
            .bind(to: textInput.rx.text)
            .disposed(by: disposeBag)

        textInput.rx.didChange
            .map { [weak self] _ in
                guard let self = self else { return "" }
                return self.textInput.text
            }
            .bind(to: viewModel.inputs.commentText)
            .disposed(by: disposeBag)

        viewModel.outputs.showPlaceholder
            .map { !$0 }
            .bind(to: placeholderLabel.rx.isHidden)
            .disposed(by: disposeBag)

        viewModel.outputs.placeholderText
            .bind(to: placeholderLabel.rx.text)
            .disposed(by: disposeBag)

        OWSharedServicesProvider.shared.appLifeCycle()
            .didChangeContentSizeCategory
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.placeholderLabel.font = OWFontBook.shared.font(typography: .bodyText)
                self.textInput.font = OWFontBook.shared.font(typography: .bodyText)
            })
            .disposed(by: disposeBag)

    }

    func applyAccessibility() {
        self.accessibilityIdentifier = Metrics.identifier
        self.textInput.accessibilityIdentifier = Metrics.textInputIdentifier
    }
}
