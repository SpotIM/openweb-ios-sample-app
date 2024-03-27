//
//  OWTextView.swift
//  SpotImCore
//
//  Created by Refael Sommer on 30/04/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import NaturalLanguage

class OWTextView: UIView {
    fileprivate struct Metrics {
        static let suffixIdentifier = "_text_view_view_id"
        static let textViewSuffixIdentifier = "_textview_id"
        static let placeholderLabelSuffixIdentifier = "_placeholder_label_id"
        static let charectersCounterLabelSuffixIdentifier = "_charecters_counter_label_id"
        static let cornerRadius: CGFloat = 6
        static let borderWidth: CGFloat = 1
        static let textViewBottomPadding: CGFloat = 16
        static let charectersTrailingPadding: CGFloat = 12
        static let charectersBottomPadding: CGFloat = 8
        static let textViewLeadingTrailingPadding: CGFloat = 10
        static let placeholderLeadingTrailingPadding: CGFloat = textViewLeadingTrailingPadding + 5
        static let textViewTopBottomPadding: CGFloat = 10
        static let textViewFontSize: CGFloat = 15
        static let charectersFontSize: CGFloat = 13
        static let baseTextViewHeight: CGFloat = 30
        static let maxNumberOfLines = 5
        static let expandAnimationDuration: CGFloat = 0.1
        static let heightConstraintPriority: CGFloat = 500
        static let didBeginEditDelay = 1
        static let delayTextViewTextChange = 5
        static let delayTextViewExpand = 10
    }

    let viewModel: OWTextViewViewModeling
    fileprivate let disposeBag = DisposeBag()

    fileprivate lazy var textView: UITextView = {
        let currentStyle = OWSharedServicesProvider.shared.themeStyleService().currentStyle
        let textView = UITextView()
            .font(OWFontBook.shared.font(typography: .bodyText))
            .textColor(OWColorPalette.shared.color(type: .textColor3, themeStyle: OWSharedServicesProvider.shared.themeStyleService().currentStyle))
            .tintColor(OWColorPalette.shared.color(type: .brandColor, themeStyle: OWSharedServicesProvider.shared.themeStyleService().currentStyle))
            .textContainerInset(
                UIEdgeInsets(
                    top: Metrics.textViewTopBottomPadding,
                    left: Metrics.textViewLeadingTrailingPadding,
                    bottom: Metrics.textViewTopBottomPadding,
                    right: Metrics.textViewLeadingTrailingPadding
                )
            )
            .enforceSemanticAttribute()
        return textView
    }()

    fileprivate lazy var charectersCountLabel: UILabel = {
        return UILabel()
                .font(OWFontBook.shared.font(typography: .footnoteText))
                .textColor(OWColorPalette.shared.color(type: .textColor6, themeStyle: OWSharedServicesProvider.shared.themeStyleService().currentStyle))
                .text("0/" + "\(self.viewModel.outputs.textViewMaxCharecters)")
                .enforceSemanticAttribute()
    }()

    fileprivate lazy var textViewPlaceholder: UILabel = {
        return UILabel()
                .font(OWFontBook.shared.font(typography: .bodyText))
                .textColor(OWColorPalette.shared.color(type: .textColor2, themeStyle: OWSharedServicesProvider.shared.themeStyleService().currentStyle))
                .numberOfLines(0)
                .enforceSemanticAttribute()
    }()

    init(viewModel: OWTextViewViewModeling, prefixIdentifier: String) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        self.enforceSemanticAttribute()
        setupViews()
        setupObservers()
        applyAccessibility(prefixId: prefixIdentifier)
        textView.rx
            .setDelegate(self)
            .disposed(by: disposeBag)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension OWTextView: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let replaceData = OWTextViewReplaceData(text: text, originalText: textView.text, range: range)
        viewModel.inputs.internalReplacedData.onNext(replaceData)
        return true
    }
}

