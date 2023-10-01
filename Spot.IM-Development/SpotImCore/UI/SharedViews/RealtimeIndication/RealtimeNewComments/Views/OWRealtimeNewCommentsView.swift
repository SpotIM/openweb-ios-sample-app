//
//  OWRealtimeNewCommentsView.swift
//  SpotImCore
//
//  Created by Revital Pisman on 21/08/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class OWRealtimeNewCommentsView: UIView {
    fileprivate struct Metrics {
        static let horizontalPadding: CGFloat = 10
        static let iconSize: CGFloat = 16

        static let font: UIFont = OWFontBook.shared.font(typography: .footnoteText)
        static let textColor: OWColor.OWType = .textColor3
        static let iconImgaeName: String = "newCommentsArrow"
    }

    fileprivate let viewModel: OWRealtimeNewCommentsViewModeling
    fileprivate let disposeBag = DisposeBag()

    fileprivate lazy var iconImageView: UIImageView = {
        return UIImageView()
            .image(UIImage(spNamed: Metrics.iconImgaeName, supportDarkMode: true)!)
            .wrapContent()
    }()

    fileprivate lazy var titleLabel: UILabel = {
        return UILabel()
            .font(Metrics.font)
            .textColor(OWColorPalette.shared.color(type: Metrics.textColor,
                                                   themeStyle: OWSharedServicesProvider.shared.themeStyleService().currentStyle))
    }()

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(viewModel: OWRealtimeNewCommentsViewModeling) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupUI()
        setupObservers()
    }
}

fileprivate extension OWRealtimeNewCommentsView {
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
                guard let self = self else { return }
                self.iconImageView.image = UIImage(spNamed: Metrics.iconImgaeName, supportDarkMode: true)
                self.titleLabel.textColor = OWColorPalette.shared.color(type: Metrics.textColor,
                                                                              themeStyle: currentStyle)
            })
            .disposed(by: disposeBag)

        OWSharedServicesProvider.shared.appLifeCycle()
            .didChangeContentSizeCategory
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.titleLabel.font = Metrics.font
            })
            .disposed(by: disposeBag)
    }
}

