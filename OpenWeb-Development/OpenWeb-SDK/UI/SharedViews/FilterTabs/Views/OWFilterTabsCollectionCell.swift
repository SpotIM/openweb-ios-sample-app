//
//  OWFilterTabsCollectionCell.swift
//  OpenWebSDK
//
//  Created by Refael Sommer on 03/06/2024.
//  Copyright © 2024 OpenWeb. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class OWFilterTabsCollectionCell: UICollectionViewCell {
    fileprivate struct Metrics {
        static let margin: CGFloat = 5
        static let height: CGFloat = OWFilterTabsView.FilterTabsMetrics.itemsHeight
        static let accessibilitySurfix = "filter_tabs_collection_cell_id"
    }

    fileprivate lazy var titleLabel: UILabel = {
        let lbl = UILabel()
            .font(OWFontBook.shared.font(typography: .bodyText))
            .textAlignment(.center)
            .numberOfLines(1)
            .adjustsFontSizeToFitWidth(false)
        return lbl
    }()

    fileprivate lazy var mainArea: UIView = {
        let view = UIView()

        view.addSubview(titleLabel)
        titleLabel.OWSnp.makeConstraints { make in
            make.edges.equalToSuperview().inset(Metrics.margin)
        }

        return view
    }()

    fileprivate var disposeBag: DisposeBag!
    fileprivate var viewModel: OWFilterTabsCollectionCellViewModel!

    func configure(with viewModel: OWFilterTabsCollectionCellViewModel) {
        self.viewModel = viewModel
        self.updateAccessibility()
        self.setupObservers()
        titleLabel.text(viewModel.text)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(frame: CGRect) {
        super.init(frame: .zero)
        setupUI()
    }

    override func prepareForReuse() {
        titleLabel.text = ""
    }
}

fileprivate extension OWFilterTabsCollectionCell {
    func setupUI() {
        contentView.addSubview(mainArea)
        mainArea.OWSnp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(Metrics.height)
        }

        titleLabel.OWSnp.makeConstraints { make in
            make.height.equalTo(OWFilterTabsView.FilterTabsMetrics.itemsHeight)
        }
    }

    func updateAccessibility() {
        self.accessibilityIdentifier = "\(viewModel.outputs.accessibilityPrefix)_\(Metrics.accessibilitySurfix)"
    }

    func setupObservers() {
        disposeBag = DisposeBag()

        Observable.combineLatest(viewModel.outputs.isSelected,
                                 OWSharedServicesProvider.shared.themeStyleService().style)
            .subscribe(onNext: { [weak self] isSelected, currentStyle in
                guard let self = self else { return }
                if isSelected {
                    self.mainArea.backgroundColor = OWColorPalette.shared.color(type: .brandColor, themeStyle: currentStyle)
                    self.titleLabel.textColor = OWColorPalette.shared.color(type: .textColor3, themeStyle: .dark)
                } else {
                    self.mainArea.backgroundColor = OWColorPalette.shared.color(type: .borderColor2, themeStyle: currentStyle)
                    self.titleLabel.textColor = OWColorPalette.shared.color(type: .textColor3, themeStyle: currentStyle)
                }
            })
            .disposed(by: disposeBag)
    }
}
