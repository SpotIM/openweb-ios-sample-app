//
//  OWToastActionView.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 20/06/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class OWToastActionView: UIView {
    fileprivate struct Metrics {
        static let identifier = "toast_action_view_id"

        static let iconSize: CGFloat = 14
        static let textSize: CGFloat = 15
        static let iconLeadingPadding: CGFloat = 2
    }

    fileprivate lazy var titleLabel: UILabel = {
        return UILabel()
            .textColor(OWColorPalette.shared.color(type: .textColor5, themeStyle: .light))
            .font(OWFontBook.shared.font(style: .medium, size: Metrics.textSize))
            .text(viewModel.outputs.title)
            // TODO: underline
    }()

    fileprivate lazy var iconImageView: UIImageView = {
        return UIImageView()
            .image(viewModel.outputs.icon)
            .tintColor(OWColorPalette.shared.color(type: .textColor5, themeStyle: .light))
    }()

    fileprivate var viewModel: OWToastActionViewModeling
    fileprivate var disposeBag = DisposeBag()

    init(viewModel: OWToastActionViewModeling) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupViews()
        setupObservers()
        applyIdentifiers()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

fileprivate extension OWToastActionView {
    func setupViews() {
        self.addSubview(titleLabel)
        titleLabel.OWSnp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
        }

        self.addSubview(iconImageView)
        iconImageView.OWSnp.makeConstraints { make in
            make.leading.equalTo(titleLabel.OWSnp.trailing).offset(Metrics.iconLeadingPadding)
            make.top.bottom.trailing.equalToSuperview()
        }
    }

    func setupObservers() {
        OWSharedServicesProvider.shared.themeStyleService()
            .style
            .subscribe(onNext: { [weak self] currentStyle in
                guard let self = self else { return }
                self.titleLabel.textColor = OWColorPalette.shared.color(type: .textColor5, themeStyle: currentStyle)
                self.iconImageView.tintColor = OWColorPalette.shared.color(type: .textColor5, themeStyle: currentStyle)
            })
            .disposed(by: disposeBag)
    }

    func applyIdentifiers() {
        self.accessibilityIdentifier = Metrics.identifier
    }
}
