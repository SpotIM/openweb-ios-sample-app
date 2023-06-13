//
//  OWMenuSelection.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 07/06/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class OWMenuSelection: UIView, OWThemeStyleInjectorProtocol {
    fileprivate struct Metrics {
        static let identifier = "menu_selection_view_id"

        static let menuWidth: CGFloat = 180
        static let cornerRadius: CGFloat = 6
        static let tableInset: CGFloat = 8
    }

    fileprivate lazy var tableView: UITableView = {
        let tableView = UITableView()
            .enforceSemanticAttribute()
            .backgroundColor(UIColor.clear)
            .separatorStyle(.singleLine)
            .separatorColor(OWColorPalette.shared.color(type: .borderColor2, themeStyle: .light))

        tableView.isScrollEnabled = false
        tableView.allowsSelection = true

        tableView.register(cellClass: OWMenuSelectionCell.self)

        return tableView
    }()

    fileprivate var viewModel: OWMenuSelectionViewModeling
    fileprivate var disposeBag: DisposeBag = DisposeBag()

    init(viewModel: OWMenuSelectionViewModeling) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupViews()
        setupObservers()
        applyIdentifiers()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

fileprivate extension OWMenuSelection {
    func setupViews() {
        self.backgroundColor = OWColorPalette.shared.color(type: .backgroundColor4, themeStyle: .light) // TODO: background color
        self.layer.borderWidth = 1
        self.layer.borderColor = OWColorPalette.shared.color(type: .borderColor2, themeStyle: .light).cgColor
        self.layer.cornerRadius = Metrics.cornerRadius

        applyShadow()
        self.useAsThemeStyleInjector()

        self.OWSnp.makeConstraints { make in
            make.width.equalTo(Metrics.menuWidth)
        }

        self.addSubview(tableView)
        self.tableView.OWSnp.makeConstraints { make in
            make.edges.equalToSuperview().inset(Metrics.tableInset)
            make.height.equalTo(0)
        }

    }

    func applyShadow() {
        layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.07).cgColor
        layer.shadowRadius = 20
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowOpacity = 1
        layer.masksToBounds = false
    }

    func setupObservers() {

        viewModel.outputs.cellsViewModels
            .bind(to: tableView.rx.items(cellIdentifier: OWMenuSelectionCell.identifierName,
                                         cellType: OWMenuSelectionCell.self)) { [weak self] index, viewModel, cell in
                guard let self = self else { return }
                cell.configure(with: viewModel)
                if index == self.tableView.numberOfRows(inSection: 0) - 1 {
                    // Hide separator for the last cell
                    cell.separatorInset = UIEdgeInsets(top: 0, left: self.tableView.bounds.size.width, bottom: 0, right: 0)
                } else {
                    // Show separator for other cells
                    cell.separatorInset = UIEdgeInsets.zero
                }
            }
            .disposed(by: disposeBag)

        tableView.rx.observe(CGSize.self, #keyPath(UITableView.contentSize))
            .unwrap()
            .subscribe(onNext: { [weak self] height in
                guard let self = self else { return }
                self.tableView.OWSnp.updateConstraints { make in
                    make.height.equalTo(height)
                }
            })
            .disposed(by: disposeBag)

        OWSharedServicesProvider.shared.themeStyleService()
            .style
            .subscribe(onNext: { [weak self] currentStyle in
                guard let self = self else { return }
                self.backgroundColor = OWColorPalette.shared.color(type: .backgroundColor4, themeStyle: currentStyle) // TODO: background color
                self.tableView.separatorColor = OWColorPalette.shared.color(type: .borderColor2, themeStyle: currentStyle)
                self.layer.borderColor = OWColorPalette.shared.color(type: .borderColor2, themeStyle: currentStyle).cgColor
            })
            .disposed(by: disposeBag)
    }

    func applyIdentifiers() {
        self.accessibilityIdentifier = Metrics.identifier
    }
}