fileprivate extension OWTextView {
    func applyAccessibility(prefixId: String) {
        self.accessibilityIdentifier = prefixId + Metrics.suffixIdentifier
        textView.accessibilityIdentifier = prefixId + Metrics.textViewSuffixIdentifier
        textViewPlaceholder.accessibilityIdentifier = prefixId + Metrics.placeholderLabelSuffixIdentifier
        charectersCountLabel.accessibilityIdentifier = prefixId + Metrics.charectersCounterLabelSuffixIdentifier
    }

    func setupViews() {
        self.layer.cornerRadius = Metrics.cornerRadius
        self.layer.borderWidth = Metrics.borderWidth
        self.layer.borderColor = OWColorPalette.shared.color(type: .brandColor, themeStyle: OWSharedServicesProvider.shared.themeStyleService().currentStyle).cgColor

        if viewModel.outputs.charectersLimitEnabled && viewModel.outputs.showCharectersLimit {
            self.addSubviews(charectersCountLabel)
            charectersCountLabel.OWSnp.makeConstraints { make in
                make.trailing.equalToSuperview().inset(Metrics.charectersTrailingPadding)
                make.bottom.equalToSuperview().inset(Metrics.charectersBottomPadding)
            }
        }

        self.addSubviews(textView)
        textView.OWSnp.makeConstraints { make in
            if viewModel.outputs.charectersLimitEnabled && viewModel.outputs.showCharectersLimit {
                make.top.leading.trailing.equalToSuperview()
                make.bottom.equalTo(charectersCountLabel.OWSnp.top)
            } else {
                make.edges.equalToSuperview()
            }
            if viewModel.outputs.isAutoExpandable {
                make.height.equalTo(textView.newHeight(withBaseHeight: Metrics.baseTextViewHeight,
                                                       maxLines: Metrics.maxNumberOfLines)).priority(Metrics.heightConstraintPriority)
            }
        }

        self.addSubviews(textViewPlaceholder)
        textViewPlaceholder.OWSnp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(Metrics.placeholderLeadingTrailingPadding)
            make.top.equalTo(textView.OWSnp.top).inset(Metrics.textViewTopBottomPadding)
            make.bottom.lessThanOrEqualTo(textView).inset(Metrics.textViewTopBottomPadding)
        }
    }

    // swiftlint:disable function_body_length
    func setupObservers() {
        viewModel.outputs.attributedTextChanged
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] attributedText in
                guard let self = self else { return }
                self.addAttributes(from: attributedText)
            })
            .disposed(by: disposeBag)

        textView.rx.didChange
            .withLatestFrom(viewModel.outputs.internalReplaceData)
            .subscribe(onNext: { [weak self] replaceData in
                guard let self = self,
                      let originalText = replaceData.originalText,
                      let replacedRange = Range(replaceData.range, in: originalText) else { return }
                let afterReplacedText = originalText.replacingOccurrences(of: originalText[replacedRange], with: replaceData.text, range: replacedRange)
                let currentText = self.textView.text
                if let currentText = currentText,
                   !(currentText.utf16.count == afterReplacedText.utf16.count &&
                   replaceData.range.length == 0) {
                    self.viewModel.inputs.replacedData.onNext(replaceData)
                }
                guard afterReplacedText != currentText else {
                    return
                }
                // Since UITextView replaces a whitespace automatically if replacing range that before has a whitepace or removes a whitespace after range if the range start index (location) is 0 at the begining.
                // So here we check for whitespaces after and before for both cases so that we send the real replace range.
                let range = replaceData.range
                let replaceText = replaceData.text
                var rangeToSend = range
                rangeToSend.location += range.location == 0 ? range.length : -1
                rangeToSend.length = 1
                if replaceText.isEmpty,
                   let rangeIsSpace = Range(rangeToSend, in: originalText),
                   originalText[rangeIsSpace] == " " {
                    if rangeToSend.location > range.location {
                        rangeToSend.location = range.location
                    }

                    if rangeToSend.length > 0 {
                        let newReplaceData = OWTextViewReplaceData(text: "", originalText: nil, range: rangeToSend)
                        self.viewModel.inputs.replacedData.onNext(newReplaceData)
                    }
                }
            })
            .disposed(by: disposeBag)

        textView.rx.didChangeSelection
            .map { [weak self] _ -> Range<String.Index>? in
                guard let self = self else { return nil }
                let range = Range(self.textView.selectedRange, in: self.textView.text)
                return range
            }
            .unwrap()
            .bind(to: viewModel.inputs.cursorRangeInternalChange)
            .disposed(by: disposeBag)

        viewModel.outputs.cursorRange
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] cursorRange in
                guard let self = self,
                      let range = self.textView.text?.nsRange(from: cursorRange) else { return }
                let savedDelegate = self.textView.delegate
                self.textView.delegate = nil // Fixes looping cursor range
                self.textView.selectedRange = range
                self.textView.delegate = savedDelegate // Return rx proxy delegate back again
            })
            .disposed(by: disposeBag)

        viewModel.outputs.cursorRangeExternalChanged
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] range in
                guard let self = self,
                      let nsRange = self.textView.text?.nsRange(from: range) else { return }
                let savedDelegate = self.textView.delegate
                self.textView.delegate = nil // Fixes looping cursor range
                self.textView.selectedRange = nsRange
                self.viewModel.inputs.cursorRangeInternalChange.onNext(range)
                self.textView.delegate = savedDelegate // Return rx proxy delegate back again
            })
            .disposed(by: disposeBag)

        textView.rx.text
            .unwrap()
            .bind(to: viewModel.inputs.textInternalChange)
            .disposed(by: disposeBag)

        viewModel.outputs.textViewText
            .observe(on: MainScheduler.instance)
            .bind(to: textView.rx.text)
            .disposed(by: disposeBag)

        viewModel.outputs.textViewTextCount
            .bind(to: charectersCountLabel.rx.text)
            .disposed(by: disposeBag)

        viewModel.outputs.placeholderText
            .subscribe(onNext: { [weak self] placeholderText in
                guard let self = self else { return }
                self.textViewPlaceholder.text = placeholderText
            })
            .disposed(by: disposeBag)

        viewModel.outputs.hidePlaceholder
            .bind(to: textViewPlaceholder.rx.isHidden)
            .disposed(by: disposeBag)

        if viewModel.outputs.isEditable {
            if viewModel.outputs.isAutoExpandable {
                textView.rx.text
                    // Fixes a jump when loading
                    .skip(1)
                    // Fixes multiline text not being loaded properly
                    .delay(.milliseconds(Metrics.delayTextViewExpand), scheduler: MainScheduler.instance)
                    .subscribe(onNext: { [weak self] _ in
                        OWScheduler.runOnMainThreadIfNeeded {
                            guard let self = self else { return }
                            UIView.animate(withDuration: Metrics.expandAnimationDuration) {
                                self.textView.OWSnp.updateConstraints { make in
                                    make.height.equalTo(self.textView.newHeight(withBaseHeight: Metrics.baseTextViewHeight,
                                                                                maxLines: Metrics.maxNumberOfLines)).priority(Metrics.heightConstraintPriority)
                                }
                                self.layoutIfNeeded()
                            }
                        }
                    })
                    .disposed(by: disposeBag)
            }
        } else {
            textView.rx.didBeginEditing
                .bind(to: viewModel.inputs.textViewTap)
                .disposed(by: disposeBag)

            textView.rx.didBeginEditing
                .delay(.microseconds(Metrics.didBeginEditDelay), scheduler: MainScheduler.asyncInstance)
                .subscribe(onNext: { [weak self] in
                    guard let self = self else { return }
                    self.textView.resignFirstResponder()
                })
                .disposed(by: disposeBag)
        }

        viewModel.outputs.becomeFirstResponderCalledWithDelay
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.textView.becomeFirstResponder()
            })
            .disposed(by: disposeBag)

        viewModel.outputs.resignFirstResponderCalled
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.textView.resignFirstResponder()
            })
            .disposed(by: disposeBag)

        OWSharedServicesProvider.shared.themeStyleService()
            .style
            .subscribe(onNext: { [weak self] currentStyle in
                guard let self = self else { return }
                self.layer.borderColor = OWColorPalette.shared.color(type: .brandColor, themeStyle: currentStyle).cgColor
                self.textViewPlaceholder.textColor = OWColorPalette.shared.color(type: .textColor2, themeStyle: currentStyle)
                self.textView.backgroundColor = OWColorPalette.shared.color(type: .backgroundColor2, themeStyle: currentStyle)
                self.textView.tintColor = OWColorPalette.shared.color(type: .brandColor, themeStyle: currentStyle)
                self.textView.textColor = OWColorPalette.shared.color(type: .textColor3, themeStyle: currentStyle)
            })
            .disposed(by: disposeBag)

        OWSharedServicesProvider.shared.appLifeCycle()
            .didChangeContentSizeCategory
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.textView.font = OWFontBook.shared.font(typography: .bodyText)
                self.charectersCountLabel.font = OWFontBook.shared.font(typography: .footnoteText)
                self.textViewPlaceholder.font = OWFontBook.shared.font(typography: .bodyText)
            })
            .disposed(by: disposeBag)

        viewModel.outputs.hasSuggestionsBarChanged
            .subscribe(onNext: { [weak self] hasSuggestionsBar in
                guard let self = self else { return }
                textView.spellCheckingType(hasSuggestionsBar ? .default : .no)
                textView.autocorrectionType(hasSuggestionsBar ? .default : .no)
            })
            .disposed(by: disposeBag)
    }

    func detectedLanguage(for string: String) -> String? {
        let recognizer = NLLanguageRecognizer()
        recognizer.processString(string)
        guard let languageCode = recognizer.dominantLanguage?.rawValue else { return nil }
        return languageCode
    }

    func addAttributes(from attributedText: NSAttributedString) {
        guard let font = self.textView.font else { return }

        let nsRange = NSRange(location: 0, length: attributedText.string.utf16.count)
        let textColor = OWColorPalette.shared.color(type: .textColor3, themeStyle: OWSharedServicesProvider.shared.themeStyleService().currentStyle)

        let updatedAttributedText = NSMutableAttributedString(string: attributedText.string)

        let paragraphStyle = NSMutableParagraphStyle()

        paragraphStyle.baseWritingDirection =  NSMutableParagraphStyle.defaultWritingDirection(forLanguage: detectedLanguage(for: String(attributedText.string)))

        updatedAttributedText.addAttribute(.font, value: font, range: nsRange)
        updatedAttributedText.addAttribute(.foregroundColor, value: textColor, range: nsRange)

        attributedText.enumerateAttributes(in: nsRange) { attributes, range, _ in
            for key in attributes.keys {
                if let value = attributes[key] {
                    updatedAttributedText.addAttribute(key, value: value, range: range)
                }
            }
        }

        updatedAttributedText.addAttribute(.paragraphStyle, value: paragraphStyle, range: nsRange)

        let savedDelegate = self.textView.delegate
        self.textView.delegate = nil // Fixes looping cursor range
        let savedSelectedRange = self.textView.selectedRange
        self.textView.attributedText = updatedAttributedText
        self.textView.selectedRange = savedSelectedRange
        self.textView.delegate = savedDelegate // Return rx proxy delegate back again
    }
}

fileprivate extension UITextView {
    func newHeight(withBaseHeight baseHeight: CGFloat, maxLines: Int) -> CGFloat {
        // Calculate the required size of the textview
        let fixedWidth = frame.size.width
        let newSize = sizeThatFits(CGSize(width: fixedWidth, height: .greatestFiniteMagnitude))
        var newFrame = frame

        // Height is always >= the base height, so calculate the possible new height
        let height: CGFloat = newSize.height > baseHeight ? newSize.height : baseHeight
        newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: height)
        return min(maxHeight(for: maxLines), newFrame.height)
    }

    func maxHeight(for lines: Int) -> CGFloat {
        if let font = self.font {
            return font.lineHeight * CGFloat(lines)
        }
        return 0
    }
}
