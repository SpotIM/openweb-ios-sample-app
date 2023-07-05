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
        static let textInputFontSize: CGFloat = 15.0
        static let placeholderLabelTopOffset: CGFloat = 8.0
        static let placeholderLabelLeadingOffset: CGFloat = 6.0
    }

    fileprivate let disposeBag = DisposeBag()
    fileprivate let viewModel: OWCommentCreationContentViewModeling

    fileprivate lazy var placeholderLabel: UILabel = {
        return UILabel()
            .font(OWFontBook.shared.font(style: .regular, size: Metrics.textInputFontSize))
            .textColor(OWColorPalette.shared.color(type: .textColor6, themeStyle: .light))
            .text(OWLocalizationManager.shared.localizedString(key: "What do you think?"))
    }()

    fileprivate lazy var textInput: UITextView = {
        var textView = UITextView()
            .backgroundColor(.clear)
            .font(OWFontBook.shared.font(style: .regular, size: Metrics.textInputFontSize))
            .textColor(OWColorPalette.shared.color(type: .textColor3, themeStyle: .light))
            .textAlignment(OWLocalizationManager.shared.textAlignment)

        textView.becomeFirstResponder()

        return textView
    }()

    init(with viewModel: OWCommentCreationContentViewModeling) {
        self.viewModel = viewModel
        super.init(frame: .zero)

        self.enforceSemanticAttribute()

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
        addSubview(textInput)
        textInput.OWSnp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        addSubview(placeholderLabel)
        placeholderLabel.OWSnp.makeConstraints { make in
            make.top.equalTo(textInput.OWSnp.top).offset(Metrics.placeholderLabelTopOffset)
            make.leading.equalTo(textInput.OWSnp.leading).offset(Metrics.placeholderLabelLeadingOffset)
        }
    }

    func setupObservers() {
        OWSharedServicesProvider.shared.themeStyleService()
            .style
            .subscribe(onNext: { [weak self] currentStyle in
                guard let self = self else { return }
                self.textInput.textColor = OWColorPalette.shared.color(type: .textColor3, themeStyle: currentStyle)
                self.placeholderLabel.textColor = OWColorPalette.shared.color(type: .textColor6, themeStyle: currentStyle)
            }).disposed(by: disposeBag)

        viewModel.outputs.commentTextOutput
            .bind(to: textInput.rx.text)
            .disposed(by: disposeBag)

        textInput.rx.didChange
            .map { [weak self] _ in
                guard let self = self else { return nil }
                return self.textInput.text
            }
            .bind(to: viewModel.inputs.commentText)
            .disposed(by: disposeBag)

        viewModel.outputs.showPlaceholder
            .map { !$0 }
            .bind(to: placeholderLabel.rx.isHidden)
            .disposed(by: disposeBag)
    }

    func applyAccessibility() {

    }
}
