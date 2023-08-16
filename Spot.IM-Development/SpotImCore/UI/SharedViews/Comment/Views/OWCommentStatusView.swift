//
//  OWCommentStatusView.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 16/08/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class OWCommentStatusView: UIView {
    fileprivate struct Metrics {
        static let cornerRadius: CGFloat = 4
        static let horizontalPadding: CGFloat = 10
        static let verticalPadding: CGFloat = 8
        static let identifier = "comment_status_view_id"
    }
    
    fileprivate var viewModel: OWCommentStatusViewModeling!
    fileprivate var disposeBag: DisposeBag!

    fileprivate lazy var iconImageView: UIImageView = {
        return UIImageView()
            .contentMode(.scaleAspectFit)
    }()

    init() {
        super.init(frame: .zero)
        setupViews()
        applyAccessibility()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with viewModel: OWCommentStatusViewModeling) {
        self.viewModel = viewModel
        disposeBag = DisposeBag()
        setupObservers()
    }
}

fileprivate extension OWCommentStatusView {
    func applyAccessibility() {
        self.accessibilityIdentifier = Metrics.identifier
    }

    func setupViews() {
        self.addCornerRadius(4)
        self.backgroundColor = OWColorPalette.shared.color(type: .separatorColor3, themeStyle: .light)

        self.addSubview(iconImageView)
        iconImageView.OWSnp.makeConstraints { make in
            make.top.equalToSuperview().inset(Metrics.verticalPadding)
            make.leading.equalToSuperview().inset(Metrics.horizontalPadding)
        }
    }

    func setupObservers() {
        OWSharedServicesProvider.shared.themeStyleService()
            .style
            .subscribe(onNext: { [weak self] currentStyle in
                guard let self = self else { return }
                self.backgroundColor = OWColorPalette.shared.color(type: .separatorColor3, themeStyle: currentStyle)
            })
            .disposed(by: disposeBag)
    }
}
