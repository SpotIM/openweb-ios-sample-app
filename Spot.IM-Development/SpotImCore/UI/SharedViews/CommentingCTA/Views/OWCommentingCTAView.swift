//
//  OWCommentingCTAView.swift
//  SpotImCore
//
//  Created by Revital Pisman on 07/05/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import UIKit
import RxSwift

class OWCommentingCTAView: UIView {
    struct Metrics {
        static let horizontalPortraitMargin: CGFloat = 20.0
        static let horizontalLandscapeMargin: CGFloat = 66.0
    }

    fileprivate lazy var skelatonView: OWCommentingCTASkeletonView = {
        return OWCommentingCTASkeletonView()
    }()

    fileprivate lazy var commentCreationEntryView: OWCommentCreationEntryView = {
        return OWCommentCreationEntryView(with: self.viewModel.outputs.commentCreationEntryViewModel)
            .enforceSemanticAttribute()
            .wrapContent()
    }()

    fileprivate lazy var commentingReadOnlyView: OWCommentingReadOnlyView = {
        return OWCommentingReadOnlyView(with: self.viewModel.outputs.commentingReadOnlyViewModel)
            .wrapContent()
    }()

    fileprivate var currentStyleView: UIView? = nil
    fileprivate var heightConstraint: OWConstraint? = nil
    fileprivate var viewModel: OWCommentingCTAViewModeling!
    fileprivate var disposeBag = DisposeBag()

    init(with viewModel: OWCommentingCTAViewModeling) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupViews()
        setupObservers()
    }

    init() {
        super.init(frame: .zero)
        self.setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

fileprivate extension OWCommentingCTAView {
    func setupViews() {
        self.enforceSemanticAttribute()

        let currentOrientation = OWSharedServicesProvider.shared.orientationService().currentOrientation

        self.addSubview(skelatonView)
        skelatonView.OWSnp.makeConstraints { make in
            make.leading.trailing.equalToSuperviewSafeArea().inset(self.horizontalMargin(isLandscape: currentOrientation == .landscape))
            make.top.bottom.equalToSuperviewSafeArea()
            self.heightConstraint = make.height.equalTo(0).constraint
        }
    }

    func setupObservers() {
        viewModel.outputs.style
            .withLatestFrom(OWSharedServicesProvider.shared.orientationService().orientation) { ($0, $1) }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] style, currentOrientation in
                guard let self = self else { return }
                self.subviews.forEach { $0.removeFromSuperview() }

                let view = self.view(forStyle: style)
                self.currentStyleView = view
                self.addSubview(view)
                view.OWSnp.makeConstraints { make in
                    make.leading.trailing.equalToSuperviewSafeArea().inset(self.horizontalMargin(isLandscape: currentOrientation == .landscape))
                    make.top.bottom.equalToSuperviewSafeArea()
                }
            })
            .disposed(by: disposeBag)

        if let heightConstraint = heightConstraint {
            viewModel.outputs.shouldShowView
                .map { !$0 }
                .bind(to: heightConstraint.rx.isActive)
                .disposed(by: disposeBag)
        }

        OWSharedServicesProvider.shared.themeStyleService()
            .style
            .subscribe(onNext: { [weak self] currentStyle in
                guard let self = self else { return }
                self.backgroundColor = OWColorPalette.shared.color(type: .backgroundColor2, themeStyle: currentStyle)
            })
            .disposed(by: disposeBag)

        OWSharedServicesProvider.shared.orientationService()
            .orientation
            .subscribe(onNext: { [weak self] currentOrientation in
                guard let self = self else { return }

                self.currentStyleView?.OWSnp.updateConstraints { make in
                    make.leading.trailing.equalToSuperviewSafeArea().inset(self.horizontalMargin(isLandscape: currentOrientation == .landscape))
                }
            })
            .disposed(by: disposeBag)
    }

    func view(forStyle style: OWCommentingCTAStyle) -> UIView {
        switch style {
        case .cta:
            return self.commentCreationEntryView
        case .conversationEnded:
            return self.commentingReadOnlyView
        default:
            return UIView()
        }
    }

    func horizontalMargin(isLandscape: Bool) -> CGFloat {
        return isLandscape ? Metrics.horizontalLandscapeMargin : Metrics.horizontalPortraitMargin
    }
}

