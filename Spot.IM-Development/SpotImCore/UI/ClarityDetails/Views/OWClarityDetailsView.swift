//
//  OWClarityDetailsView.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 21/08/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import UIKit
import RxCocoa
import RxSwift

class OWClarityDetailsView: UIView {
    fileprivate struct Metrics {
        static let horizontalPadding: CGFloat = 16
        static let verticalPadding: CGFloat = 20
        static let titleTopPadding: CGFloat = 12
        static let spaceBetweenParagraphs: CGFloat = 16
    }

    fileprivate lazy var topParagraphLabel: UILabel = {
        return UILabel()
            .textColor(OWColorPalette.shared.color(type: .textColor3, themeStyle: .light))
            .font(OWFontBook.shared.font(typography: .bodyText))
            .attributedText(viewModel.outputs.topParagraphAttributedString)
            .numberOfLines(0)
    }()

    fileprivate lazy var detailsTitleLabel: UILabel = {
        return UILabel()
            .font(OWFontBook.shared.font(typography: .bodyInteraction))
            .textColor(OWColorPalette.shared.color(type: .textColor3, themeStyle: .light))
            .text(viewModel.outputs.detailsTitleText)
            .numberOfLines(0)
    }()

    fileprivate lazy var paragraphsStackView: UIStackView = {
        let stackView = UIStackView()
            .spacing(Metrics.spaceBetweenParagraphs)
            .axis(.vertical)
        viewModel.outputs.paragraphItems.forEach { paragraph in
            let paragraphView = OWParagraphWithIconView(text: paragraph.text, icon: paragraph.icon ?? UIImage())
            stackView.addArrangedSubview(paragraphView)
        }
        return stackView
    }()

    fileprivate let viewModel: OWClarityDetailsViewModeling
    fileprivate var disposeBag: DisposeBag

    init(viewModel: OWClarityDetailsViewModeling) {
        self.viewModel = viewModel
        self.disposeBag = DisposeBag()
        super.init(frame: .zero)

        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

fileprivate extension OWClarityDetailsView {
    func setupViews() {
        self.addSubview(topParagraphLabel)
        topParagraphLabel.OWSnp.makeConstraints { make in
            make.top.equalToSuperview().inset(Metrics.verticalPadding)
            make.leading.trailing.equalToSuperview().inset(Metrics.horizontalPadding)
        }

        self.addSubview(detailsTitleLabel)
        detailsTitleLabel.OWSnp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(Metrics.horizontalPadding)
            make.top.equalTo(topParagraphLabel.OWSnp.bottom).offset(Metrics.titleTopPadding)
        }

        self.addSubview(paragraphsStackView)
        paragraphsStackView.OWSnp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(Metrics.horizontalPadding)
            make.top.equalTo(detailsTitleLabel.OWSnp.bottom).offset(Metrics.spaceBetweenParagraphs)
        }
    }

    func setupObservers() {
        OWSharedServicesProvider.shared.themeStyleService()
            .style
            .subscribe(onNext: { [weak self] currentStyle in
                guard let self = self else { return }
                self.topParagraphLabel.textColor = OWColorPalette.shared.color(type: .textColor3, themeStyle: currentStyle)
                self.detailsTitleLabel.textColor = OWColorPalette.shared.color(type: .textColor3, themeStyle: currentStyle)
            })
            .disposed(by: disposeBag)

        OWSharedServicesProvider.shared.appLifeCycle()
            .didChangeContentSizeCategory
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.topParagraphLabel.font = OWFontBook.shared.font(typography: .bodyText)
                self.detailsTitleLabel.font = OWFontBook.shared.font(typography: .bodyInteraction)
            })
            .disposed(by: disposeBag)
    }
}
