//
//  OWUserMentionLoadingCell.swift
//  OpenWebSDK
//
//  Created by Refael Sommer on 18/04/2024.
//  Copyright © 2024 OpenWeb. All rights reserved.
//

import UIKit
import Foundation
import RxSwift

class OWUserMentionLoadingCell: UITableViewCell {
    private struct Metrics {
        static let identifier = "loading_cell_id"
        static let indicatorIdentifier = "loading_cell_indicator_id"
        static let indicatorHorizontalPadding: CGFloat = 20
        static let titleHorizontalPadding: CGFloat = 8
    }

    private var viewModel: OWUserMentionLoadingCellViewModeling!
    private var disposeBag: DisposeBag!

    private lazy var indicator: UIActivityIndicatorView = {
        return UIActivityIndicatorView()
    }()

    private lazy var titleLabel: UILabel = {
        return UILabel()
            .font(OWFontBook.shared.font(typography: .bodyText))
            .textColor(OWColorPalette.shared.color(type: .textColor2, themeStyle: OWSharedServicesProvider.shared.themeStyleService().currentStyle))
            .text(OWLocalizationManager.shared.localizedString(key: "Loading") + "...")
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        applyAccessibility()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
        applyAccessibility()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = nil
    }

    override func configure(with viewModel: OWCellViewModel) {
        guard let vm = viewModel as? OWUserMentionLoadingCellViewModel else { return }
        self.viewModel = vm
        indicator.startAnimating()
        setupObservers()
    }
}

private extension OWUserMentionLoadingCell {
    func setupViews() {
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
        self.contentView.addSubview(indicator)
        self.contentView.addSubview(titleLabel)
        indicator.OWSnp.makeConstraints { make in
            make.leading.equalToSuperviewSafeArea().offset(Metrics.indicatorHorizontalPadding)
            make.centerY.equalToSuperview()
        }
        titleLabel.OWSnp.makeConstraints { make in
            make.leading.equalTo(indicator.OWSnp.trailing).offset(Metrics.titleHorizontalPadding)
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperviewSafeArea().inset(Metrics.titleHorizontalPadding)
        }
    }

    func setupObservers() {
        disposeBag = DisposeBag()

        OWSharedServicesProvider.shared.themeStyleService()
            .style
            .subscribe(onNext: { [weak self] currentStyle in
                guard let self = self else { return }
                self.titleLabel.textColor = OWColorPalette.shared.color(type: .textColor1, themeStyle: currentStyle)

            })
            .disposed(by: disposeBag)
    }

    func applyAccessibility() {
        self.accessibilityIdentifier = Metrics.identifier
        indicator.accessibilityIdentifier = Metrics.indicatorIdentifier
    }
}
