//
//  OWRealtimeTypingView.swift
//  OpenWebSDK
//
//  Created by Revital Pisman on 20/08/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class OWRealtimeTypingView: UIView {
    private struct Metrics {
        static let horizontalMargin: CGFloat = 10
        static let animationViewWidth: CGFloat = 19
        static let animationViewHeight: CGFloat = 18

        static let titleLabelTextColor: OWColor.OWType = .textColor3

        static let identifier = "realtime_typing_view_id"
        static let typingAnimationViewIdentifier = "realtime_typing_animation_view_id"
        static let typingLabelIdentifier = "realtime_typing_label_id"
    }

    private var viewModel: OWRealtimeTypingViewModeling!
    private let disposeBag = DisposeBag()

    private let typingAnimationView: OWTypingAnimationView = {
        let animationView = OWTypingAnimationView()
        animationView.startAnimating()

        return animationView
            .userInteractionEnabled(false)
    }()

    private lazy var typingLabel: UILabel = {
        return UILabel()
            .font(font)
            .textColor(OWColorPalette.shared.color(type: Metrics.titleLabelTextColor,
                                                   themeStyle: OWSharedServicesProvider.shared.themeStyleService().currentStyle))
    }()

    private var font: UIFont {
        return OWFontBook.shared.font(typography: .footnoteText)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(viewModel: OWRealtimeTypingViewModeling) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupUI()
        setupObservers()
        applyAccessibility()
    }
}

private extension OWRealtimeTypingView {
    func setupUI() {
        self.addSubview(typingAnimationView)
        typingAnimationView.OWSnp.makeConstraints { make in
            make.leading.centerY.equalToSuperview()
            make.height.equalTo(Metrics.animationViewWidth)
            make.width.equalTo(Metrics.animationViewHeight)
        }

        self.addSubview(typingLabel)
        typingLabel.OWSnp.makeConstraints { make in
            make.top.bottom.trailing.equalToSuperview()
            make.leading.equalTo(typingAnimationView.OWSnp.trailing).offset(Metrics.horizontalMargin)
        }
    }

    func setupObservers() {
        viewModel.outputs.typingCount
            .bind(to: typingLabel.rx.text)
            .disposed(by: disposeBag)

        OWSharedServicesProvider.shared.themeStyleService()
            .style
            .subscribe(onNext: { [weak self] currentStyle in
                guard let self else { return }
                self.typingLabel.textColor = OWColorPalette.shared.color(type: Metrics.titleLabelTextColor,
                                                                        themeStyle: currentStyle)
            })
            .disposed(by: disposeBag)

        OWSharedServicesProvider.shared.appLifeCycle()
            .didChangeContentSizeCategory
            .subscribe(onNext: { [weak self] _ in
                guard let self else { return }
                self.typingLabel.font = self.font
            })
            .disposed(by: disposeBag)
    }

    func applyAccessibility() {
        self.accessibilityIdentifier = Metrics.identifier
        typingAnimationView.accessibilityIdentifier = Metrics.typingAnimationViewIdentifier
        typingLabel.accessibilityIdentifier = Metrics.typingLabelIdentifier
    }
}
