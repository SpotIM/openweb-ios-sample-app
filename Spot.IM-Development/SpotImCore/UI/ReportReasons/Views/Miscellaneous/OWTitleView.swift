//
//  OWTitleView.swift
//  SpotImCore
//
//  Created by Refael Sommer on 01/05/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

protocol OWTitleViewOutputs {
    var closeTapped: Observable<Void> { get }
}

protocol OWTitleViewProtocol {
    var outputs: OWTitleViewOutputs { get }
}

class OWTitleView: UIView, OWTitleViewProtocol, OWTitleViewOutputs {
    fileprivate struct Metrics {
        static let suffixIdentifier = "_title_view_id"
        static let titleLabelSuffixIdentifier = "_title_label_id"
        static let closeButtonSuffixIdentifier = "_close_button_id"
        static let titleLeadingPadding: CGFloat = 16
        static let titleFontSize: CGFloat = 15
        static let closeButtonTrailingPadding: CGFloat = 19
        static let closeButtonPadding: CGFloat = 20
    }

    var outputs: OWTitleViewOutputs { return self }

    fileprivate let disposeBag = DisposeBag()

    let title: String

    var closeTap = PublishSubject<Void>()
    var closeTapped: Observable<Void> {
        return closeTap.asObservable()
    }

    fileprivate lazy var titleLabel: UILabel = {
        return title
                .label
                .font(UIFont.preferred(style: .bold, of: Metrics.titleFontSize))
                .text(title)
    }()

    fileprivate lazy var closeButton: UIButton = {
        return UIButton()
            .image(UIImage(spNamed: "closeCrossIcon", supportDarkMode: true), state: .normal)
            .withPadding(Metrics.closeButtonPadding)
    }()

    init(title: String, prefixIdentifier: String) {
        self.title = title
        super.init(frame: .zero)
        setupViews()
        setupObservers()
        applyAccessibility(prefixId: prefixIdentifier)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

fileprivate extension OWTitleView {
    func applyAccessibility(prefixId: String) {
        self.accessibilityIdentifier = prefixId + Metrics.suffixIdentifier
        titleLabel.accessibilityIdentifier = prefixId + Metrics.titleLabelSuffixIdentifier
        closeButton.accessibilityIdentifier = prefixId + Metrics.closeButtonSuffixIdentifier
    }

    func setupViews() {
        self.backgroundColor(OWColorPalette.shared.color(type: .backgroundColor2, themeStyle: OWSharedServicesProvider.shared.themeStyleService().currentStyle))

        self.addSubview(titleLabel)
        titleLabel.OWSnp.makeConstraints { make in
            make.leading.equalToSuperview().inset(Metrics.titleLeadingPadding)
            make.centerY.equalToSuperview()
        }

        self.addSubview(closeButton)
        closeButton.OWSnp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(Metrics.closeButtonTrailingPadding - Metrics.closeButtonPadding)
            make.centerY.equalToSuperview()
        }
    }

    func setupObservers() {
        OWSharedServicesProvider.shared.themeStyleService()
            .style
            .subscribe(onNext: { [weak self] currentStyle in
                guard let self = self else { return }
                self.backgroundColor(OWColorPalette.shared.color(type: .backgroundColor2, themeStyle: currentStyle))
                self.closeButton.image(UIImage(spNamed: "closeCrossIcon", supportDarkMode: true), state: .normal)
            })
            .disposed(by: disposeBag)

        closeButton.rx.tap
            .bind(to: closeTap)
            .disposed(by: disposeBag)
    }
}
