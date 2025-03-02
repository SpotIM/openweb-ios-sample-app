//
//  ToolbarCollectionCell.swift
//  OpenWeb-Development
//
//  Created by Alon Haiut on 27/06/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import UIKit
import Combine
import CombineCocoa

class ToolbarCollectionCell: UICollectionViewCell {
    private struct Metrics {
        static let margin: CGFloat = 5
        static let size: CGFloat = CommentCreationToolbar.ToolbarMetrics.height
        static let accessibilitySurfix = "toolbar_cell_id"
    }

    private lazy var titleLabel: UILabel = {
        let lbl = UILabel()
            .font(FontBook.mainHeadingBold)
            .textAlignment(.center)
            .textColor(.red)
        return lbl
    }()

    private lazy var mainArea: UIView = {
        let view = UIView()

        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(Metrics.margin)
        }

        return view
    }()

    private var cancellables: Set<AnyCancellable> = []
    private var viewModel: ToolbarCollectionCellViewModeling!

    func configure(with viewModel: ToolbarCollectionCellViewModeling) {
        self.viewModel = viewModel
        self.updateAccessibility()
        self.setupObservers()
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

private extension ToolbarCollectionCell {
    func setupUI() {
        contentView.addSubview(mainArea)
        mainArea.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.size.equalTo(Metrics.size)
        }
    }

    func updateAccessibility() {
        self.accessibilityIdentifier = "\(viewModel.outputs.accessibilityPrefix)_\(Metrics.accessibilitySurfix)"
    }

    func setupObservers() {
        cancellables.removeAll()

        viewModel.outputs.emoji
            .map { $0 as String? }
            .assign(to: \.text, on: titleLabel)
            .store(in: &cancellables)
    }
}
