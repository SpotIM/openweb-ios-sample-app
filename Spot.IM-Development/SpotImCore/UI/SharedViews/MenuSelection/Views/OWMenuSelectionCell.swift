//
//  OWMenuSelectionCell.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 07/06/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

class OWMenuSelectionCell: UITableViewCell {

    fileprivate struct Metrics {
        static let textSize: CGFloat = 15
        static let verticalPadding: CGFloat = 12
        static let horizontalPadding: CGFloat = 4
    }

    fileprivate lazy var label: UILabel = {
        return UILabel()
            .font(OWFontBook.shared.font(style: .regular, size: Metrics.textSize))
            .textColor(OWColorPalette.shared.color(type: .textColor5, themeStyle: .light))
    }()

    fileprivate var viewModel: OWMenuSelectionCellViewModeling!
    fileprivate var disposeBag = DisposeBag()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with viewModel: OWMenuSelectionCellViewModeling) {
        self.disposeBag = DisposeBag()
        self.viewModel = viewModel

        self.setupObservers()
        self.applyAccessibility()
    }
}

fileprivate extension OWMenuSelectionCell {
    func setupUI() {
        self.backgroundColor = UIColor.clear

        self.addSubview(label)
        label.OWSnp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(Metrics.horizontalPadding)
            make.top.bottom.equalToSuperview().inset(Metrics.verticalPadding)
        }
    }

    func setupObservers() {
        viewModel.outputs.titleText
            .bind(to: label.rx.text)
            .disposed(by: disposeBag)

        OWSharedServicesProvider.shared.themeStyleService()
            .style
            .subscribe(onNext: { [weak self] currentStyle in
                guard let self = self else { return }
                self.label.textColor = OWColorPalette.shared.color(type: .textColor5, themeStyle: currentStyle)
            })
            .disposed(by: disposeBag)
    }

    func applyAccessibility() {
        // TODO:
    }
}
