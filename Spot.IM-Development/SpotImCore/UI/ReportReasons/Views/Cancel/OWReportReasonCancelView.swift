//
//  OWReportReasonCancelView.swift
//  SpotImCore
//
//  Created by Refael Sommer on 24/04/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

class OWReportReasonCancelView: UIView {
    fileprivate struct Metrics {
        static let identifier = "report_reason_cancel_view_id"
        static let titleViewPrefixIdentifier = "report_reason_cancel"
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

    fileprivate let viewModel: OWReportReasonCancelViewViewModeling
    fileprivate let disposeBag = DisposeBag()

    init(viewModel: OWReportReasonCancelViewViewModeling = OWReportReasonCancelViewViewModel()) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupViews()
        setupObservers()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

fileprivate extension OWReportReasonCancelView {
    func setupViews() {
        self.addSubviews(closeButton)
        closeButton.OWSnp.makeConstraints { make in
            make.top.equalToSuperviewSafeArea().offset(Metrics.closeButtonTopSpacing)
            make.trailing.equalToSuperviewSafeArea().inset(Metrics.horizontalSpacing)
        }

        self.addSubviews(titleView)
        titleView.OWSnp.makeConstraints { make in
            make.top.equalTo(closeButton.OWSnp.bottom).offset(Metrics.titleViewTopSpacing)
            make.leading.trailing.equalToSuperviewSafeArea().inset(Metrics.horizontalSpacing)
        }
    }

    func setupObservers() {
        closeButton.rx.tap
            .bind(to: viewModel.inputs.closeReportReasonCancelTap)
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
