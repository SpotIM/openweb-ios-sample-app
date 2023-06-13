//
//  OWPresenterService.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 18/04/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift
import UIKit

protocol OWPresenterServicing {
    func showAlert(title: String, message: String, actions: [OWRxPresenterAction], viewableMode: OWViewableMode) -> Observable<OWRxPresenterResponseType>
    func showMenu(title: String?, actions: [OWRxPresenterAction], viewableMode: OWViewableMode) -> Observable<OWRxPresenterResponseType>
    func showMenu(actions: [OWMenuSelectionItem], sender: UIView, viewableMode: OWViewableMode)
}

extension OWPresenterServicing {
    func showMenu(title: String? = nil, actions: [OWRxPresenterAction], viewableMode: OWViewableMode) -> Observable<OWRxPresenterResponseType> {
        return showMenu(title: title, actions: actions, viewableMode: viewableMode)
    }
}

class OWPresenterService: OWPresenterServicing {

    var disposeBag = DisposeBag()

    func showAlert(title: String, message: String, actions: [OWRxPresenterAction], viewableMode: OWViewableMode) -> Observable<OWRxPresenterResponseType> {
        guard let presenterVC = getPresenterVC(for: viewableMode)
        else { return .empty() }

        return UIAlertController.rx.show(onViewController: presenterVC,
                                         preferredStyle: .alert,
                                         title: title,
                                         message: message,
                                         actions: actions)
    }

    func showMenu(title: String?, actions: [OWRxPresenterAction], viewableMode: OWViewableMode) -> Observable<OWRxPresenterResponseType> {
        // TODO: show proper menu instead of actionSheet
        guard let presenterVC = getPresenterVC(for: viewableMode)
        else { return .empty() }
        return .empty()
//        return UIAlertController.rx.show(onViewController: presenterVC,
//                                         preferredStyle: .actionSheet,
//                                         title: title,
//                                         message: nil,
//                                         actions: actions)
    }

    func showMenu(actions: [OWMenuSelectionItem], sender: UIView, viewableMode: OWViewableMode) {
        guard let presenterVC = getPresenterVC(for: viewableMode) else { return }
        let menuVM = OWMenuSelectionViewModel(items: actions.map {
            OWMenuSelectionItem(title: $0.title, onClick: PublishSubject()) // TODO: publish subject
        })
        let menuView = OWMenuSelection(viewModel: menuVM)

        let wrapperView = UIView().backgroundColor(.clear)
        presenterVC.view.addSubview(wrapperView)
        wrapperView.OWSnp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        wrapperView.addSubview(menuView)

        var zeroSizeConstraint: OWConstraint? = nil
        let senderLocationFrame = sender.convert(CGPoint.zero, to: presenterVC.view)
        let isTopSection = senderLocationFrame.y < (presenterVC.view.frame.height / 2)
        let isLeftSection = senderLocationFrame.x < (presenterVC.view.frame.width / 2)
        menuView.OWSnp.makeConstraints { make in
            if (isTopSection) {
                make.top.equalTo(sender.OWSnp.centerY)
            } else {
                make.bottom.equalTo(sender.OWSnp.centerY)
            }
            if (isLeftSection) {
                make.left.equalTo(sender.OWSnp.centerX)
            } else {
                make.right.equalTo(sender.OWSnp.centerX)
            }

            zeroSizeConstraint = make.size.equalTo(0).constraint
            zeroSizeConstraint?.isActive = true
        }

        let tapGesture: UITapGestureRecognizer = {
            let tap = UITapGestureRecognizer()
            tap.numberOfTapsRequired = 1
            return tap
        }()

        wrapperView.addGestureRecognizer(tapGesture)
        tapGesture.rx.event
            .voidify()
            .subscribe(onNext: { _ in
                wrapperView.removeFromSuperview()
            })
            .disposed(by: disposeBag)

        // TODO: propper animation
        UIView.animate(withDuration: 0.3, delay: 0, options: UIView.AnimationOptions.transitionCurlDown, animations: {
            zeroSizeConstraint?.isActive = false
            menuView.setNeedsLayout()
            menuView.layoutIfNeeded()
        })
    }
}

fileprivate extension OWPresenterService {
    func getPresenterVC(for viewableMode: OWViewableMode) -> UIViewController? {
        switch(viewableMode) {
        case .independent:
            return (OWManager.manager.uiLayer as? OWCompactRouteringCompatible)?.compactRoutering.topController
        case .partOfFlow:
            return (OWManager.manager.uiLayer as? OWRouteringCompatible)?.routering.navigationController
        }
    }
}
