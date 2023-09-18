//
//  OWRealtimeIndicationAnimationView.swift
//  SpotImCore
//
//  Created by Revital Pisman on 21/08/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import UIKit
import RxSwift

class OWRealtimeIndicationAnimationView: UIView {
    struct Metrics {
        static let swipeThresholdToDismiss: CGFloat = 5
        static let swipeMagnetAnimationDuration: CGFloat = 0.3
        static let bottomOffsetStartPointDivisor: CGFloat = 2
        static let showAndDismissAnimationDuration: CGFloat = 0.7
        static let showAndDismissAnimationSpringWithDamping: CGFloat = 0.5
        static let showAndDismissAnimationSpringVelocity: CGFloat = 0.5
    }

    fileprivate var indicationViewBottomConstraint: OWConstraint?
    fileprivate var indicationViewCenterConstraint: OWConstraint?
    fileprivate var indicationViewCurrentCenterOffset: CGFloat?
    fileprivate var indicationViewCurrentBottomOffset: CGFloat?

    fileprivate lazy var realtimeIndicationView: OWRealtimeIndicationView = {
        return OWRealtimeIndicationView(viewModel: viewModel.outputs.realtimeIndicationViewModel)
    }()

    fileprivate var viewModel: OWRealtimeIndicationAnimationViewModeling
    fileprivate let disposeBag = DisposeBag()

    init(viewModel: OWRealtimeIndicationAnimationViewModeling) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupUI()
        setupObservers()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.indicationViewCurrentBottomOffset = self.bounds.height / Metrics.bottomOffsetStartPointDivisor

        if indicationViewBottomConstraint == nil,
            let indicationViewCurrentBottomOffset = self.indicationViewCurrentBottomOffset {
            realtimeIndicationView.OWSnp.makeConstraints { make in
                self.indicationViewBottomConstraint = make.bottom.equalToSuperview().offset(indicationViewCurrentBottomOffset).constraint
            }
        }
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        if let hitView = view, hitView.isDescendant(of: self.realtimeIndicationView) {
            return hitView
        }
        return nil
    }
}

fileprivate extension OWRealtimeIndicationAnimationView {
    func setupUI() {
        self.clipsToBounds = true

        self.addSubview(realtimeIndicationView)
        realtimeIndicationView.OWSnp.makeConstraints { [weak self] make in
            self?.indicationViewCurrentCenterOffset = 0.0
            self?.indicationViewCenterConstraint = make.centerX.equalToSuperview().constraint
        }
    }

    func setupObservers() {
        viewModel.outputs
            .shouldShow
            .subscribe(onNext: { [weak self] shouldShow in
                guard let self = self else { return }
                self.animate(shouldShow)
            })
            .disposed(by: disposeBag)

        viewModel.outputs.realtimeIndicationViewModel
            .outputs.horisontalPositionDidChange
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] transition in
                guard let self = self else { return }
                self.indicationViewCurrentCenterOffset = transition
                self.indicationViewCenterConstraint?.update(offset: transition)
            })
            .disposed(by: disposeBag)

        viewModel.outputs.realtimeIndicationViewModel
            .outputs.horisontalPositionChangeDidEnd
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                guard let self = self,
                      let currentCenter = self.indicationViewCurrentCenterOffset else { return }

                if currentCenter > (self.bounds.width / Metrics.swipeThresholdToDismiss) || currentCenter < -(self.bounds.width / Metrics.swipeThresholdToDismiss) {
                    // Dismiss to the side
                    self.swiped(offset: currentCenter)
                } else {
                    // Return to the center
                    self.indicationViewCenterConstraint?.update(offset: 0)
                    UIView.animate(withDuration: Metrics.swipeMagnetAnimationDuration) {
                        self.layoutIfNeeded()
                    }
                }
            })
            .disposed(by: disposeBag)
    }

    func animate(_ isShown: Bool) {
        guard let indicationViewCurrentBottomOffset = self.indicationViewCurrentBottomOffset else { return }
        let offset = isShown ? -indicationViewCurrentBottomOffset/3 : indicationViewCurrentBottomOffset
        self.indicationViewBottomConstraint?.update(offset: offset)

        UIView.animate(
            withDuration: Metrics.showAndDismissAnimationDuration,
            delay: 0.0,
            usingSpringWithDamping: Metrics.showAndDismissAnimationSpringWithDamping,
            initialSpringVelocity: Metrics.showAndDismissAnimationSpringVelocity,
            animations: {
                self.layoutIfNeeded()
            }
        )
    }

    func swiped(offset currentOffset: CGFloat) {
        let offset = currentOffset > 0 ? self.bounds.width : -self.bounds.width
        self.indicationViewCenterConstraint?.update(offset: offset)
        UIView.animate(withDuration: Metrics.swipeMagnetAnimationDuration,
                       animations: {
            self.layoutIfNeeded()
        }, completion: { [ weak self] _ in
            guard let self = self else { return }
            self.reset()
            self.viewModel.inputs.swiped()
        })
    }

    func reset() {
        if let indicationViewCurrentBottomOffset = self.indicationViewCurrentBottomOffset {
            self.indicationViewBottomConstraint?.update(offset: indicationViewCurrentBottomOffset)
        }
        self.indicationViewCurrentCenterOffset = 0
        self.indicationViewCenterConstraint?.update(offset: 0)
        self.layoutIfNeeded()
    }
}
