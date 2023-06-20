//
//  OWCommentCreationFloatingKeyboardView.swift
//  SpotImCore
//
//  Created by Alon Shprung on 07/06/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class OWCommentCreationFloatingKeyboardView: UIView, OWThemeStyleInjectorProtocol {
    fileprivate struct Metrics {
        static let identifier = "comment_creation_floating_keyboard_view_id"
        static let prefixIdentifier = "comment_creation_floating_keyboard"
        static let userAvatarLeadingPadding: CGFloat = 16
        static let userAvatarBottomPadding: CGFloat = 12
        static let userAvatarSize: CGFloat = 40
        static let textViewHorizontalPadding: CGFloat = 10
        static let textViewVerticalPadding: CGFloat = 12
    }

    fileprivate lazy var footerView: UIView = {
        return UIView(frame: .zero)
            .backgroundColor(OWColorPalette.shared.color(type: .backgroundColor2, themeStyle: OWSharedServicesProvider.shared.themeStyleService().currentStyle))
    }()

    fileprivate lazy var footerSafeAreaView: UIView = {
        return UIView(frame: .zero)
            .backgroundColor(OWColorPalette.shared.color(type: .backgroundColor2, themeStyle: OWSharedServicesProvider.shared.themeStyleService().currentStyle))
    }()

    fileprivate lazy var textView: OWTextView = {
        return OWTextView(viewModel: viewModel.outputs.textViewVM,
                          prefixIdentifier: Metrics.prefixIdentifier)
    }()

    fileprivate lazy var userAvatarView: OWAvatarView = {
        let avatarView = OWAvatarView()
        avatarView.backgroundColor = .clear
        return avatarView
    }()

    fileprivate lazy var closeButton: UIButton = {
        return UIButton(frame: .zero)
            .backgroundColor(.clear)
    }()

    fileprivate let viewModel: OWCommentCreationFloatingKeyboardViewViewModeling
    fileprivate let disposeBag = DisposeBag()

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(viewModel: OWCommentCreationFloatingKeyboardViewViewModeling) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        userAvatarView.configure(with: viewModel.outputs.avatarViewVM)
        setupViews()
        setupObservers()
        applyAccessibility()
    }

    private func applyAccessibility() {
        self.accessibilityIdentifier = Metrics.identifier
    }
}

fileprivate extension OWCommentCreationFloatingKeyboardView {
    func setupViews() {
        self.useAsThemeStyleInjector()
        self.backgroundColor = .clear

        self.addSubview(closeButton)
        closeButton.OWSnp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        self.addSubview(footerView)
        footerView.OWSnp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(self.safeAreaLayoutGuide)
        }

        self.addSubview(footerSafeAreaView)
        footerSafeAreaView.OWSnp.makeConstraints { make in
            make.top.equalTo(footerView.OWSnp.bottom)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }

        footerView.addSubview(userAvatarView)
        userAvatarView.OWSnp.makeConstraints { make in
            make.leading.equalToSuperview().inset(Metrics.userAvatarLeadingPadding)
            make.bottom.equalToSuperview().inset(Metrics.userAvatarBottomPadding)
            make.size.equalTo(Metrics.userAvatarSize)
        }

        footerView.addSubview(textView)
        textView.OWSnp.makeConstraints { make in
            make.leading.equalTo(userAvatarView.OWSnp.trailing).offset(Metrics.textViewHorizontalPadding)
            make.trailing.equalToSuperview().inset(Metrics.textViewHorizontalPadding)
            make.bottom.top.equalToSuperview().inset(Metrics.textViewVerticalPadding)
            make.height.equalTo(50) // Will be removed after expandable capability added
        }
    }

    func setupObservers() {
        OWSharedServicesProvider.shared.themeStyleService()
            .style
            .subscribe(onNext: { [weak self] currentStyle in
                guard let self = self else { return }

                self.footerView.backgroundColor = OWColorPalette.shared.color(type: .backgroundColor2, themeStyle: currentStyle)
                self.footerSafeAreaView.backgroundColor = OWColorPalette.shared.color(type: .backgroundColor2, themeStyle: currentStyle)
            })
            .disposed(by: disposeBag)

        closeButton.rx.tap
            .bind(to: viewModel.inputs.closeButtonTap)
            .disposed(by: disposeBag)
    }
}

