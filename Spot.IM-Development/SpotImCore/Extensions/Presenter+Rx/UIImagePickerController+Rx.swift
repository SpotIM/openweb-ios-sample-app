//
//  UIImagePickerController+Rx.swift
//  SpotImCore
//
//  Created by Alon Shprung on 16/08/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import UIKit

class RxImagePickerDelegateProxy
    : RxNavigationControllerDelegateProxy, UIImagePickerControllerDelegate {

    public init(imagePicker: UIImagePickerController) {
        super.init(navigationController: imagePicker)
    }

}

extension Reactive where Base: UIImagePickerController {
    static func show(
        onViewController viewController: UIViewController,
        animated: Bool = true,
        mediaTypes: [String],
        sourceType: UIImagePickerController.SourceType
    ) -> Observable<OWImagePickerPresenterResponseType> {

        let imagePickerVC = UIImagePickerController()
        imagePickerVC.mediaTypes = mediaTypes
        imagePickerVC.sourceType = sourceType
        imagePickerVC.allowsEditing = false

        viewController.present(imagePickerVC, animated: animated)

        let pickerCanceled = imagePickerVC.rx.didCancel
            .map { OWImagePickerPresenterResponseType.cancled }

        let pickerFinishWithMediaInfo = imagePickerVC.rx.didFinishPickingMediaWithInfo
            .map { OWImagePickerPresenterResponseType.mediaInfo($0) }

        return Observable.merge(pickerCanceled, pickerFinishWithMediaInfo)
            .do(onNext: { _ in
                imagePickerVC.dismiss(animated: animated, completion: nil)
            })
    }
}

fileprivate extension Reactive where Base: UIImagePickerController {
    var didFinishPickingMediaWithInfo: Observable<[UIImagePickerController.InfoKey: AnyObject]> {
        return delegate
            .methodInvoked(#selector(UIImagePickerControllerDelegate.imagePickerController(_:didFinishPickingMediaWithInfo:)))
            .map({ (a) in
                return try castOrThrow(Dictionary<UIImagePickerController.InfoKey, AnyObject>.self, a[1])
            })
    }

    var didCancel: Observable<()> {
        return delegate
            .methodInvoked(#selector(UIImagePickerControllerDelegate.imagePickerControllerDidCancel(_:)))
            .map {_ in () }
    }

    func castOrThrow<T>(_ resultType: T.Type, _ object: Any) throws -> T {
        guard let returnValue = object as? T else {
            throw RxCocoaError.castingError(object: object, targetType: resultType)
        }

        return returnValue
    }
}
