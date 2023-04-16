//
//  OWSpacerView.swift
//  SpotImCore
//
//  Created by Revital Pisman on 16/04/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import UIKit
import RxSwift

class OWSpacerView: UIView {
    fileprivate struct Metrics {
        static let height: CGFloat = 1.0
        static let verticalPadding: CGFloat = 16
        static let horizontalPadding: CGFloat = 12
    }

    fileprivate lazy var seperatorView: UIView = {
       return UIView()
            .backgroundColor(OWColorPalette.shared.color(type: .separatorColor3, themeStyle: .light))
    }()

    fileprivate var viewModel: OWSpacerViewModeling!
    fileprivate var disposeBag = DisposeBag()

    init(with viewModel: OWSpacerViewModeling) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupUI()
        setupObservers()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init() {
        super.init(frame: .zero)
    }

    // Only when using spacer as a cell
    func configure(with viewModel: OWSpacerViewModeling) {
        self.viewModel = viewModel
        self.disposeBag = DisposeBag()
        self.setupUI()
        self.setupObservers()
    }
}

extension OWSpacerView {
    func setupUI() {
        self.backgroundColor = .clear
        self.addSubviews(seperatorView)

        if viewModel.outputs.shouldShowCommentStyle {
            seperatorView.OWSnp.makeConstraints { make in
                make.leading.trailing.equalToSuperview()
                make.top.equalToSuperview().offset(Metrics.verticalPadding)
                make.bottom.equalToSuperview().offset(-Metrics.verticalPadding)
                make.height.equalTo(Metrics.height)
            }
        } else if viewModel.outputs.shouldShowCommunityStyle {
            seperatorView.OWSnp.makeConstraints { make in
                make.leading.equalToSuperview().offset(Metrics.horizontalPadding)
                make.trailing.equalToSuperview().offset(-Metrics.horizontalPadding)
                make.bottom.top.equalToSuperview()
                make.height.equalTo(Metrics.height)
            }
        }
    }

    func setupObservers() {
        OWSharedServicesProvider.shared.themeStyleService()
            .style
            .subscribe(onNext: { [weak self] currentStyle in
                guard let self = self else { return }
                self.seperatorView.backgroundColor = OWColorPalette.shared.color(type: .separatorColor3, themeStyle: currentStyle)
            }).disposed(by: disposeBag)
    }
}
