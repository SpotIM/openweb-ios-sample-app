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
    func showMenu(actions: [OWMenuSelectionItem], sender: UIView, viewableMode: OWViewableMode)
    func showActivity(activityItems: [Any], applicationActivities: [UIActivity]?, viewableMode: OWViewableMode) -> Observable<OWRxPresenterResponseType>
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

    func showMenu(actions: [OWMenuSelectionItem], sender: UIView, viewableMode: OWViewableMode) {
        guard let presenterVC = getPresenterVC(for: viewableMode) else { return }
        let menuVM = OWMenuSelectionViewModel(items: actions)
        // OWMenuSelectionWrapperView is addind himself to the presenterVC with propper constraints
        _ = OWMenuSelectionWrapperView(menuVM: menuVM, senderView: sender, presenterVC: presenterVC)
    }

    func showActivity(activityItems: [Any], applicationActivities: [UIActivity]?, viewableMode: OWViewableMode) -> Observable<OWRxPresenterResponseType> {
        guard let presenterVC = getPresenterVC(for: viewableMode)
        else { return .empty() }
        return UIActivityViewController.rx.show(onViewController: presenterVC, activityItems: activityItems, applicationActivities: applicationActivities)
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
