//
//  OWRealtimeNewCommentsView.swift
//  OpenWebSDK
//
//  Created by Revital Pisman on 21/08/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class OWRealtimeNewCommentsView: UIView {
    private struct Metrics {
        static let horizontalPadding: CGFloat = 10
        static let iconSize: CGFloat = 16

        static let textColor: OWColor.OWType = .textColor3
        static let iconImgaeName: String = "newCommentsArrow"

        static let identifier = "realtime_new_comment_view_id"
        static let iconImageViewIdentifier = "realtime_new_comment_arrow_icon_id"
        static let titleLabelIdentifier = "realtime_new_comment_title_label_id"
    }

    private let viewModel: OWRealtimeNewCommentsViewModeling
    private let disposeBag = DisposeBag()

    private lazy var iconImageView: UIImageView = {
        return UIImageView()
            .image(UIImage(spNamed: Metrics.iconImgaeName, supportDarkMode: true)!)
            .wrapContent()
    }()

    private lazy var titleLabel: UILabel = {
        return UILabel()
            .font(font)
            .textColor(OWColorPalette.shared.color(type: Metrics.textColor,
                                                   themeStyle: OWSharedServicesProvider.shared.themeStyleService().currentStyle))
    }()

    private var font: UIFont {
        return OWFontBook.shared.font(typography: .footnoteText)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(viewModel: OWRealtimeNewCommentsViewModeling) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupUI()
        setupObservers()
        applyAccessibility()
    }
}

private extension OWRealtimeNewCommentsView {
    func setupUI() {
        self.addSubview(iconImageView)
        iconImageView.OWSnp.makeConstraints { make in
            make.leading.centerY.equalToSuperview()
            make.size.equalTo(Metrics.iconSize)
        }

        self.addSubview(titleLabel)
        titleLabel.OWSnp.makeConstraints { make in
            make.top.bottom.trailing.equalToSuperview()
            make.leading.equalTo(iconImageView.OWSnp.trailing).offset(Metrics.horizontalPadding)
        }
    }

    func setupObservers() {
        viewModel.outputs.newCommentsText
            .bind(to: titleLabel.rx.text)
            .disposed(by: disposeBag)

        OWSharedServicesProvider.shared.themeStyleService()
            .style
            .subscribe(onNext: { [weak self] currentStyle in
                guard let self else { return }
                self.iconImageView.image = UIImage(spNamed: Metrics.iconImgaeName, supportDarkMode: true)
                self.titleLabel.textColor = OWColorPalette.shared.color(type: Metrics.textColor,
                                                                              themeStyle: currentStyle)
            })
            .disposed(by: disposeBag)

        OWSharedServicesProvider.shared.appLifeCycle()
            .didChangeContentSizeCategory
            .subscribe(onNext: { [weak self] _ in
                guard let self else { return }
                self.titleLabel.font = self.font
            })
            .disposed(by: disposeBag)
    }

    func applyAccessibility() {
        self.accessibilityIdentifier = Metrics.identifier
        iconImageView.accessibilityIdentifier = Metrics.iconImageViewIdentifier
        titleLabel.accessibilityIdentifier = Metrics.titleLabelIdentifier
    }
}
