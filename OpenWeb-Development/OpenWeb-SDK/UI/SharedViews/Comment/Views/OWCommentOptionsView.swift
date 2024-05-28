//
//  OWCommentOptionsView.swift
//  OpenWebSDK
//
//  Created by Alon Shprung on 28/05/2024.
//  Copyright © 2024 OpenWeb. All rights reserved.
//

import Foundation
import UIKit

class OWCommentOptionsView: UIView {
    struct Metrics {
        static let optionsImageInset: CGFloat = 22
        static let optionButtonSize: CGFloat = 30
        static let optionButtonIdentifier = "comment_header_option_button_id"
    }

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

    func configure(with viewModel: OWCommentViewModeling) {
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

    }

    func applyAccessibility() {
        optionButton.accessibilityIdentifier = Metrics.optionButtonIdentifier
        optionButton.accessibilityTraits = .button
        optionButton.accessibilityLabel = OWLocalizationManager.shared.localizedString(key: "OptionsMenu")
    }
}
