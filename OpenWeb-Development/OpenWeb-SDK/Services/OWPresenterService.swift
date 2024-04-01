//
//  OWPresenterService.swift
//  OpenWebSDK
//
//  Created by  Nogah Melamed on 18/04/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
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
    func showImagePicker(mediaTypes: [String], sourceType: UIImagePickerController.SourceType, viewableMode: OWViewableMode) -> Observable<OWImagePickerPresenterResponseType>
    func showGifPicker(viewableMode: OWViewableMode) -> Observable<OWGifPickerPresenterResponseType>
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
    fileprivate unowned let sharedServicesProvider: OWSharedServicesProviding

    init(sharedServicesProvider: OWSharedServicesProviding) {
        self.sharedServicesProvider = sharedServicesProvider
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

    func showImagePicker(mediaTypes: [String], sourceType: UIImagePickerController.SourceType, viewableMode: OWViewableMode) -> Observable<OWImagePickerPresenterResponseType> {
        guard let presenterVC = getPresenterVC(for: viewableMode) else { return .empty() }
        return UIImagePickerController.rx.show(
            onViewController: presenterVC,
            mediaTypes: mediaTypes,
            sourceType: sourceType
        )
    }

    // This function should not be called! We musr use gif picker only if giphy availabe
    func showGifPicker(viewableMode: OWViewableMode) -> Observable<OWGifPickerPresenterResponseType> {
        let gifService = sharedServicesProvider.gifService()
        guard let presenterVC = getPresenterVC(for: viewableMode),
              let giphyVC = gifService.gifSelectionVC()
        else { return .empty() }

        presenterVC.present(giphyVC, animated: true)

        let pickerCanceled = gifService.didCancel
            .map { OWGifPickerPresenterResponseType.cancled }

        let didSelectMedia = gifService.didSelectMedia
            .map { OWGifPickerPresenterResponseType.mediaInfo($0) }

        return Observable.merge(pickerCanceled, didSelectMedia)
            .do(onNext: { _ in
                giphyVC.dismiss(animated: true, completion: nil)
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
