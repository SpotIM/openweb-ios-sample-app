//
//  OWCommentReplyCounterView.swift
//  SpotImCore
//
//  Created by Alon Shprung on 26/06/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import UIKit
import RxSwift

class OWCommentReplyCounterView: UIView {
    fileprivate struct Metrics {
        static let identifier = "comment_cretion_reply_counter_id"
        static let labelIdentifier = "comment_cretion_reply_counter_label_id"

        static let counterHeight = 24.0
    }

    fileprivate lazy var counterLabel: UILabel = {
        return UILabel()
            .font(OWFontBook.shared.font(typography: .footnoteText))
            .textColor(OWColorPalette.shared.color(type: .foreground2Color, themeStyle: .light))
    }()

    fileprivate var viewHeightConstraint: OWConstraint?

    fileprivate let disposeBag = DisposeBag()
    fileprivate let viewModel: OWCommentReplyCounterViewModeling

    init(with viewModel: OWCommentReplyCounterViewModeling) {
        self.viewModel = viewModel
        super.init(frame: .zero)

        setupUI()
        setupObservers()
        applyAccessibility()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

fileprivate extension OWCommentReplyCounterView {
    func setupUI() {
        self.enforceSemanticAttribute()

        self.OWSnp.makeConstraints { make in
            viewHeightConstraint = make.height.equalTo(0).constraint
        }

        addSubview(counterLabel)
        counterLabel.OWSnp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    func setupObservers() {
        OWSharedServicesProvider.shared.themeStyleService()
            .style
            .subscribe(onNext: { [weak self] currentStyle in
                guard let self = self else { return }
                self.counterLabel.textColor = OWColorPalette.shared.color(type: .foreground2Color, themeStyle: currentStyle)
            }).disposed(by: disposeBag)

        viewModel.outputs.counterText
            .bind(to: self.counterLabel.rx.text)
            .disposed(by: disposeBag)

        viewModel.outputs.showCounter
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] showCounter in
                guard let self = self else { return }
                if (showCounter) {
                    self.viewHeightConstraint?.update(offset: Metrics.counterHeight)
                }
            })
            .disposed(by: disposeBag)

        OWSharedServicesProvider.shared.appLifeCycle()
            .didChangeContentSizeCategory
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.counterLabel.font = OWFontBook.shared.font(typography: .footnoteText)
            })
            .disposed(by: disposeBag)
    }

    func applyAccessibility() {
        self.accessibilityIdentifier = Metrics.identifier
        self.counterLabel.accessibilityIdentifier = Metrics.labelIdentifier
    }
}
