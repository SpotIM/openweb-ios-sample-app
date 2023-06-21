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
    fileprivate let disposeBag = DisposeBag()

    init(menuVM: OWMenuSelectionViewModel, senderView: OWUISource, presenterVC: UIViewController) {
        menuView = OWMenuSelectionView.init(viewModel: menuVM)
        super.init(frame: .zero)
        setupViews(senderView: senderView, presenterVC: presenterVC)
        setupObservers()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

fileprivate extension OWMenuSelectionEncapsulationView {
    func setupViews(senderView: OWUISource, presenterVC: UIViewController) {
        presenterVC.view.addSubview(self)
        self.OWSnp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        let senderLocationFrame = senderView.convert(CGPoint.zero, to: presenterVC.view)
        let isTopSection = senderLocationFrame.y < (presenterVC.view.frame.height / 2)
        let isLeftSection = senderLocationFrame.x < (presenterVC.view.frame.width / 2)

        self.addSubview(menuView)
        menuView.OWSnp.makeConstraints { make in
            if (isTopSection) {
                make.top.equalTo(senderView.OWSnp.centerY)
            } else {
                make.bottom.equalTo(senderView.OWSnp.centerY)
            }
            if (isLeftSection) {
                make.left.equalTo(senderView.OWSnp.centerX)
            } else {
                make.right.equalTo(senderView.OWSnp.centerX)
            }
        }
    }

    func setupObservers() {
        tapGesture.rx.event
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.dismissMenu()
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
