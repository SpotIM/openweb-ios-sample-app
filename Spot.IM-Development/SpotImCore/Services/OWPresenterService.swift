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
    func showActivity(activityItems: [Any], applicationActivities: [UIActivity]?, viewableMode: OWViewableMode) -> Observable<OWRxPresenterResponseType>
    func showToast(requiredData: OWToastRequiredData, viewableMode: OWViewableMode) -> Observable<OWRxPresenterResponseType>
}

extension OWPresenterServicing {
    func showMenu(title: String? = nil, actions: [OWRxPresenterAction], viewableMode: OWViewableMode) -> Observable<OWRxPresenterResponseType> {
        return showMenu(title: title, actions: actions, viewableMode: viewableMode)
    }
}

class OWPresenterService: OWPresenterServicing {

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
        return UIAlertController.rx.show(onViewController: presenterVC,
                                         preferredStyle: .actionSheet,
                                         title: title,
                                         message: nil,
                                         actions: actions)
    }

    func showActivity(activityItems: [Any], applicationActivities: [UIActivity]?, viewableMode: OWViewableMode) -> Observable<OWRxPresenterResponseType> {
        guard let presenterVC = getPresenterVC(for: viewableMode)
        else { return .empty() }
        return UIActivityViewController.rx.show(onViewController: presenterVC, activityItems: activityItems, applicationActivities: applicationActivities)
    }

    func showToast(requiredData: OWToastRequiredData, viewableMode: OWViewableMode) -> Observable<OWRxPresenterResponseType>{
        guard let presenterVC = getPresenterVC(for: viewableMode) else { return .empty() }

        return Observable.create { observer in
            let rxAction = OWRxPresenterAction(title: "", type: requiredData.action)
            let toastVM = OWToastViewModel(requiredData: requiredData) {
                observer.onNext(.selected(action: rxAction))
                observer.onCompleted()
            }
            let toastView = OWToastView(viewModel: toastVM)

            presenterVC.view.addSubview(toastView)
            toastView.OWSnp.makeConstraints { make in
                make.centerX.equalToSuperview()
                make.bottom.equalToSuperview().offset(50) // TODO: what insets?
            }
            presenterVC.view.setNeedsLayout()
            presenterVC.view.layoutIfNeeded()

            UIView.animate(withDuration: 0.5, animations: {
                toastView.OWSnp.updateConstraints { make in
                    make.bottom.equalToSuperview().inset(30)
                }
                presenterVC.view.setNeedsLayout()
                presenterVC.view.layoutIfNeeded()
            }, completion: { _ in
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 5) {
                    UIView.animate(withDuration: 0.5, animations: {
                        toastView.OWSnp.updateConstraints { make in
                            make.bottom.equalToSuperview().offset(50)
                        }
                        presenterVC.view.setNeedsLayout()
                        presenterVC.view.layoutIfNeeded()
                    }, completion: { _ in
                        toastView.removeFromSuperview()
                    })
                }

            })

            return Disposables.create()
        }
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
