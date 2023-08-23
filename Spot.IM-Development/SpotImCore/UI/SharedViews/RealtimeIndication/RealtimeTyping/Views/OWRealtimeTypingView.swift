//
//  OWRealtimeTypingView.swift
//  SpotImCore
//
//  Created by Revital Pisman on 20/08/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class OWRealtimeTypingView: UIView {
    fileprivate struct Metrics {
        static let horizontalMargin: CGFloat = 10
        static let animationViewWidth: CGFloat = 19
        static let animationViewHeight: CGFloat = 18

        static let font = OWFontBook.shared.font(typography: .footnoteText)
    }

    fileprivate var viewModel: OWRealtimeTypingViewModeling!
    fileprivate let disposeBag = DisposeBag()

    fileprivate let typingAnimationView: OWTypingAnimationView = {
        let animationView = OWTypingAnimationView()
        animationView.startAnimating()

        return animationView
            .userInteractionEnabled(false)
    }()

    fileprivate lazy var typingLabel: UILabel = {
        return UILabel()
            .font(Metrics.font)
            .textColor(OWColorPalette.shared.color(type: .textColor3,
                                                   themeStyle: OWSharedServicesProvider.shared.themeStyleService().currentStyle))
    }()

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(viewModel: OWRealtimeTypingViewModeling) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupUI()
        setupObservers()
    }
}

fileprivate extension OWRealtimeTypingView {
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
                guard let self = self else { return }
                self.typingLabel.textColor = OWColorPalette.shared.color(type: .textColor3,
                                                                        themeStyle: currentStyle)
            })
            .disposed(by: disposeBag)

        OWSharedServicesProvider.shared.appLifeCycle()
            .didChangeContentSizeCategory
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.typingLabel.font = Metrics.font
            })
            .disposed(by: disposeBag)
    }
}
