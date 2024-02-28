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
        static let labelLeadingOffset: CGFloat = 4
        static let iconSize: CGFloat = 24

        static let margins: UIEdgeInsets = UIEdgeInsets(top: 24, left: 0, bottom: 24, right: 0)
        static let identifier = "conversation_commenting_read_only_view_id"
        static let iconIdentifier = "conversation_commenting_read_only_icon_id"
        static let labelIdentifier = "conversation_commenting_read_only_label_id"
    }

    fileprivate lazy var iconImageView: UIImageView = {
       return UIImageView(image: UIImage(spNamed: "commentingReadOnlyIcon", supportDarkMode: true))
            .enforceSemanticAttribute()
    }()

    fileprivate lazy var label: UILabel = {
       return UILabel()
            .text(OWLocalizationManager.shared.localizedString(key: "CommentingReadOnlyMessage"))
            .textColor(OWColorPalette.shared.color(type: .textColor3, themeStyle: .light))
            .font(OWFontBook.shared.font(typography: .bodyContext))
            .numberOfLines(0)
            .enforceSemanticAttribute()
            .wrapContent()
    }()

    fileprivate var viewModel: OWCommentingReadOnlyViewModeling!
    fileprivate var disposeBag = DisposeBag()

    init(with viewModel: OWCommentingReadOnlyViewModeling) {
        super.init(frame: .zero)
        disposeBag = DisposeBag()
        self.viewModel = viewModel
        applyAccessibility()
        setupObservers()
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

fileprivate extension OWCommentingReadOnlyView {
    func applyAccessibility() {
        self.accessibilityIdentifier = Metrics.identifier
        iconImageView.accessibilityIdentifier = Metrics.iconIdentifier
        label.accessibilityIdentifier = Metrics.labelIdentifier
    }

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
            make.top.greaterThanOrEqualToSuperview().offset(Metrics.margins.top)
            make.bottom.greaterThanOrEqualToSuperview().offset(Metrics.margins.bottom)
            make.trailing.equalToSuperview()
            make.centerY.equalTo(iconImageView)
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

        OWSharedServicesProvider.shared.appLifeCycle()
            .didChangeContentSizeCategory
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.label.font = OWFontBook.shared.font(typography: .bodyContext)
            })
            .disposed(by: disposeBag)
    }

    func updateCustomUI() {
        viewModel.inputs.triggerCustomizeIconImageViewUI.onNext(iconImageView)
        viewModel.inputs.triggerCustomizeTitleLabelUI.onNext(label)
    }
}
