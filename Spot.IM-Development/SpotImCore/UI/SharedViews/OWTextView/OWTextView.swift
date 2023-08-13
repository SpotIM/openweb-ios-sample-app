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
    }

    let viewModel: OWTextViewViewModeling
    fileprivate let disposeBag = DisposeBag()

    fileprivate lazy var textView: UITextView = {
        let currentStyle = OWSharedServicesProvider.shared.themeStyleService().currentStyle
        return UITextView()
            .font(OWFontBook.shared.font(typography: .bodyText))
            .textColor(OWColorPalette.shared.color(type: .textColor1, themeStyle: currentStyle))
            .tintColor(OWColorPalette.shared.color(type: .brandColor, themeStyle: currentStyle))
            .textContainerInset(.init(top: Metrics.textViewTopBottomPadding,
                                      left: Metrics.textViewLeadingTrailingPadding,
                                      bottom: Metrics.textViewTopBottomPadding,
                                      right: Metrics.textViewLeadingTrailingPadding))
            .enforceSemanticAttribute()
            .spellCheckingType(viewModel.outputs.hasSuggestionsBar ? .default : .no)
            .autocorrectionType(viewModel.outputs.hasSuggestionsBar ? .default : .no)
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
                .textColor(OWColorPalette.shared.color(type: .textColor6, themeStyle: OWSharedServicesProvider.shared.themeStyleService().currentStyle))
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
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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

        if viewModel.outputs.charectersLimitEnabled {
            self.addSubviews(charectersCountLabel)
            charectersCountLabel.OWSnp.makeConstraints { make in
                make.trailing.equalToSuperview().inset(Metrics.charectersTrailingPadding)
                make.bottom.equalToSuperview().inset(Metrics.charectersBottomPadding)
            }
        }

        self.addSubviews(textView)
        textView.OWSnp.makeConstraints { make in
            if viewModel.outputs.charectersLimitEnabled {
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
        }
    }

    func setupObservers() {
        textView.rx.text
            .skip(1)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                if self.viewModel.outputs.charectersLimitEnabled {
                    self.textView.text = String(self.textView.text.prefix(self.viewModel.outputs.textViewMaxCharecters))
                }
                self.viewModel.inputs.textViewCharectersCount.onNext(self.textView.text.count)
                self.charectersCountLabel.text = "\(self.textView.text.count)/" + "\(self.viewModel.outputs.textViewMaxCharecters)"
                self.viewModel.inputs.textViewTextChange.onNext(self.textView.text ?? "")
            })
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
                    .subscribe(onNext: { [weak self] _ in
                        guard let self = self else { return }
                        UIView.animate(withDuration: Metrics.expandAnimationDuration) {
                            self.textView.OWSnp.updateConstraints { make in
                                make.height.equalTo(self.textView.newHeight(withBaseHeight: Metrics.baseTextViewHeight,
                                                                            maxLines: Metrics.maxNumberOfLines)).priority(Metrics.heightConstraintPriority)
                            }
                            self.layoutIfNeeded()
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

        viewModel.outputs.textViewText
            // This delay fixes the textView from flickering when text is inserted
            .delay(.milliseconds(Metrics.delayTextViewTextChange), scheduler: MainScheduler.instance)
            .bind(to: textView.rx.text)
            .disposed(by: disposeBag)

        viewModel.outputs.becomeFirstResponderCalled
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
                self.textViewPlaceholder.textColor = OWColorPalette.shared.color(type: .textColor5, themeStyle: currentStyle)
                self.textView.textColor = OWColorPalette.shared.color(type: .textColor1, themeStyle: currentStyle)
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
