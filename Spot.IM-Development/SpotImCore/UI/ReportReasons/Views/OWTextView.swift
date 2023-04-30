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
        static let cornerRadius: CGFloat = 6
        static let borderWidth: CGFloat = 1
        static let charectersTrailingPadding: CGFloat = 12
        static let charectersBottomPadding: CGFloat = 8
        static let placeholderLeadingPadding: CGFloat = 5
        static let placeholderTopPadding: CGFloat = 9
    }

    let viewModel: OWTextViewViewModeling
    fileprivate let disposeBag = DisposeBag()

    fileprivate lazy var textView: UITextView = {
        return UITextView()
                .font(OWFontBook.shared.font(style: .regular, size: 15))
                .textColor(OWColorPalette.shared.color(type: .textColor1, themeStyle: OWSharedServicesProvider.shared.themeStyleService().currentStyle))
                .tintColor(OWColorPalette.shared.color(type: .brandColor, themeStyle: OWSharedServicesProvider.shared.themeStyleService().currentStyle))
    }()

    fileprivate lazy var charectersCountView: UILabel = {
        return UILabel()
                .font(OWFontBook.shared.font(style: .regular, size: 13))
                .textColor(OWColorPalette.shared.color(type: .textColor5, themeStyle: OWSharedServicesProvider.shared.themeStyleService().currentStyle))
                .text("0/" + "\(self.viewModel.outputs.textViewMaxCharecters)")
    }()

    fileprivate lazy var textViewPlaceholder: UILabel = {
        return UILabel()
                .font(OWFontBook.shared.font(style: .regular, size: 15))
                .textColor(OWColorPalette.shared.color(type: .textColor5, themeStyle: OWSharedServicesProvider.shared.themeStyleService().currentStyle))
    }()

    init(viewModel: OWTextViewViewModeling) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupViews()
        setupObservers()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

fileprivate extension OWTextView {
    func setupViews() {
        self.layer.cornerRadius = Metrics.cornerRadius
        self.layer.borderWidth = Metrics.borderWidth
        self.layer.borderColor = OWColorPalette.shared.color(type: .brandColor, themeStyle: OWSharedServicesProvider.shared.themeStyleService().currentStyle).cgColor

        self.addSubviews(textView)
        textView.OWSnp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        if viewModel.outputs.isEditable {
            self.addSubviews(charectersCountView)
            charectersCountView.OWSnp.makeConstraints { make in
                make.trailing.equalTo(textView.OWSnp.trailing).inset(Metrics.charectersTrailingPadding)
                make.bottom.equalTo(textView.OWSnp.bottom).inset(Metrics.charectersBottomPadding)
            }
        }

        self.addSubviews(textViewPlaceholder)
        textViewPlaceholder.OWSnp.makeConstraints { make in
            make.leading.equalTo(textView.OWSnp.leading).inset(Metrics.placeholderLeadingPadding)
            make.top.equalTo(textView.OWSnp.top).inset(Metrics.placeholderTopPadding)
        }
    }

    func setupObservers() {
        textView.rx.text
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.textView.text = String(self.textView.text.prefix(self.viewModel.outputs.textViewMaxCharecters))
                self.viewModel.inputs.textViewCharectersCount.onNext(self.textView.text.count)
                self.charectersCountView.text = "\(self.textView.text.count)/" + "\(self.viewModel.outputs.textViewMaxCharecters)"
            })
            .disposed(by: disposeBag)

        viewModel.outputs.placeholderText
            .subscribe { [weak self] placeholderText in
                guard let self = self else { return }
                self.textViewPlaceholder.text = placeholderText
            }
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
