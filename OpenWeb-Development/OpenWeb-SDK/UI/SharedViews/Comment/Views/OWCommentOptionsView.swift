//
//  OWCommentOptionsView.swift
//  OpenWebSDK
//
//  Created by Alon Shprung on 28/05/2024.
//  Copyright © 2024 OpenWeb. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

class OWCommentOptionsView: UIView {
    struct Metrics {
        static let optionsImageInset: CGFloat = 22
        static let optionButtonSize: CGFloat = 30
        static let optionButtonIdentifier = "comment_header_option_button_id"
    }

    fileprivate var viewModel: OWCommentOptionsViewModeling!
    fileprivate var disposedBag = DisposeBag()

    fileprivate lazy var optionButton: UIButton = {
        let image = UIImage(spNamed: "optionsIcon", supportDarkMode: true)
        let leftInset: CGFloat = OWLocalizationManager.shared.textAlignment == .left ? 0 : -Metrics.optionsImageInset
        let rightInset: CGFloat = OWLocalizationManager.shared.textAlignment == .right ? 0 : -Metrics.optionsImageInset
        return UIButton()
            .image(image, state: .normal)
            .imageEdgeInsets(UIEdgeInsets(top: 0, left: leftInset, bottom: 0, right: rightInset))
    }()

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init() {
        super.init(frame: .zero)
        setupViews()
        applyAccessibility()
    }

    func configure(with viewModel: OWCommentOptionsViewModeling) {
        setupObservers()
    }

    func prepareForReuse() {
        self.optionButton.isHidden = false
    }
}

fileprivate extension OWCommentOptionsView {
    func setupViews() {
        addSubview(optionButton)
        optionButton.OWSnp.makeConstraints { make in
            make.size.equalTo(Metrics.optionButtonSize)
            make.edges.equalToSuperview()
        }
    }

    func setupObservers() {
        optionButton.rx.tap
            .map { [weak self] in
                return self?.optionButton
            }
            .unwrap()
            .bind(to: viewModel.inputs.tapButton)
            .disposed(by: disposedBag)

        OWSharedServicesProvider.shared.themeStyleService()
            .style
            .subscribe(onNext: { [weak self] currentStyle in
                guard let self = self else { return }

                self.optionButton.image(UIImage(spNamed: "optionsIcon", supportDarkMode: true), state: .normal)
            })
            .disposed(by: disposedBag)
    }

    func applyAccessibility() {
        optionButton.accessibilityIdentifier = Metrics.optionButtonIdentifier
        optionButton.accessibilityTraits = .button
        optionButton.accessibilityLabel = OWLocalizationManager.shared.localizedString(key: "OptionsMenu")
    }
}
