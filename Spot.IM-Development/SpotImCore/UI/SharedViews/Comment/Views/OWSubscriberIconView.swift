//
//  OWSubscriberIconView.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 22/03/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class OWSubscriberIconView: UIView {

    fileprivate struct Metrics {
        static let subscriberBadgeIconSize: CGFloat = 18
        static let identifier = "subscriber_badge_view_id"
    }

    fileprivate var viewModel: OWSubscriberIconViewModeling!
    fileprivate var disposeBag: DisposeBag!

    fileprivate lazy var imgViewIcon: UIImageView = {
        return UIImageView()
            .contentMode(.scaleAspectFit)
            .tintColor(OWColorPalette.shared.color(type: .brandColor, themeStyle: .light))
    }()

    init() {
        super.init(frame: .zero)
        self.accessibilityIdentifier = Metrics.identifier
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with viewModel: OWSubscriberIconViewModeling) {
        self.viewModel = viewModel
        disposeBag = DisposeBag()
        setupObservers()
    }
}

fileprivate extension OWSubscriberIconView {

    func setupViews() {
        self.addSubview(imgViewIcon)

        imgViewIcon.OWSnp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.size.equalTo(Metrics.subscriberBadgeIconSize)
        }
    }

    func setupObservers() {
        viewModel.outputs.isSubscriber
            .map { !$0 } // Reverse
            .bind(to: imgViewIcon.rx.isHidden)
            .disposed(by: disposeBag)

        viewModel.outputs.image
            .map { $0.withRenderingMode(.alwaysTemplate) }
            .bind(to: imgViewIcon.rx.image)
            .disposed(by: disposeBag)
    }
}
