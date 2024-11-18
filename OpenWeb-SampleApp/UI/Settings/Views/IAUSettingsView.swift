//
//  IAUSettingsView.swift
//  OpenWeb-Development
//
//  Created by Refael Sommer on 28/02/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import UIKit
import RxSwift

class IAUSettingsView: UIView {

    private struct Metrics {
        static let identifier = "iau_settings_view_id"
        static let horizontalOffset: CGFloat = 10
    }

    private lazy var titleLabel: UILabel = {
        var titleLabel = UILabel()
        titleLabel.text = viewModel.outputs.title
        titleLabel.font = FontBook.secondaryHeadingBold
        return titleLabel
    }()

    private let viewModel: IAUSettingsViewModeling
    private let disposeBag = DisposeBag()

    init(viewModel: IAUSettingsViewModeling) {
        self.viewModel = viewModel
        super.init(frame: CGRect.zero)
        setupViews()
        applyAccessibility()
        setupObservers()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension IAUSettingsView {
    func applyAccessibility() {
        self.accessibilityIdentifier = Metrics.identifier
    }

    func setupViews() {
        self.backgroundColor = ColorPalette.shared.color(type: .background)

        self.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.leading.trailing.equalTo(self).inset(Metrics.horizontalOffset)
            make.top.equalTo(self.snp.top)
        }
    }

    func setupObservers() {
    }
}
