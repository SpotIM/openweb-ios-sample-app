//
//  GiphyViewController+Rx.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 28/02/2024.
//  Copyright © 2024 Spot.IM. All rights reserved.
//

// #if canImport(GiphyUISDK)
import Foundation
import GiphyUISDK
import RxSwift
import RxCocoa
import UIKit

// TODO: shoyuld be available only if giphy SDK is available

// https://jayleeios.medium.com/rxswift-delegate-proxy-35362b1e5e10
//class GifViewControllerProxy: DelegateProxy<OWGiphySDKInterop, OWGiphySDKInteropDelegate>, DelegateProxyType, OWGiphySDKInteropDelegate {
//    fileprivate weak var _control: OWGiphySDKInterop? = nil
//
//    init(parentObject: OWGiphySDKInterop) {
//        self._control = parentObject
//        super.init(parentObject: parentObject, delegateProxy: GifViewControllerProxy.self)
//    }
//
//    static func registerKnownImplementations() {
//        self.register { GifViewControllerProxy(parentObject: $0) }
//    }
//
//    static func currentDelegate(for object: OWGiphySDKInterop) -> OWGiphySDKInteropDelegate? {
//        return object.delegate
//    }
//
//    static func setCurrentDelegate(_ delegate: OWGiphySDKInteropDelegate?, to object: OWGiphySDKInterop) {
//        object.delegate = delegate
//    }
//
//    func didDismiss(with controller: UIViewController) {
//
//    }
// }

//extension Reactive where Base: OWGiphySDKInterop {
//    var delegate: DelegateProxy<OWGiphySDKInterop, OWGiphySDKInteropDelegate> {
//        return GifViewControllerProxy.proxy(for: self.base)
//    }

//    var didSelectMedia: Observable<OWCommentGif> {
//        return delegate

//            .methodInvoked(#selector(OWGiphySDKInteropDelegate.didSelectMedia(withGiphyViewController:media:)))
//            .map { (result) in
//                
//                return nil
//                let media = try castOrThrow(OWGiphyMedia.self, result[1])
//                guard let original = media.images?.original,
//                      let preview = media.images?.preview,
//                      let url = original.gifUrl,
//                      let title = media.title
//                else { return nil }
//
//                return OWCommentGif(previewWidth: preview.width,
//                                    previewHeight: preview.height,
//                                    originalWidth: original.width,
//                                    originalHeight: original.height,
//                                    originalUrl: url,
//                                    title: title,
//                                    previewUrl: preview.gifUrl ?? url)
//            }
//            .unwrap()
//    }

//    var didCancel: Observable<Void> {
//        return delegate
//            .methodInvoked(#selector(OWGiphySDKInteropDelegate.didDismiss(with:)))
//            .voidify()
//    }
//
//    func castOrThrow<T>(_ resultType: T.Type, _ object: Any) throws -> T {
//        guard let returnValue = object as? T else {
//            throw RxCocoaError.castingError(object: object, targetType: resultType)
//        }
//
//        return returnValue
//    }
// }
