//
//  OWOnlineViewingUsersCounterView.swift
//  SpotImCore
//
//  Created by Revital Pisman on 27/03/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class OWOnlineViewingUsersCounterView: UIView {
    fileprivate struct Metrics {
        static let horizontalMargin: CGFloat = 6
        static let viewersFontSize: CGFloat = 13.0
        static let identifier = "online_viewing_users_counter_id"
        static let imgViewIconIdentifier = "online_viewing_users_img_view_icon_id"
        static let lblViewersNumberIdentifier = "online_viewing_users_lbl_viewers_number_id"
        static let iconSize: CGFloat = 16.0
    }

    fileprivate var viewModel: OWOnlineViewingUsersCounterViewModeling!
    fileprivate let disposeBag = DisposeBag()

    fileprivate lazy var iconImageView: UIImageView = {
        return UIImageView()
            .image(UIImage(spNamed: "onlineViewingUsers", supportDarkMode: false)!)
            .contentMode(.scaleAspectFit)
    }()

    fileprivate lazy var counterLabel: UILabel = {
        return UILabel()
            .enforceSemanticAttribute()
            .font(OWFontBook.shared.font(style: .regular, size: Metrics.viewersFontSize))
            .textColor(OWColorPalette.shared.color(type: .textColor2,
                                                   themeStyle: OWSharedServicesProvider.shared.themeStyleService().currentStyle))
    }()

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(viewModel: OWOnlineViewingUsersCounterViewModeling) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupUI()
        setupObservers()
    }
}

fileprivate extension OWOnlineViewingUsersCounterView {
    func setupUI() {
        self.addSubview(iconImageView)
        iconImageView.OWSnp.makeConstraints { make in
            make.top.leading.bottom.equalToSuperview()
            make.size.equalTo(Metrics.iconSize)
        }

        self.addSubview(counterLabel)
        counterLabel.OWSnp.makeConstraints { make in
            make.centerY.trailing.equalToSuperview()
            make.leading.equalTo(iconImageView.OWSnp.trailing).offset(Metrics.horizontalMargin)
        }
        applyAccessibility()
    }

    private func applyAccessibility() {
        self.accessibilityIdentifier = Metrics.identifier
        iconImageView.accessibilityIdentifier = Metrics.imgViewIconIdentifier
        counterLabel.accessibilityIdentifier = Metrics.lblViewersNumberIdentifier
    }

    func setupObservers() {
        viewModel.outputs.viewingCount
            .startWith("1")
            .bind(to: counterLabel.rx.text)
            .disposed(by: disposeBag)

        OWSharedServicesProvider.shared.themeStyleService()
            .style
            .subscribe(onNext: { [weak self] currentStyle in
                guard let self = self else { return }

                self.counterLabel.textColor = OWColorPalette.shared.color(type: .textColor2,
                                                                        themeStyle: currentStyle)
                self.updateCustomUI()
            })
            .disposed(by: disposeBag)
    }

    func updateCustomUI() {
        viewModel.inputs.triggerCustomizeIconImageViewUI.onNext(iconImageView)
        viewModel.inputs.triggerCustomizeCounterLabelUI.onNext(counterLabel)
    }
}

