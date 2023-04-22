//
//  SPOnlineViewingUsersCounterView.swift
//  SpotImCore
//
//  Created by Alon Haiut on 13/12/2021.
//  Copyright © 2021 Spot.IM. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class SPOnlineViewingUsersCounterView: UIView {
    fileprivate struct Metrics {
        static let horizontalMargin: CGFloat = 6
        static let viewersFontSize: CGFloat = 15.0
        static let identifier = "online_viewing_users_counter_id"
        static let imgViewIconIdentifier = "online_viewing_users_img_view_icon_id"
        static let lblViewersNumberIdentifier = "online_viewing_users_lbl_viewers_number_id"
    }

    fileprivate var viewModel: SPOnlineViewingUsersCounterViewModeling!
    fileprivate let disposeBag = DisposeBag()

    fileprivate lazy var imgViewIcon: UIImageView = {
        let img = UIImageView()
            .contentMode(.scaleAspectFit)
            .image(UIImage(spNamed: "viewingUsers", supportDarkMode: false)!)

        return img
    }()

    fileprivate lazy var lblViewersNumber: UILabel = {
        let lbl = UILabel()
            .font(UIFont.preferred(style: .regular, of: Metrics.viewersFontSize))
            .textColor(.spForeground3)

        return lbl
    }()

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
    }

    init() {
        super.init(frame: .zero)
        setupViews()
    }

    init(viewModel: SPOnlineViewingUsersCounterViewModeling) {
        super.init(frame: .zero)
        self.viewModel = viewModel
        setupViews()
        configureViews()
    }

    func configure(with viewModel: SPOnlineViewingUsersCounterViewModeling) {
        self.viewModel = viewModel
        configureViews()
    }
}

fileprivate extension SPOnlineViewingUsersCounterView {
    func setupViews() {
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

    func configureViews() {
        viewModel.outputs.viewingCount
            .startWith("1")
            .bind(to: lblViewersNumber.rx.text)
            .disposed(by: disposeBag)
    }
}

