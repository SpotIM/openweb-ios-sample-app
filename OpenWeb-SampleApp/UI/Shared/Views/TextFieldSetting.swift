//
//  TextFieldSetting.swift
//  OpenWeb-Development
//
//  Created by Refael Sommer on 19/01/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import UIKit
import Combine
import CombineCocoa

class TextFieldSetting: UIView {
    private struct Metrics {
        static let horizontalOffset: CGFloat = 10
        static let textFieldCorners: CGFloat = 12
        static let keyboardPadding: CGFloat = 5
        static let titleWidthProportion: CGFloat = 0.33
        static let titleNumberOfLines: Int = 2
    }

    private let title: String
    private let placeholder: String
    private let text = CurrentValueSubject<String?, Never>(nil)
    private var font: UIFont
    private var cancellables = Set<AnyCancellable>()

    fileprivate lazy var textFieldTitleLbl: UILabel = {
        return title
            .label
            .font(font)
            .numberOfLines(Metrics.titleNumberOfLines)
            .lineBreakMode(.byWordWrapping)
    }()

    private(set) lazy var textFieldControl = {
        let textField = UITextField()
            .corner(radius: Metrics.textFieldCorners)
            .border(width: 1.0, color: ColorPalette.shared.color(type: .blackish))
            .borderStyle(.roundedRect)
            .autocapitalizationType(.none)
            .placeholder(placeholder)
        return textField
    }()

    init(title: String, placeholder: String = "", accessibilityPrefixId: String, text: String? = nil, font: UIFont = FontBook.mainHeading) {
        self.title = title
        self.placeholder = placeholder
        self.font = font
        super.init(frame: .zero)
        textFieldControl.text = text

        setupViews()
        setupObservers()
        applyAccessibility(prefixId: accessibilityPrefixId)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension TextFieldSetting {
    func applyAccessibility(prefixId: String) {
        textFieldTitleLbl.accessibilityIdentifier = prefixId + "_label_id"
        textFieldControl.accessibilityIdentifier = prefixId + "_text_field_id"
    }

    @objc func setupViews() {
        let stackView = UIStackView()
        self.addSubview(stackView)
        stackView.distribution = .fillProportionally
        stackView.addArrangedSubview(textFieldTitleLbl)
        stackView.addArrangedSubview(textFieldControl)
        stackView.spacing = Metrics.horizontalOffset
        stackView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(Metrics.horizontalOffset)
            make.trailing.equalToSuperview().offset(-Metrics.horizontalOffset)
            make.top.bottom.equalToSuperview()
        }

        textFieldTitleLbl.snp.makeConstraints { make in
            make.width.equalTo(self.snp.width).multipliedBy(Metrics.titleWidthProportion)
        }

        textFieldControl.snp.makeConstraints { make in
            make.width.equalTo(self.snp.width).multipliedBy(1 - Metrics.titleWidthProportion).priority(.low)
        }
    }

    func setupObservers() {
        text
            .dropFirst() // Skip initialize CurrentValueSubject value
            .prefix(1) // Take first value after initialize
            .assign(to: \.text, on: textFieldControl)
            .store(in: &cancellables)

        textFieldControl.controlEventPublisher(for: [.editingDidEnd, .editingDidEndOnExit])
            .sink { [weak self] _ in
                self?.textFieldControl.endEditing(true)
            }
            .store(in: &cancellables)

        let keyboardShowHeight = NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
            .map { notification -> CGFloat in
                let height = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.height
                return height ?? 0
            }

        let keyboardHideHeight = NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
            .map { _ -> CGFloat in
                0
            }

        Publishers.Merge(keyboardShowHeight, keyboardHideHeight)
            .sink { [weak self] keyboardHeight in
                guard let self else { return }
                if self.textFieldControl.isFirstResponder,
                   let scrollView = self.superview as? UIScrollView {
                    let insets = UIEdgeInsets(top: 0,
                                              left: 0,
                                              bottom: keyboardHeight + Metrics.keyboardPadding,
                                              right: 0)
                    scrollView.contentInset = insets
                    scrollView.scrollIndicatorInsets = insets

                    if scrollView.frame.height - keyboardHeight + scrollView.contentOffset.y < self.frame.origin.y + Metrics.keyboardPadding + self.frame.size.height {
                        let moveTo = self.frame.origin.y - keyboardHeight + self.frame.size.height + Metrics.keyboardPadding
                        let scrollPoint = CGPoint(x: 0, y: moveTo)
                        scrollView.setContentOffset(scrollPoint, animated: true)
                    }
                } else if let scrollView = self.superview as? UIScrollView {
                    let insets = UIEdgeInsets.zero
                    scrollView.contentInset = insets
                    scrollView.scrollIndicatorInsets = insets
                }
            }
            .store(in: &cancellables)
    }
}
