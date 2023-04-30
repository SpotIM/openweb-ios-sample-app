//
//  OWReportReasonThanksView.swift
//  SpotImCore
//
//  Created by Refael Sommer on 27/04/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

class OWReportReasonThanksView: UIView {
    fileprivate struct Metrics {
        static let identifier = "report_reason_thanks_view_id"
        static let titleViewPrefixIdentifier = "report_reason_thanks_view"
        static let closeButtonTopSpacing: CGFloat = 18
        static let horizontalSpacing: CGFloat = 16
        static let titleViewTopSpacing: CGFloat = 20
    }

    fileprivate lazy var closeButton: UIButton = {
        return UIButton()
            .image(UIImage(spNamed: "closeCrossIcon", supportDarkMode: true), state: .normal)
            .horizontalAlignment(.left)
    }()

    fileprivate lazy var titleView: OWTitleSubtitleIconView = {
        return OWTitleSubtitleIconView(iconName: viewModel.outputs.titleIconName,
                                       title: viewModel.outputs.title,
                                       subtitle: viewModel.outputs.subtitle,
                                       accessibilityPrefixId: Metrics.titleViewPrefixIdentifier)
    }()

    fileprivate let viewModel: OWReportReasonThanksViewViewModeling
    fileprivate let disposeBag = DisposeBag()

    init(viewModel: OWReportReasonThanksViewViewModeling = OWReportReasonThanksViewViewModel()) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupViews()
        setupObservers()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

fileprivate extension OWReportReasonThanksView {
    func setupViews() {
        self.addSubviews(closeButton)
        closeButton.OWSnp.makeConstraints { make in
            make.top.equalToSuperViewSafeArea().offset(Metrics.closeButtonTopSpacing)
            make.trailing.equalToSuperview().inset(Metrics.horizontalSpacing)
        }

        self.addSubviews(titleView)
        titleView.OWSnp.makeConstraints { make in
            make.top.equalTo(closeButton.OWSnp.bottom).offset(Metrics.titleViewTopSpacing)
            make.leading.trailing.equalToSuperview().inset(Metrics.horizontalSpacing)
        }
    }

    func setupObservers() {
        closeButton.rx.tap
            .bind(to: viewModel.inputs.closeReportReasonThanksTap)
            .disposed(by: disposeBag)

        OWSharedServicesProvider.shared.themeStyleService()
            .style
            .subscribe(onNext: { [weak self] currentStyle in
                guard let self = self else { return }
                self.backgroundColor = OWColorPalette.shared.color(type: .backgroundColor2, themeStyle: currentStyle)
                self.closeButton.image(UIImage(spNamed: "closeCrossIcon", supportDarkMode: true), state: .normal)
            })
            .disposed(by: disposeBag)
    }
}
