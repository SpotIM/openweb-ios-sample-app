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
    private struct Metrics {
        static let margin: CGFloat = 10
        static let cornerRadius: CGFloat = 3
        static let numberOfLines = 1
        static let height: CGFloat = OWFilterTabsView.FilterTabsMetrics.itemsHeight
        static let accessibilitySurfix = "filter_tabs_collection_cell_id"
    }

    private lazy var titleLabel: UILabel = {
        return UILabel()
            .font(OWFontBook.shared.font(typography: .bodyInteraction))
            .textAlignment(.center)
            .numberOfLines(Metrics.numberOfLines)
            .adjustsFontSizeToFitWidth(false)
            .lineBreakMode(.byClipping)
    }()

    private lazy var mainView: UIView = {
        return UIView()
            .corner(radius: Metrics.cornerRadius)
    }()

    private var disposeBag: DisposeBag!
    private var viewModel: OWFilterTabsCollectionCellViewModel!

    override func configure(with viewModel: OWCellViewModel) {
        guard let viewModel = viewModel as? OWFilterTabsCollectionCellViewModel else { return }
        self.viewModel = viewModel
        updateAccessibility()
        setupObservers()
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
        super.prepareForReuse()
        titleLabel.text = ""
    }
}

private extension OWFilterTabsCollectionCell {
    func setupUI() {
        contentView.addSubview(mainView)
        mainView.OWSnp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.greaterThanOrEqualTo(Metrics.height)
        }

        mainView.addSubview(titleLabel)
        titleLabel.OWSnp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(Metrics.margin)
            make.top.bottom.equalToSuperview()
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
                guard let self else { return }
                if isSelected {
                    self.mainView.backgroundColor = OWColorPalette.shared.color(type: .brandColor, themeStyle: currentStyle)
                    self.titleLabel.textColor = OWColorPalette.shared.color(type: .textColor3, themeStyle: .dark)
                } else {
                    self.mainView.backgroundColor = OWColorPalette.shared.color(type: .borderColor2, themeStyle: currentStyle)
                    self.titleLabel.textColor = OWColorPalette.shared.color(type: .textColor3, themeStyle: currentStyle)
                }
            })
            .disposed(by: disposeBag)
    }
}
