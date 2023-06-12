//
//  OWCommentingReadOnlyView.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 28/03/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class OWCommentingReadOnlyView: UIView {
    fileprivate struct Metrics {
        static let fontSize: CGFloat = 15
        static let labelLeadingOffset: CGFloat = 4
        static let iconSize: CGFloat = 24
    }

    fileprivate lazy var iconImageView: UIImageView = {
       return UIImageView(image: UIImage(spNamed: "commentingReadOnlyIcon", supportDarkMode: true))
            .enforceSemanticAttribute()
    }()

    fileprivate lazy var label: UILabel = {
       return UILabel()
            .text(OWLocalizationManager.shared.localizedString(key: "Commenting on this article has ended"))
            .textColor(OWColorPalette.shared.color(type: .textColor3, themeStyle: .light))
            .font(OWFontBook.shared.font(style: .medium, size: Metrics.fontSize))
            .enforceSemanticAttribute()
    }()

    fileprivate var viewModel: OWCommentingReadOnlyViewModeling!
    fileprivate var disposeBag = DisposeBag()

    init(with viewModel: OWCommentingReadOnlyViewModeling) {
        super.init(frame: .zero)
        disposeBag = DisposeBag()
        self.viewModel = viewModel
        setupObservers()
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

fileprivate extension OWCommentingReadOnlyView {
    func setupUI() {
        self.enforceSemanticAttribute()
        self.addSubview(iconImageView)
        iconImageView.OWSnp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.centerY.equalToSuperview()
            make.size.equalTo(Metrics.iconSize)
        }

        self.addSubview(label)
        label.OWSnp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.centerY.equalToSuperview()
            make.leading.equalTo(iconImageView.OWSnp.trailing).offset(Metrics.labelLeadingOffset)
        }
    }

    func setupObservers() {
        OWSharedServicesProvider.shared.themeStyleService()
            .style
            .subscribe(onNext: { [weak self] currentStyle in
                guard let self = self else { return }

                self.label.textColor = OWColorPalette.shared.color(type: .textColor3, themeStyle: currentStyle)
                self.iconImageView.image = UIImage(spNamed: "commentingReadOnlyIcon", supportDarkMode: true)
                self.updateCustomUI()
            })
            .disposed(by: disposeBag)
    }

    func updateCustomUI() {
        viewModel.inputs.triggerCustomizeIconImageViewUI.onNext(iconImageView)
        viewModel.inputs.triggerCustomizeTitleLabelUI.onNext(label)
    }
}
