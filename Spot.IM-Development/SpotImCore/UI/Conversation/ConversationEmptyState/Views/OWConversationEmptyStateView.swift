//
//  OWConversationEmptyStateView.swift
//  SpotImCore
//
//  Created by Revital Pisman on 09/05/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import UIKit
import RxSwift

class OWConversationEmptyStateView: UIView {
    fileprivate struct Metrics {
        static let fontSize: CGFloat = 15
        static let titleLabelTopOffset: CGFloat = 10
        static let iconSize: CGFloat = 48
        static let titleLabelNumberOfLines: Int = 0
    }

    fileprivate lazy var iconImageView: UIImageView = {
       return UIImageView()
            .enforceSemanticAttribute()
    }()

    fileprivate lazy var titleLabel: UILabel = {
       return UILabel()
            .textColor(OWColorPalette.shared.color(type: .textColor3, themeStyle: .light))
            .font(OWFontBook.shared.font(style: .medium, size: Metrics.fontSize))
            .textAlignment(.center)
            .numberOfLines(Metrics.titleLabelNumberOfLines)
            .hugContent(axis: .horizontal)
    }()

    fileprivate lazy var containerView: UIView = { return UIView() }()

    fileprivate var viewModel: OWConversationEmptyStateViewModeling!
    fileprivate var disposeBag = DisposeBag()

    init(viewModel: OWConversationEmptyStateViewModeling) {
        super.init(frame: .zero)
        self.viewModel = viewModel

        setupViews()
        setupObservers()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // Only when using community question as a cell
    func configure(with viewModel: OWConversationEmptyStateViewModeling) {
        self.viewModel = viewModel
        self.disposeBag = DisposeBag()
        self.setupObservers()
    }

    init() {
        super.init(frame: .zero)
        setupViews()
    }
}

fileprivate extension OWConversationEmptyStateView {
    func setupViews() {
        self.enforceSemanticAttribute()

        self.addSubview(containerView)
        containerView.OWSnp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.greaterThanOrEqualToSuperview()
            make.trailing.lessThanOrEqualToSuperview()
        }

        containerView.addSubview(iconImageView)
        iconImageView.OWSnp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.size.equalTo(Metrics.iconSize)
        }

        containerView.addSubview(titleLabel)
        titleLabel.OWSnp.makeConstraints { make in
            make.top.equalTo(iconImageView.OWSnp.bottom).offset(Metrics.titleLabelTopOffset)
            make.leading.trailing.equalToSuperview()
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }

    func setupObservers() {
        viewModel.outputs.text
            .bind(to: titleLabel.rx.text)
            .disposed(by: disposeBag)

        Observable.combineLatest(OWSharedServicesProvider.shared.themeStyleService().style,
                                 viewModel.outputs.iconName)
        .observe(on: MainScheduler.instance)
        .subscribe(onNext: { [weak self] (currentStyle, iconName) -> Void in
            guard let self = self else { return }

            self.titleLabel.textColor = OWColorPalette.shared.color(type: .textColor3, themeStyle: currentStyle)
            self.iconImageView.image = UIImage(spNamed: iconName, supportDarkMode: true)
        })
        .disposed(by: disposeBag)
    }
}
