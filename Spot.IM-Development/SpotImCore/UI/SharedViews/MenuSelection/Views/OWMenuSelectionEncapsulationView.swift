//
//  OWMenuSelectionWrapperView.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 14/06/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class OWMenuSelectionEncapsulationView: UIView {
    fileprivate lazy var tapGesture: UITapGestureRecognizer = {
        let tap = UITapGestureRecognizer()
        tap.delegate = self
        self.addGestureRecognizer(tap)
        self.isUserInteractionEnabled = true
        return tap
    }()

    fileprivate var menuView: OWMenuSelectionView
    fileprivate var constraintsMapper: [OWMenuConstraintOption: OWConstraintItem]
    fileprivate let disposeBag = DisposeBag()
    fileprivate let menuVM: OWMenuSelectionViewModeling

    init(menuVM: OWMenuSelectionViewModeling, constraintsMapper: [OWMenuConstraintOption: OWConstraintItem]) {
        self.menuVM = menuVM
        menuView = OWMenuSelectionView(viewModel: menuVM)
        self.constraintsMapper = constraintsMapper
        super.init(frame: .zero)
        setupObservers()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupMenu() {
        self.addSubview(menuView)
        menuView.OWSnp.makeConstraints { make in
            constraintsMapper.forEach { option, constraintItem in
                switch(option) {
                case .top: make.top.equalTo(constraintItem)
                case .bottom: make.bottom.equalTo(constraintItem)
                case .left: make.left.equalTo(constraintItem)
                case .right: make.right.equalTo(constraintItem)
                }
            }
        }
    }
}

fileprivate extension OWMenuSelectionEncapsulationView {
    func setupObservers() {
        tapGesture.rx.event
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.dismissMenu()
                self.menuVM.inputs.menuDismissed.onNext()
            })
            .disposed(by: disposeBag)
    }

    func dismissMenu() {
        self.removeFromSuperview()
    }
}

extension OWMenuSelectionEncapsulationView: UIGestureRecognizerDelegate {
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let tapLocation = gestureRecognizer.location(in: menuView)
        // Enable interaction inside menu view - but also dismiss menu
        if menuView.bounds.contains(tapLocation) {
            // Make sure that menu is dismissed only after click is done
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.dismissMenu()
            }
            return false
        }
        return true
    }
}
