//
//  OWCommunityQuestionView.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 05/09/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import UIKit
import RxSwift

// TODO: complete
class OWCommunityQuestionView: UIView {
    fileprivate struct Metrics {
        static let fontSize: CGFloat = 15.0
        static let questionHorizontalOffset: CGFloat = 12.0
        static let questionVerticalOffset: CGFloat = 8.0
        static let containerCorderRadius: CGFloat = 8.0

        static let identifier = "community_question_id"
    }

    fileprivate lazy var titleTextView: UITextView = {
        let textView = UITextView()
            .backgroundColor(.clear)
            .isEditable(false)
            .isSelectable(false)
            .userInteractionEnabled(true)
            .isScrollEnabled(false)
            .wrapContent(axis: .vertical)
            .hugContent(axis: .vertical)
            .dataDetectorTypes([.link])
            .font(OWFontBook.shared.font(typography: .bodySpecial))
            .textContainerInset(.zero)

        textView.linkTextAttributes = [NSAttributedString.Key.foregroundColor: OWColorPalette.shared.color(type: .brandColor, themeStyle: .light),
                                       NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue]
        textView.textContainer.lineFragmentPadding = 0
        textView.sizeToFit()
        return textView
    }()

    fileprivate lazy var questionLabel: UILabel = {
        return UILabel()
            .wrapContent()
            .numberOfLines(0)
            .font(OWFontBook.shared.font(typography: .bodySpecial))
            .textColor(OWColorPalette.shared.color(type: .textColor3,
                                                         themeStyle: OWSharedServicesProvider.shared.themeStyleService().currentStyle))
    }()

    fileprivate lazy var questionContainer: UIView = {
        return UIView()
            .backgroundColor(OWColorPalette.shared.color(type: .backgroundColor1, themeStyle: OWSharedServicesProvider.shared.themeStyleService().currentStyle))
            .corner(radius: Metrics.containerCorderRadius)
            .border(width: 1, color: OWColorPalette.shared.color(type: .borderColor1, themeStyle: OWSharedServicesProvider.shared.themeStyleService().currentStyle))
    }()

    fileprivate var heightConstraint: OWConstraint? = nil
    fileprivate var viewModel: OWCommunityQuestionViewModeling!
    fileprivate var disposeBag = DisposeBag()

    // For init when using in Views and not in cells
    init(with viewModel: OWCommunityQuestionViewModeling) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        updateUI()
        setupObservers()
        applyAccessibility()
    }

    // For using in cells that will then call the configure function
    init() {
        super.init(frame: .zero)
        applyAccessibility()
    }

    // Only when using community question as a cell
    func configure(with viewModel: OWCommunityQuestionViewModeling) {
        self.viewModel = viewModel
        self.disposeBag = DisposeBag()
        self.updateUI()
        self.setupObservers()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

fileprivate extension OWCommunityQuestionView {
    func applyAccessibility() {
        self.accessibilityIdentifier = Metrics.identifier
    }

    func updateCustomUI() {
        viewModel.inputs.triggerCustomizeQuestionContainerViewUI.onNext(questionContainer)
        viewModel.inputs.triggerCustomizeQuestionTitleLabelUI.onNext(questionLabel)
        viewModel.inputs.triggerCustomizeQuestionTitleTextViewUI.onNext(titleTextView)
    }

    // This function is Called updateUI instead of setupUI since it is designed to be reused for cells -
    // using function configure and here it is also called in init when this class is used as a standalone uiview
    func updateUI() {
        self.backgroundColor = .clear
        self.isHidden = true

        questionContainer.removeFromSuperview()
        questionLabel.removeFromSuperview()
        titleTextView.removeFromSuperview()

        if viewModel.outputs.showContainer {
            self.addSubview(questionContainer)
            questionContainer.OWSnp.makeConstraints { make in
                make.edges.equalToSuperview()
            }

            questionContainer.addSubview(questionLabel)
            questionLabel.OWSnp.makeConstraints { make in
                make.top.equalToSuperview().offset(Metrics.questionVerticalOffset)
                make.bottom.equalToSuperview().offset(-Metrics.questionVerticalOffset)
                make.leading.equalToSuperview().offset(Metrics.questionHorizontalOffset)
                make.trailing.equalToSuperview().offset(-Metrics.questionHorizontalOffset)
            }
        } else {
            self.addSubview(titleTextView)
            titleTextView.OWSnp.makeConstraints { make in
                make.edges.equalToSuperview()
                heightConstraint = make.height.equalTo(0).constraint
            }
        }
    }

    func setupObservers() {
        viewModel.outputs.communityQuestion
            .bind(to: questionLabel.rx.text)
            .disposed(by: disposeBag)

        viewModel.outputs.attributedCommunityQuestion
            .bind(to: titleTextView.rx.attributedText)
            .disposed(by: disposeBag)

        viewModel.outputs.shouldShowView
            .map { !$0 }
            .bind(to: self.rx.isHidden)
            .disposed(by: disposeBag)

        if let heightConstraint = heightConstraint {
            viewModel.outputs.shouldShowView
                .map { !$0 }
                .bind(to: heightConstraint.rx.isActive)
                .disposed(by: disposeBag)
        }

        OWSharedServicesProvider.shared.themeStyleService()
            .style
            .subscribe(onNext: { [weak self] currentStyle in
                guard let self = self else { return }
                self.questionLabel.textColor = OWColorPalette.shared.color(type: .textColor3, themeStyle: currentStyle)
                self.questionContainer.backgroundColor = OWColorPalette.shared.color(type: .backgroundColor1, themeStyle: currentStyle)
                self.questionContainer.layer.borderColor = OWColorPalette.shared.color(type: .borderColor1, themeStyle: currentStyle).cgColor
                self.titleTextView.textColor = OWColorPalette.shared.color(type: .textColor2, themeStyle: currentStyle)
                self.updateCustomUI()
            })
            .disposed(by: disposeBag)

        OWSharedServicesProvider.shared.appLifeCycle()
            .didChangeContentSizeCategory
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.titleTextView.font = OWFontBook.shared.font(typography: .bodySpecial)
                self.questionLabel.font = OWFontBook.shared.font(typography: .bodySpecial)
            })
            .disposed(by: disposeBag)
    }
}
