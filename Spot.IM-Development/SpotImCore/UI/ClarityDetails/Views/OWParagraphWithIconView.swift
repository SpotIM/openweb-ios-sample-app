//
//  ParagraphWithIconView.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 21/08/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import UIKit
import RxCocoa
import RxSwift

class OWParagraphWithIconView: UIView {
    fileprivate struct Metrics {
        static let iconSize: CGFloat = 24
        static let textLeadingPadding: CGFloat = 10
    }

    fileprivate let text: String
    fileprivate let icon: UIImage
    fileprivate let disposeBag: DisposeBag

    init(text: String, icon: UIImage) {
        self.text = text
        self.icon = icon
        self.disposeBag = DisposeBag()
        super.init(frame: .zero)

        setupViews()
        setupObservers()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    fileprivate lazy var iconImageView: UIImageView = {
        return UIImageView(image: self.icon)
            .tintAdjustmentMode(.normal)
            .tintColor(OWColorPalette.shared.color(type: .textColor3, themeStyle: .light))
    }()

    fileprivate lazy var textLabel: UILabel = {
        return UILabel()
            .text(self.text)
            .textColor(OWColorPalette.shared.color(type: .textColor3, themeStyle: .light))
            .font(OWFontBook.shared.font(typography: .bodyText))
            .numberOfLines(0)
    }()
}

fileprivate extension OWParagraphWithIconView {
    func setupViews() {
        self.addSubview(iconImageView)
        iconImageView.OWSnp.makeConstraints { make in
            make.size.equalTo(Metrics.iconSize)
            make.leading.centerY.equalToSuperview()
        }

        self.addSubview(textLabel)
        textLabel.OWSnp.makeConstraints { make in
            make.top.bottom.trailing.equalToSuperview()
            make.leading.equalTo(iconImageView.OWSnp.trailing).offset(Metrics.textLeadingPadding)
        }
    }

    func setupObservers() {
        OWSharedServicesProvider.shared.themeStyleService()
            .style
            .subscribe(onNext: { [weak self] currentStyle in
                guard let self = self else { return }
                self.textLabel.textColor = OWColorPalette.shared.color(type: .textColor3, themeStyle: currentStyle)
                self.iconImageView.tintColor = OWColorPalette.shared.color(type: .textColor3, themeStyle: currentStyle)
            })
            .disposed(by: disposeBag)

        OWSharedServicesProvider.shared.appLifeCycle()
            .didChangeContentSizeCategory
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.textLabel.font = OWFontBook.shared.font(typography: .bodyText)
            })
            .disposed(by: disposeBag)
    }
}
