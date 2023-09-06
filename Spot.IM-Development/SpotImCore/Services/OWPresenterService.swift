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
    func showAlert(
        title: String?,
        message: String?,
        actions: [OWRxPresenterAction],
        preferredStyle: UIAlertController.Style,
        viewableMode: OWViewableMode
    ) -> Observable<OWRxPresenterResponseType>
    func showMenu(actions: [OWRxPresenterAction], sender: OWUISource, viewableMode: OWViewableMode) -> Observable<OWRxPresenterResponseType>
    func showActivity(activityItems: [Any], applicationActivities: [UIActivity]?, viewableMode: OWViewableMode) -> Observable<OWRxPresenterResponseType>
    func showToast(requiredData: OWToastRequiredData, viewableMode: OWViewableMode) -> Observable<OWRxPresenterResponseType>
    func showImagePicker(mediaTypes: [String], sourceType: UIImagePickerController.SourceType, viewableMode: OWViewableMode) -> Observable<OWImagePickerPresenterResponseType>
}

extension OWPresenterServicing {
    func showAlert(
        title: String?,
        message: String?,
        actions: [OWRxPresenterAction],
        preferredStyle: UIAlertController.Style = .alert,
        viewableMode: OWViewableMode
    ) -> Observable<OWRxPresenterResponseType> {
        showAlert(title: title, message: message, actions: actions, preferredStyle: preferredStyle, viewableMode: viewableMode)
    }
}

class OWPresenterService: OWPresenterServicing {

    init() {
        RxImagePickerDelegateProxy.register { RxImagePickerDelegateProxy(imagePicker: $0) }
    }

    func showAlert(
        title: String?,
        message: String?,
        actions: [OWRxPresenterAction],
        preferredStyle: UIAlertController.Style = .alert,
        viewableMode: OWViewableMode
    ) -> Observable<OWRxPresenterResponseType> {
        guard let presenterVC = getPresenterVC(for: viewableMode)
        else { return .empty() }

        return UIAlertController.rx.show(onViewController: presenterVC,
                                         preferredStyle: preferredStyle,
                                         title: title,
                                         message: message,
                                         actions: actions)
    }

    func showMenu(actions: [OWRxPresenterAction], sender: OWUISource, viewableMode: OWViewableMode) -> Observable<OWRxPresenterResponseType> {
        guard let presenterVC = getPresenterVC(for: viewableMode) else { return .empty() }
        return Observable.create { observer in
            // Map to regular UIAlertAction
            let menuItems = actions.map { rxAction in
                OWMenuSelectionItem(title: rxAction.title, titleIdentifier: rxAction.type.identifier) {
                    observer.onNext(.selected(action: rxAction))
                    observer.onCompleted()
                }
            }

            let menuVM = OWMenuSelectionViewModel(items: menuItems, onDismiss: {
                observer.onNext(.completion)
                observer.onCompleted()
            })

            // calculate constraints for menu
            let senderLocationFrame = sender.convert(CGPoint.zero, to: presenterVC.view)
            let isTopSection = senderLocationFrame.y < (presenterVC.view.frame.height / 2)
            let isLeftSection = senderLocationFrame.x < (presenterVC.view.frame.width / 2)

            var menuConstraintsMapper: [OWMenuConstraintOption: OWConstraintItem] = [:]
            if (isTopSection) {
                menuConstraintsMapper[.top] = sender.OWSnp.centerY
            } else {
                menuConstraintsMapper[.bottom] = sender.OWSnp.centerY
            }
            if (isLeftSection) {
                menuConstraintsMapper[.left] = sender.OWSnp.centerX
            } else {
                menuConstraintsMapper[.right] = sender.OWSnp.centerX
            }

            // Create OWMenuSelectionEncapsulationView and align menu according to constraints
            let menuEncapsulationView = OWMenuSelectionEncapsulationView(menuVM: menuVM, constraintsMapper: menuConstraintsMapper)
            presenterVC.view.addSubview(menuEncapsulationView)
            menuEncapsulationView.OWSnp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
            menuEncapsulationView.setupMenu()

            return Disposables.create()
        }
    }

    func showActivity(activityItems: [Any], applicationActivities: [UIActivity]?, viewableMode: OWViewableMode) -> Observable<OWRxPresenterResponseType> {
        guard let presenterVC = getPresenterVC(for: viewableMode) else { return .empty() }
        return UIActivityViewController.rx.show(onViewController: presenterVC, activityItems: activityItems, applicationActivities: applicationActivities)
    }

    func showToast(requiredData: OWToastRequiredData, viewableMode: OWViewableMode) -> Observable<OWRxPresenterResponseType> {
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
                        observer.onNext(.completion)
                    })
                }

            })

            return Disposables.create()
        }
    }

    func showImagePicker(mediaTypes: [String], sourceType: UIImagePickerController.SourceType, viewableMode: OWViewableMode) -> Observable<OWImagePickerPresenterResponseType> {
        guard let presenterVC = getPresenterVC(for: viewableMode) else { return .empty() }
        return UIImagePickerController.rx.show(
            onViewController: presenterVC,
            mediaTypes: mediaTypes,
            sourceType: sourceType
        )
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
