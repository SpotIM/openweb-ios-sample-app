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
    }

    fileprivate var viewModel: OWOnlineViewingUsersCounterViewModeling!
    fileprivate let disposeBag = DisposeBag()

    fileprivate lazy var imgViewIcon: UIImageView = {
        let img = UIImageView()
            .image(UIImage(spNamed: "onlineViewingUsers", supportDarkMode: false)!)
            .contentMode(.scaleAspectFit)

        return img
    }()

    fileprivate lazy var lblViewersNumber: UILabel = {
        let lbl = UILabel()
            .enforceSemanticAttribute()
            .font(OWFontBook.shared.font(style: .regular, size: Metrics.viewersFontSize))
            .textColor(OWColorPalette.shared.color(type: .textColor2,
                                                   themeStyle: OWSharedServicesProvider.shared.themeStyleService().currentStyle))

        return lbl
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
        self.addSubview(imgViewIcon)
        imgViewIcon.OWSnp.makeConstraints { make in
            make.top.leading.bottom.equalToSuperview()
        }

        self.addSubview(lblViewersNumber)
        lblViewersNumber.OWSnp.makeConstraints { make in
            make.centerY.trailing.equalToSuperview()
            make.leading.equalTo(imgViewIcon.OWSnp.trailing).offset(Metrics.horizontalMargin)
        }
        applyAccessibility()
    }

    private func applyAccessibility() {
        self.accessibilityIdentifier = Metrics.identifier
        imgViewIcon.accessibilityIdentifier = Metrics.imgViewIconIdentifier
        lblViewersNumber.accessibilityIdentifier = Metrics.lblViewersNumberIdentifier
    }

    func setupObservers() {
        viewModel.outputs.viewingCount
            .startWith("1")
            .bind(to: lblViewersNumber.rx.text)
            .disposed(by: disposeBag)

        OWSharedServicesProvider.shared.themeStyleService()
            .style
            .subscribe(onNext: { [weak self] currentStyle in
                guard let self = self else { return }

                self.lblViewersNumber.textColor = OWColorPalette.shared.color(type: .textColor2,
                                                                        themeStyle: currentStyle)
            }).disposed(by: disposeBag)
    }
}

