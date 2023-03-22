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

    fileprivate struct Metrics {
        static let height: CGFloat = 1.0
    }
    fileprivate lazy var seperatorView: UIView = {
       return UIView()
            .backgroundColor(OWColorPalette.shared.color(type: .separatorColor1, themeStyle: .light))
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

        self.viewModel = vm
        disposeBag = DisposeBag()
        setupObservers()
    }
}

fileprivate extension OWSpacerCell {
    func setupUI() {
        self.backgroundColor = .clear
        self.addSubviews(seperatorView)

        seperatorView.OWSnp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(Metrics.height)
        }
    }

    func setupObservers() {
        OWSharedServicesProvider.shared.themeStyleService()
            .style
            .subscribe(onNext: { [weak self] currentStyle in
                guard let self = self else { return }
                self.seperatorView.backgroundColor = OWColorPalette.shared.color(type: .separatorColor1, themeStyle: currentStyle)
            }).disposed(by: disposeBag)
    }
}
