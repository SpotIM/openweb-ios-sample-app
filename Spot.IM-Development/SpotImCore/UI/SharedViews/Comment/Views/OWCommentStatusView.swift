//
//  OWCommentStatusView.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 16/08/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class OWCommentStatusView: UIView {
    fileprivate struct Metrics {
        static let cornerRadius: CGFloat = 4
        static let horizontalPadding: CGFloat = 10
        static let verticalPadding: CGFloat = 8
        static let iconTrailingPadding: CGFloat = 2
        static let iconSize: CGFloat = 20

        static let identifier = "comment_status_view_id"
        static let iconIdentifier = "comment_status_icon_id"
        static let labelIdentifier = "comment_status_label_id"
    }

    fileprivate var viewModel: OWCommentStatusViewModeling!
    fileprivate var disposeBag: DisposeBag!

    fileprivate lazy var iconImageView: UIImageView = {
        return UIImageView()
            .contentMode(.scaleAspectFit)
    }()

    fileprivate lazy var messageLabel: UILabel = {
        return UILabel()
            .numberOfLines(0)
    }()

    init() {
        super.init(frame: .zero)
        setupViews()
        applyAccessibility()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with viewModel: OWCommentStatusViewModeling) {
        self.viewModel = viewModel
        disposeBag = DisposeBag()
        setupObservers()
    }
}

fileprivate extension OWCommentStatusView {
    func applyAccessibility() {
        self.accessibilityIdentifier = Metrics.identifier
        iconImageView.accessibilityIdentifier = Metrics.iconIdentifier
        messageLabel.accessibilityIdentifier = Metrics.labelIdentifier
    }

    func setupViews() {
        self.addCornerRadius(Metrics.cornerRadius)
        self.backgroundColor = OWColorPalette.shared.color(type: .separatorColor3, themeStyle: .light)

        self.addSubview(iconImageView)
        iconImageView.OWSnp.makeConstraints { make in
            make.top.equalToSuperview().inset(Metrics.verticalPadding)
            make.leading.equalToSuperview().inset(Metrics.horizontalPadding)
            make.size.equalTo(Metrics.iconSize)
        }

        self.addSubview(messageLabel)
        messageLabel.OWSnp.makeConstraints { make in
            make.leading.equalTo(iconImageView.OWSnp.trailing).offset(Metrics.iconTrailingPadding)
            make.top.bottom.equalToSuperview().inset(Metrics.verticalPadding)
            make.trailing.equalToSuperview().inset(Metrics.horizontalPadding)
        }
    }

    func setupObservers() {
        viewModel.outputs.iconImage
            .bind(to: iconImageView.rx.image)
            .disposed(by: disposeBag)

        viewModel.outputs.messageAttributedText
            .subscribe(onNext: { [weak self] attributedText in
                guard let self = self else { return }
                self.messageLabel
                    .attributedText(attributedText)
                    .addRangeGesture(targetRange: self.viewModel.outputs.learnMoreClickableString) { [weak self] in
                        guard let self = self else { return }
                        self.viewModel.inputs.learnMoreTap.onNext()
                    }
            })
            .disposed(by: disposeBag)

        OWSharedServicesProvider.shared.themeStyleService()
            .style
            .subscribe(onNext: { [weak self] currentStyle in
                guard let self = self else { return }
                self.backgroundColor = OWColorPalette.shared.color(type: .separatorColor3, themeStyle: currentStyle)
            })
            .disposed(by: disposeBag)
    }
}
