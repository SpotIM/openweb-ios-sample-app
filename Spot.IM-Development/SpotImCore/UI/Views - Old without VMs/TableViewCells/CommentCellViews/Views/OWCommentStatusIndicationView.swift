//
//  OWCommentStatusIndicationView.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 07/04/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

class OWCommentStatusIndicationView: UIView {
    struct Metrics {
        static let iconSize: CGFloat = 14

        static let iconLeadingOffset: CGFloat = 12
        static let iconTopPadding: CGFloat = 14
        static let textVerticalPadding: CGFloat = 12
        static let statusTextHorizontalOffset: CGFloat = 8

        static let identifier = "comment_status_indication_view_id"
    }

    private let iconImageView: UIImageView = {
        return UIImageView()
            .image(UIImage(spNamed: "pendingIcon")!)
    }()

    private let statusTextLabel: UILabel = {
        return UILabel()
            .numberOfLines(0)
            .font(OWFontBook.shared.font(typography: .bodyText))
    }()

    fileprivate var viewModel: OWCommentStatusIndicationViewModeling!
    fileprivate var disposeBag: DisposeBag!

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.accessibilityIdentifier = Metrics.identifier
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func updateColorsAccordingToStyle() {
        statusTextLabel.textColor = .commentStatusIndicatorText
        self.backgroundColor = .commentStatusIndicatorBackground
    }

    func configure(with viewModel: OWCommentStatusIndicationViewModeling) {
        self.viewModel = viewModel
        disposeBag = DisposeBag()
        setupObservers()
    }
}

fileprivate extension OWCommentStatusIndicationView {
    func setupObservers() {
        viewModel.outputs.indicationIcon
            .bind(to: iconImageView.rx.image)
            .disposed(by: disposeBag)

        viewModel.outputs.indicationText
            .bind(to: statusTextLabel.rx.text)
            .disposed(by: disposeBag)

        OWSharedServicesProvider.shared.appLifeCycle()
            .didChangeContentSizeCategory
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.statusTextLabel.font = OWFontBook.shared.font(typography: .bodyText)
            })
            .disposed(by: disposeBag)
    }

    func setupUI() {
        self.addCornerRadius(4)
        self.addSubviews(iconImageView, statusTextLabel)

        iconImageView.OWSnp.makeConstraints { make in
            make.leading.equalToSuperview().offset(Metrics.iconLeadingOffset)
            make.top.equalToSuperview().offset(Metrics.iconTopPadding)
            make.width.height.equalTo(Metrics.iconSize)
        }

        statusTextLabel.OWSnp.makeConstraints { make in
            make.leading.equalTo(iconImageView.OWSnp.trailing).offset(Metrics.statusTextHorizontalOffset)
            make.trailing.equalToSuperview().offset(-Metrics.statusTextHorizontalOffset)
            make.top.equalToSuperview().offset(Metrics.textVerticalPadding)
            make.bottom.equalToSuperview().offset(-Metrics.textVerticalPadding)
        }
    }
}
