//
//  OWFilterTabsSkeletonCollectionCell.swift
//  OpenWebSDK
//
//  Created by Refael Sommer on 17/06/2024.
//  Copyright © 2024 OpenWeb. All rights reserved.
//

import UIKit

class OWFilterTabsSkeletonCollectionCell: UICollectionViewCell {
    private struct Metrics {
        static let skeletonCornerRadius: CGFloat = 3
        static let height: CGFloat = OWFilterTabsView.FilterTabsMetrics.itemsHeight
        static let width: CGFloat = OWFilterTabsView.FilterTabsMetrics.skeletonsWidth
        static let accessibilityId = "filter_tabs_skeleton_collection_cell_id"
    }

    private lazy var skeletonContentView: UIView = {
        return UIView()
            .corner(radius: Metrics.skeletonCornerRadius)
            .backgroundColor(OWColorPalette.shared.color(type: .skeletonColor, themeStyle: .light))
    }()

    private lazy var skelatonView: OWSkeletonShimmeringView = {
        let view = OWSkeletonShimmeringView()
        view.enforceSemanticAttribute()
        view.addSubview(skeletonContentView)
        skeletonContentView.OWSnp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.greaterThanOrEqualTo(Metrics.height)
        }
        return view
    }()

    private var viewModel: OWFilterTabsSkeletonCollectionCellVM!

    override func configure(with viewModel: OWCellViewModel) {
        guard let viewModel = viewModel as? OWFilterTabsSkeletonCollectionCellVM else { return }
        self.viewModel = viewModel
        skelatonView.addSkeletonShimmering()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(frame: CGRect) {
        super.init(frame: .zero)
        setupUI()
        applyAccessibility()
    }
}

private extension OWFilterTabsSkeletonCollectionCell {
    func setupUI() {
        contentView.addSubview(skelatonView)
        skelatonView.OWSnp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(Metrics.width)
            make.height.equalTo(Metrics.height)
        }
    }

    func applyAccessibility() {
        self.accessibilityIdentifier = Metrics.accessibilityId
    }
}
