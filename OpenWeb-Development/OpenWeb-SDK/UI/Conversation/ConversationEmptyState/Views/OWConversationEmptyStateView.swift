//
//  OWConversationEmptyStateView.swift
//  OpenWebSDK
//
//  Created by Revital Pisman on 09/05/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import UIKit
import RxSwift

class OWConversationEmptyStateView: UIView {
    private struct Metrics {
        static let titleLabelTopOffset: CGFloat = 10
        static let iconSize: CGFloat = 48
        static let titleLabelNumberOfLines: Int = 0
        static let margins: UIEdgeInsets = UIEdgeInsets(top: 60, left: 6, bottom: 60, right: 6)

        static let identifier = "empty_state_view_id"
        static let titleIdentifier = "empty_state_view_title_id"
    }

    private lazy var iconImageView: UIImageView = {
       return UIImageView()
            .enforceSemanticAttribute()
    }()

    private lazy var titleLabel: UILabel = {
       return UILabel()
            .textColor(OWColorPalette.shared.color(type: .textColor3, themeStyle: .light))
            .font(OWFontBook.shared.font(typography: .bodyText))
            .textAlignment(.center)
            .numberOfLines(Metrics.titleLabelNumberOfLines)
            .hugContent(axis: .horizontal)
    }()

    private lazy var containerView: UIView = { return UIView() }()
    private var heightConstraint: OWConstraint?

    private var viewModel: OWConversationEmptyStateViewModeling!
    private var disposeBag = DisposeBag()

    init(viewModel: OWConversationEmptyStateViewModeling) {
        super.init(frame: .zero)
        self.viewModel = viewModel

        setupViews()
        applyAccessibility()
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
        applyAccessibility()
    }
}

private extension OWConversationEmptyStateView {
    func setupViews() {
        self.enforceSemanticAttribute()

        self.addSubview(containerView)
        containerView.OWSnp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.greaterThanOrEqualToSuperview().offset(Metrics.margins.left)
            make.trailing.lessThanOrEqualToSuperview().offset(Metrics.margins.right)
            make.top.greaterThanOrEqualToSuperview().offset(Metrics.margins.top)
            make.bottom.lessThanOrEqualToSuperview().offset(Metrics.margins.bottom)
        }

        containerView.addSubview(iconImageView)
        iconImageView.OWSnp.makeConstraints { make in
            make.top.greaterThanOrEqualToSuperview()
            make.centerX.equalToSuperview()
            make.size.equalTo(Metrics.iconSize)
        }

        containerView.addSubview(titleLabel)
        titleLabel.OWSnp.makeConstraints { make in
            make.top.equalTo(iconImageView.OWSnp.bottom).offset(Metrics.titleLabelTopOffset)
            make.leading.trailing.equalToSuperview()
            make.centerX.equalToSuperview()
            make.bottom.lessThanOrEqualToSuperview()
        }
    }

    func applyAccessibility() {
        self.accessibilityIdentifier = Metrics.identifier
        titleLabel.accessibilityIdentifier = Metrics.titleIdentifier
    }

    func setupObservers() {
        viewModel.outputs.text
            .bind(to: titleLabel.rx.text)
            .disposed(by: disposeBag)

        Observable.combineLatest(OWSharedServicesProvider.shared.themeStyleService().style,
                                 viewModel.outputs.iconName)
        .observe(on: MainScheduler.instance)
        .subscribe(onNext: { [weak self] currentStyle, iconName in
            guard let self = self else { return }

            self.titleLabel.textColor = OWColorPalette.shared.color(type: .textColor3, themeStyle: currentStyle)
            self.iconImageView.image = UIImage(spNamed: iconName, supportDarkMode: true)
            self.updateCustomUI()
        })
        .disposed(by: disposeBag)

        OWSharedServicesProvider.shared.appLifeCycle()
            .didChangeContentSizeCategory
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.titleLabel.font = OWFontBook.shared.font(typography: .bodyText)
            })
            .disposed(by: disposeBag)

        viewModel.outputs.iconIdentifier
            .bind(to: iconImageView.rx.accessibilityIdentifier)
            .disposed(by: disposeBag)
    }

    func updateCustomUI() {
        viewModel.inputs.triggerCustomizeIconImageViewUI.onNext(iconImageView)
        viewModel.inputs.triggerCustomizeTitleLabelUI.onNext(titleLabel)
    }
}
