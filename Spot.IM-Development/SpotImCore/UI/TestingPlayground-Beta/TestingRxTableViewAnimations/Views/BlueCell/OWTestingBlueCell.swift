//
//  OWTestingBlueCell.swift
//  SpotImCore
//
//  Created by Alon Haiut on 25/04/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

#if BETA

import UIKit

class OWTestingBlueCell: UITableViewCell {

    fileprivate struct Metrics {
        static let insetForFirstLevel: CGFloat = 5.0
        static let roundCorners: CGFloat = 10.0
        static let padding: CGFloat = 8.0
    }

    fileprivate lazy var firstLevelView: OWTestingBlueFirstLevel = {
        return OWTestingBlueFirstLevel()
    }()

    fileprivate var viewModel: OWTestingBlueCellViewModeling!

    fileprivate lazy var cellContent: UIView = {
        let view = UIView()
            .backgroundColor(.blue)
            .corner(radius: Metrics.roundCorners)

        view.addSubview(firstLevelView)
        firstLevelView.OWSnp.makeConstraints { make in
            make.edges.equalToSuperview().inset(Metrics.insetForFirstLevel)
        }

        return view
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func configure(with viewModel: OWCellViewModel) {
        guard let vm = viewModel as? OWTestingBlueCellViewModeling else { return }
        self.viewModel = vm

        firstLevelView.configure(with: self.viewModel.outputs.firstLevelVM)
    }
}

fileprivate extension OWTestingBlueCell {
    func setupUI() {
        self.backgroundColor = .clear
        self.selectionStyle = .none

        contentView.addSubview(cellContent)
        cellContent.OWSnp.makeConstraints { make in
            make.edges.equalToSuperview().inset(Metrics.padding)
        }
    }
}

#endif
