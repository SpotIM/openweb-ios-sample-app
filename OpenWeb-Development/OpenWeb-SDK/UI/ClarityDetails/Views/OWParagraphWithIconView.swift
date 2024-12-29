//
//  ParagraphWithIconView.swift
//  OpenWebSDK
//
//  Created by  Nogah Melamed on 21/08/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import Foundation
import UIKit
import RxCocoa
import RxSwift

class OWParagraphWithIconView: UIView {
    private struct Metrics {
        static let iconSize: CGFloat = 24
        static let textLeadingPadding: CGFloat = 10

        static let identifier = "paragraph_with_icon_view_id"
        static let textLabelIdentifier = "paragraph_with_icon_text_label_id"
    }

    private let disposeBag: DisposeBag
    private let viewModel: OWParagraphWithIconViewModeling

    init(viewModel: OWParagraphWithIconViewModeling) {
        self.viewModel = viewModel
        self.disposeBag = DisposeBag()
        super.init(frame: .zero)

        setupViews()
        setupObservers()
        applyAccessibility()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private lazy var iconImageView: UIImageView = {
        return UIImageView(image: self.viewModel.outputs.icon)
            .tintAdjustmentMode(.normal)
            .tintColor(OWColorPalette.shared.color(type: .textColor3, themeStyle: .light))
    }()

    private lazy var textLabel: UILabel = {
        return UILabel()
            .numberOfLines(0)
            .enforceSemanticAttribute()
    }()
}

private extension OWParagraphWithIconView {
    func setupViews() {
        self.enforceSemanticAttribute()

        self.addSubview(iconImageView)
        iconImageView.OWSnp.makeConstraints { make in
            make.size.equalTo(Metrics.iconSize)
            make.leading.top.equalToSuperview()
        }

        self.addSubview(textLabel)
        textLabel.OWSnp.makeConstraints { make in
            make.top.bottom.trailing.equalToSuperview()
            make.leading.equalTo(iconImageView.OWSnp.trailing).offset(Metrics.textLeadingPadding)
        }
    }

    func setupObservers() {
        viewModel.outputs.attributedString
            .bind(to: textLabel.rx.attributedText)
            .disposed(by: disposeBag)

        viewModel.outputs.attributedString
            .subscribe(onNext: { [weak self] attributedString in
                guard let self else { return }
                self.textLabel
                    .attributedText(attributedString)
                    .addRangeGesture(targetRange: self.viewModel.outputs.communityGuidelinesClickablePlaceholder) { [weak self] in
                        guard let self else { return }
                        self.viewModel.inputs.communityGuidelinesClick.onNext()
                    }
            })
            .disposed(by: disposeBag)

        OWSharedServicesProvider.shared.themeStyleService()
            .style
            .subscribe(onNext: { [weak self] currentStyle in
                guard let self else { return }
                self.iconImageView.tintColor = OWColorPalette.shared.color(type: .textColor3, themeStyle: currentStyle)
            })
            .disposed(by: disposeBag)
    }

    func applyAccessibility() {
        self.accessibilityIdentifier = Metrics.identifier
        textLabel.accessibilityIdentifier = Metrics.textLabelIdentifier
    }
}
