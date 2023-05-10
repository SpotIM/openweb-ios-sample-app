//
//  OWSpacerCell.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 28/12/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

class OWSpacerCell: UITableViewCell {

    fileprivate lazy var spacerView: OWSpacerView = {
        return OWSpacerView()
    }()

    fileprivate var viewModel: OWSpacerCellViewModeling!
    fileprivate var disposeBag = DisposeBag()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func configure(with viewModel: OWCellViewModel) {
        guard let vm = viewModel as? OWSpacerCellViewModel else { return }
        self.disposeBag = DisposeBag()
        self.viewModel = vm

        spacerView.configure(with: self.viewModel.outputs.spacerViewModel)

        self.setupObservers()
    }
}

fileprivate extension OWSpacerCell {
    func setupUI() {
        self.backgroundColor = OWColorPalette.shared.color(type: .backgroundColor2, themeStyle: .light)
        self.selectionStyle = .none

        self.addSubview(spacerView)
        spacerView.OWSnp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    func setupObservers() {
        OWSharedServicesProvider.shared.themeStyleService()
            .style
            .subscribe(onNext: { [weak self] currentStyle in
                guard let self = self else { return }
                self.backgroundColor = OWColorPalette.shared.color(type: .backgroundColor2, themeStyle: currentStyle)
            })
            .disposed(by: disposeBag)
    }
}
