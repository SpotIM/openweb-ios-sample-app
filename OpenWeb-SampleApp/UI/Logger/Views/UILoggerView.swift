//
//  UILoggerView.swift
//  OpenWeb-Development
//
//  Created by Refael Sommer on 20/03/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import UIKit
import Foundation
import RxSwift

class UILoggerView: UIView {
    private struct Metrics {
        static let identifier = "logger_view_id"
        static let loggerTitleIdentifier = "logger_title_id"
        static let loggerTextViewIdentifier = "logger_text_view_id"
        static let verticalOffset: CGFloat = 20
        static let horizontalOffset: CGFloat = 15
        static let verticalPaddingForAutoScrollToBottom: CGFloat = -60
        static let delayScrollToBottom = 100 // Time in ms
    }

    private lazy var titleLabel: UILabel = {
        return UILabel()
            .font(FontBook.mainHeadingBold)
            .textColor(.black)
            .lineBreakMode(.byWordWrapping)
    }()

    private lazy var loggerTextView: UITextView = {
        let textView = UITextView()
            .isEditable(false)
            .isScrollEnabled(true)
            .isSelectable(false)
            .backgroundColor(.clear)
            .font(FontBook.helperLight)
            .textColor(.black)
            .indicatorStyle(.black)
        return textView
    }()

    private lazy var clearButton: UIButton = {
        let this = UIButton()
        this.setImage(UIImage(systemName: "trash"), for: .normal)
        this.tintColor = .black
        return this
    }()

    private let viewModel: UILoggerViewModeling
    private let disposeBag = DisposeBag()

    init(viewModel: UILoggerViewModeling = UILoggerViewModel()) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupViews()
        setupObservers()
        applyAccessibility()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension UILoggerView {
    func applyAccessibility() {
        self.accessibilityIdentifier = Metrics.identifier
        titleLabel.accessibilityIdentifier = Metrics.loggerTitleIdentifier
        loggerTextView.accessibilityIdentifier = Metrics.loggerTextViewIdentifier
    }

    func setupViews() {
        self.backgroundColor = .yellow

        self.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.leading.top.equalTo(self).inset(Metrics.horizontalOffset)
        }

        self.addSubview(clearButton)
        clearButton.snp.makeConstraints { make in
            make.trailing.top.equalTo(self).inset(Metrics.horizontalOffset)
            make.centerY.equalTo(titleLabel)
        }

        self.addSubview(loggerTextView)
        loggerTextView.snp.makeConstraints { make in
            make.leading.trailing.equalTo(self).inset(Metrics.horizontalOffset)
            make.top.equalTo(titleLabel.snp.bottom).offset(Metrics.verticalOffset)
            make.bottom.equalTo(self).inset(Metrics.verticalOffset)
        }
    }

    func setupObservers() {
        viewModel.outputs.loggerText
            .observe(on: MainScheduler.instance)
            .bind(to: loggerTextView.rx.text)
            .disposed(by: disposeBag)

        viewModel.outputs.loggerText
            .throttle(.milliseconds(Metrics.delayScrollToBottom), scheduler: MainScheduler.asyncInstance)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                guard let self else { return }
                self.scrollTextViewToBottom(textView: self.loggerTextView)
            })
            .disposed(by: disposeBag)

        viewModel.outputs.title
            .bind(to: titleLabel.rx.text)
            .disposed(by: disposeBag)

        clearButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.viewModel.inputs.clear()
            })
            .disposed(by: disposeBag)
    }

    func scrollTextViewToBottom(textView: UITextView) {
        if textView.text.count > 0,
           !textView.isDragging,
           textView.contentOffset.y + textView.frame.size.height <= textView.contentSize.height - Metrics.verticalPaddingForAutoScrollToBottom {
            let location = textView.text.count - 1
            let bottom = NSRange(location: location, length: 1)
            textView.scrollRangeToVisible(bottom)
        }
    }
}
