//
//  OWSubscriberIconView.swift
//  OpenWebSDK
//
//  Created by  Nogah Melamed on 22/03/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class OWSubscriberIconView: UIView {

    private struct Metrics {
        static let subscriberBadgeIconSize: CGFloat = 12
        static let identifier = "subscriber_badge_view_id"
        static let imageViewIdentifier = "subscriber_badge_image_view_id"
    }

    private var viewModel: OWSubscriberIconViewModeling!
    private var disposeBag: DisposeBag!

    private lazy var imgViewIcon: UIImageView = {
        return UIImageView()
            .contentMode(.scaleAspectFit)
            .tintColor(OWColorPalette.shared.color(type: .brandColor, themeStyle: .light))
    }()

    init() {
        super.init(frame: .zero)
        setupViews()
        applyAccessibility()
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

private extension OWSubscriberIconView {
    func applyAccessibility() {
        self.accessibilityIdentifier = Metrics.identifier
        imgViewIcon.accessibilityIdentifier = Metrics.imageViewIdentifier
    }

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

        viewModel.outputs.isSubscriber
            .subscribe(onNext: { [weak self] isVisible in
                OWScheduler.runOnMainThreadIfNeeded {
                    guard let self else { return }
                    self.imgViewIcon.OWSnp.updateConstraints { make in
                        make.size.equalTo(isVisible ? Metrics.subscriberBadgeIconSize : 0)
                    }
                }
            })
            .disposed(by: disposeBag)

        viewModel.outputs.image
            .map { $0.withRenderingMode(.alwaysTemplate) }
            .bind(to: imgViewIcon.rx.image)
            .disposed(by: disposeBag)

        OWSharedServicesProvider.shared.themeStyleService()
            .style
            .subscribe(onNext: { [weak self] style in
                guard let self else { return }

                self.imgViewIcon.tintColor = OWColorPalette.shared.color(type: .brandColor, themeStyle: style)
            })
            .disposed(by: disposeBag)
    }
}
