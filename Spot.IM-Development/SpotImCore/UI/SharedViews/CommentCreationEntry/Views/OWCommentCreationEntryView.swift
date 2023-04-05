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
        static let labelInsetVertical: CGFloat = 12
        static let labelInsetHorizontal: CGFloat = 15
        static let fontSize: CGFloat = 15
        static let identifier = "comment_creation_entry_id"
        static let labelIdentifier = "comment_creation_entry_label_id"
    }

    fileprivate lazy var userAvatarView: SPAvatarView = {
        let avatarView = SPAvatarView()
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
    }()

    fileprivate lazy var label: UILabel = {
        return UILabel()
            .font(UIFont.preferred(style: .regular, of: Metrics.fontSize))
            .text(OWLocalizationManager.shared.localizedString(key: "What do you think?"))
            .textColor(OWColorPalette.shared.color(type: .textColor2, themeStyle: .light))
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
        setupViews()
    }

    private func applyAccessibility() {
        self.accessibilityIdentifier = Metrics.identifier
        label.accessibilityIdentifier = Metrics.labelIdentifier
    }
}

fileprivate extension OWCommentCreationEntryView {
    func setupViews() {
        applyAccessibility()
        addSubview(userAvatarView)
        userAvatarView.OWSnp.makeConstraints { make in
            make.centerY.leading.equalToSuperview()
            make.size.equalTo(Metrics.userAvatarSize)
        }

        addSubview(labelContainer)
        labelContainer.OWSnp.makeConstraints { make in
            make.top.bottom.trailing.equalToSuperview()
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
                // TODO: custon UI
            }).disposed(by: disposeBag)
    }
}
