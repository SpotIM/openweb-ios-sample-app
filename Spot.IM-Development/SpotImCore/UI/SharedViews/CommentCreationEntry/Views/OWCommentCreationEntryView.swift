//
//  OWCommentCreationEntryView.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 05/04/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import UIKit

class OWCommentCreationEntryView: UIView {
    fileprivate struct Metrics {
        static let userAvatarSize: CGFloat = 40
        static let containerLeadingOffset: CGFloat = 10
        static let labelInsetVertical: CGFloat = 10
        static let labelInsetHorizontal: CGFloat = 15

        static let margins: UIEdgeInsets = UIEdgeInsets(top: 12, left: 0, bottom: 14, right: 0)

        static let identifier = "comment_creation_entry_id"
        static let labelIdentifier = "comment_creation_entry_label_id"
    }

    fileprivate lazy var userAvatarView: OWAvatarView = {
        let avatarView = OWAvatarView()
        avatarView.backgroundColor = .clear
        return avatarView
    }()

    fileprivate lazy var labelContainer: UIView = {
        return UIView()
            .border(
                width: 1.0,
                color: OWColorPalette.shared.color(type: .borderColor2, themeStyle: .light))
            .corner(radius: 6.0)
            .backgroundColor(OWColorPalette.shared.color(type: .backgroundColor4, themeStyle: .light))
            .userInteractionEnabled(true)
            .enforceSemanticAttribute()
    }()

    fileprivate lazy var label: UILabel = {
        return UILabel()
            .font(OWFontBook.shared.font(typography: .bodyText))
            .text(OWLocalizationManager.shared.localizedString(key: "WhatDoYouThink"))
            .textColor(OWColorPalette.shared.color(type: .textColor2, themeStyle: .light))
            .enforceSemanticAttribute()
    }()

    fileprivate lazy var tapGesture: UITapGestureRecognizer = {
        let tapGesture = UITapGestureRecognizer()
        labelContainer.addGestureRecognizer(tapGesture)
        return tapGesture
    }()

    fileprivate var viewModel: OWCommentCreationEntryViewModeling!
    fileprivate var disposeBag = DisposeBag()

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(with viewModel: OWCommentCreationEntryViewModeling) {
        super.init(frame: .zero)
        disposeBag = DisposeBag()
        self.viewModel = viewModel
        userAvatarView.configure(with: viewModel.outputs.avatarViewVM)
        setupObservers()
        setupUI()
    }

    private func applyAccessibility() {
        self.accessibilityIdentifier = Metrics.identifier
        label.accessibilityIdentifier = Metrics.labelIdentifier
    }
}

fileprivate extension OWCommentCreationEntryView {
    func updateCustomUI() {
        viewModel.inputs.triggerCustomizeTitleLabelUI.onNext(label)
        viewModel.inputs.triggerCustomizeContainerViewUI.onNext(labelContainer)
    }

    func setupUI() {
        applyAccessibility()
        addSubview(userAvatarView)
        userAvatarView.OWSnp.makeConstraints { make in
            make.top.greaterThanOrEqualToSuperview().offset(Metrics.margins.top)
            make.bottom.greaterThanOrEqualToSuperview().offset(Metrics.margins.bottom)
            make.centerY.leading.equalToSuperview()
            make.size.equalTo(Metrics.userAvatarSize)
        }

        addSubview(labelContainer)
        labelContainer.OWSnp.makeConstraints { make in
            make.top.greaterThanOrEqualToSuperview().offset(Metrics.margins.top)
            make.bottom.greaterThanOrEqualToSuperview().offset(-Metrics.margins.bottom)
            make.trailing.equalToSuperview()
            make.leading.equalTo(userAvatarView.OWSnp.trailing).offset(Metrics.containerLeadingOffset)
        }

        labelContainer.addSubview(label)
        label.OWSnp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(Metrics.labelInsetVertical)
            make.leading.trailing.equalToSuperview().inset(Metrics.labelInsetHorizontal)
        }
    }

    func setupObservers() {
        tapGesture.rx.event.voidify()
        .bind(to: viewModel.inputs.tap)
        .disposed(by: disposeBag)

        OWSharedServicesProvider.shared.themeStyleService()
            .style
            .subscribe(onNext: { [weak self] currentStyle in
                guard let self = self else { return }
                self.labelContainer.layer.borderColor = OWColorPalette.shared.color(type: .borderColor2, themeStyle: currentStyle).cgColor
                self.labelContainer.backgroundColor = OWColorPalette.shared.color(type: .backgroundColor4, themeStyle: currentStyle)
                self.label.textColor = OWColorPalette.shared.color(type: .textColor2, themeStyle: currentStyle)
                self.updateCustomUI()
            }).disposed(by: disposeBag)

        OWSharedServicesProvider.shared.appLifeCycle()
            .didChangeContentSizeCategory
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.label.font = OWFontBook.shared.font(typography: .bodyText)
            })
            .disposed(by: disposeBag)
    }
}
