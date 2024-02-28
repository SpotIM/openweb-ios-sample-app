//
//  GiphyViewController+Rx.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 28/02/2024.
//  Copyright © 2024 Spot.IM. All rights reserved.
//

import Foundation
import GiphyUISDK
import RxSwift
import RxCocoa
import UIKit

// TODO: shoyuld be available only if giphy SDK is available

// https://jayleeios.medium.com/rxswift-delegate-proxy-35362b1e5e10
class GifViewControllerProxy: DelegateProxy<GiphyViewController, GiphyDelegate>, DelegateProxyType, GiphyDelegate {
    fileprivate weak var _control: GiphyViewController? = nil

    init(parentObject: GiphyViewController) {
        self._control = parentObject
        super.init(parentObject: parentObject, delegateProxy: GifViewControllerProxy.self)
    }

    static func registerKnownImplementations() {
        self.register { GifViewControllerProxy(parentObject: $0) }
    }

    static func currentDelegate(for object: GiphyUISDK.GiphyViewController) -> GiphyUISDK.GiphyDelegate? {
        return object.delegate
    }

    static func setCurrentDelegate(_ delegate: GiphyUISDK.GiphyDelegate?, to object: GiphyUISDK.GiphyViewController) {
        object.delegate = delegate
    }

    func didDismiss(controller: GiphyUISDK.GiphyViewController?) {

    }
}

extension Reactive where Base: GiphyViewController {
    var delegate: DelegateProxy<GiphyViewController, GiphyDelegate> {
        return GifViewControllerProxy.proxy(for: self.base)
    }

    var didSelectMedia: Observable<URL> { // TODO: propper data
        return delegate
        // TODO: do we need the contentType?
            .methodInvoked(#selector(GiphyDelegate.didSelectMedia(giphyViewController:media:contentType:)))
            .map { (result) in
                let media = try castOrThrow(GPHMedia.self, result[1])
                return URL(string: media.url)
            }
            .unwrap()
    }

    var didCancel: Observable<Void> {
        return delegate
            .methodInvoked(#selector(GiphyDelegate.didDismiss(controller:)))
            .voidify()
    }

    func castOrThrow<T>(_ resultType: T.Type, _ object: Any) throws -> T {
        guard let returnValue = object as? T else {
            throw RxCocoaError.castingError(object: object, targetType: resultType)
        }

        return returnValue
    }
}
