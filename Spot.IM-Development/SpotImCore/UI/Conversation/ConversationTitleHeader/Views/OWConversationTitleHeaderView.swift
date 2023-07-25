//
//  OWConversationTitleHeaderView.swift
//  SpotImCore
//
//  Created by Revital Pisman on 21/03/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class OWConversationTitleHeaderView: UIView {
    fileprivate struct Metrics {
        static let verticalOffset: CGFloat = 16
        static let closeButtonTopBottomPadding = 7
    }

    fileprivate lazy var titleLabel: UILabel = {
        return UILabel()
            .enforceSemanticAttribute()
            .font(OWFontBook.shared.font(typography: .titleSmall))
            .textColor(OWColorPalette.shared.color(type: .textColor1, themeStyle: OWSharedServicesProvider.shared.themeStyleService().currentStyle))
            .text(OWLocalizationManager.shared.localizedString(key: "Conversation"))
    }()

    fileprivate lazy var closeButton: UIButton = {
        return UIButton()
            .image(UIImage(spNamed: "closeButton", supportDarkMode: true), state: .normal)
    }()

    fileprivate var viewModel: OWConversationTitleHeaderViewModeling
    fileprivate let disposeBag = DisposeBag()

    init(viewModel: OWConversationTitleHeaderViewModeling) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupUI()
        setupObservers()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

fileprivate extension OWConversationTitleHeaderView {
    func setupUI() {
        self.addSubview(titleLabel)
        titleLabel.OWSnp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.equalToSuperview().offset(Metrics.verticalOffset)
        }

        self.addSubview(closeButton)
        closeButton.OWSnp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(Metrics.closeButtonTopBottomPadding)
            make.trailing.equalToSuperview().offset(-Metrics.verticalOffset)
            make.leading.greaterThanOrEqualTo(titleLabel).offset(Metrics.verticalOffset)
        }
    }

    func setupObservers() {
        closeButton.rx.tap
            .bind(to: viewModel.inputs.closeTapped)
            .disposed(by: disposeBag)

        OWSharedServicesProvider.shared.themeStyleService()
            .style
            .subscribe(onNext: { [weak self] currentStyle in
                guard let self = self else { return }

                self.titleLabel.textColor = OWColorPalette.shared.color(type: .textColor1, themeStyle: currentStyle)
                self.closeButton.setImage(UIImage(spNamed: "closeButton", supportDarkMode: true), for: .normal)
                self.updateCustomUI()
            })
            .disposed(by: disposeBag)
    }

    func updateCustomUI() {
        viewModel.inputs.triggerCustomizeTitleLabelUI.onNext(titleLabel)
        viewModel.inputs.triggerCustomizeCloseButtonUI.onNext(closeButton)
    }
}
