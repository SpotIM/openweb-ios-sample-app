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
        static let identifier = "_text_view_view_id"
        static let textViewIdentifier = "_textview_id"
        static let placeholderLabelIdentifier = "_placeholder_label_id"
        static let charectersCounterLabelIdentifier = "_charecters_counter_label_id"
        static let cornerRadius: CGFloat = 6
        static let borderWidth: CGFloat = 1
        static let textViewBottomPadding: CGFloat = 16
        static let charectersTrailingPadding: CGFloat = 12
        static let charectersBottomPadding: CGFloat = 8
        static let textViewLeadingTrailingPadding: CGFloat = 5
        static let placeholderLeadingTrailingPadding: CGFloat = textViewLeadingTrailingPadding + 5
        static let textViewTopBottomPadding: CGFloat = 10
        static let textViewFontSize: CGFloat = 15
        static let charectersFontSize: CGFloat = 13
    }

    let viewModel: OWTextViewViewModeling
    fileprivate let disposeBag = DisposeBag()

    fileprivate lazy var textView: UITextView = {
        return UITextView()
                .font(OWFontBook.shared.font(style: .regular, size: Metrics.textViewFontSize))
                .textColor(OWColorPalette.shared.color(type: .textColor1, themeStyle: OWSharedServicesProvider.shared.themeStyleService().currentStyle))
                .tintColor(OWColorPalette.shared.color(type: .brandColor, themeStyle: OWSharedServicesProvider.shared.themeStyleService().currentStyle))
                .textContainerInset(.init(top: Metrics.textViewTopBottomPadding,
                                          left: Metrics.textViewLeadingTrailingPadding,
                                          bottom: Metrics.textViewTopBottomPadding,
                                          right: Metrics.textViewLeadingTrailingPadding))
    }()

    fileprivate lazy var charectersCountView: UILabel = {
        return UILabel()
                .font(OWFontBook.shared.font(style: .regular, size: Metrics.charectersFontSize))
                .textColor(OWColorPalette.shared.color(type: .textColor5, themeStyle: OWSharedServicesProvider.shared.themeStyleService().currentStyle))
                .text("0/" + "\(self.viewModel.outputs.textViewMaxCharecters)")
    }()

    fileprivate lazy var textViewPlaceholder: UILabel = {
        return UILabel()
                .font(OWFontBook.shared.font(style: .regular, size: Metrics.textViewFontSize))
                .textColor(OWColorPalette.shared.color(type: .textColor5, themeStyle: OWSharedServicesProvider.shared.themeStyleService().currentStyle))
                .numberOfLines(0)
    }()

    init(viewModel: OWTextViewViewModeling, prefixIdentifier: String) {
        self.viewModel = viewModel
        super.init(frame: .zero)
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
        self.accessibilityIdentifier = prefixId + Metrics.identifier
        textView.accessibilityIdentifier = prefixId + Metrics.textViewIdentifier
        textViewPlaceholder.accessibilityIdentifier = prefixId + Metrics.placeholderLabelIdentifier
        charectersCountView.accessibilityIdentifier = prefixId + Metrics.charectersCounterLabelIdentifier
    }

    func setupViews() {
        self.layer.cornerRadius = Metrics.cornerRadius
        self.layer.borderWidth = Metrics.borderWidth
        self.layer.borderColor = OWColorPalette.shared.color(type: .brandColor, themeStyle: OWSharedServicesProvider.shared.themeStyleService().currentStyle).cgColor

        if viewModel.outputs.charectersLimitEnabled {
            self.addSubviews(charectersCountView)
            charectersCountView.OWSnp.makeConstraints { make in
                make.trailing.equalToSuperview().inset(Metrics.charectersTrailingPadding)
                make.bottom.equalToSuperview().inset(Metrics.charectersBottomPadding)
            }
        }

        self.addSubviews(textView)
        textView.OWSnp.makeConstraints { make in
            if viewModel.outputs.charectersLimitEnabled {
                make.top.leading.trailing.equalToSuperview()
                make.bottom.equalTo(charectersCountView.OWSnp.top)
            } else {
                make.edges.equalToSuperview()
            }
        }

        self.addSubviews(textViewPlaceholder)
        textViewPlaceholder.OWSnp.makeConstraints { make in
            make.leading.equalTo(textView.OWSnp.leading).inset(Metrics.placeholderLeadingTrailingPadding)
            make.trailing.equalTo(textView.OWSnp.trailing).inset(Metrics.placeholderLeadingTrailingPadding)
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
                self.charectersCountView.text = "\(self.textView.text.count)/" + "\(self.viewModel.outputs.textViewMaxCharecters)"
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

        if !viewModel.outputs.isEditable {
            textView.rx.didBeginEditing
                .bind(to: viewModel.inputs.textViewTap)
                .disposed(by: disposeBag)

            textView.rx.didBeginEditing
                .delay(.microseconds(1), scheduler: MainScheduler.asyncInstance)
                .subscribe(onNext: { [weak self] in
                    guard let self = self else { return }
                    self.textView.resignFirstResponder()
                })
                .disposed(by: disposeBag)
        }

        viewModel.outputs.textViewText
            .bind(to: textView.rx.text)
            .disposed(by: disposeBag)

        viewModel.outputs.becomeFirstResponderCalled
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.textView.becomeFirstResponder()
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
    }
}
