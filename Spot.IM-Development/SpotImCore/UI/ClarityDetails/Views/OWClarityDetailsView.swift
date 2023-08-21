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
    }

    fileprivate lazy var topParagraphLabel: UILabel = {
        return UILabel()
            .textColor(OWColorPalette.shared.color(type: .textColor3, themeStyle: .light))
            .font(OWFontBook.shared.font(typography: .bodyText))
            .attributedText(viewModel.outputs.topParagraphAttributedString)
            .numberOfLines(0)
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
    }

    func setupObservers() {
        OWSharedServicesProvider.shared.themeStyleService()
            .style
            .subscribe(onNext: { [weak self] currentStyle in
                guard let self = self else { return }
                self.topParagraphLabel.textColor = OWColorPalette.shared.color(type: .textColor3, themeStyle: currentStyle)
            })
            .disposed(by: disposeBag)

        OWSharedServicesProvider.shared.appLifeCycle()
            .didChangeContentSizeCategory
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.topParagraphLabel.font = OWFontBook.shared.font(typography: .bodyText)
            })
            .disposed(by: disposeBag)
    }
}
