//
//  OWGifService.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 28/02/2024.
//  Copyright © 2024 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift
import UIKit
import OpenWebSDK.OWGiphySDK

protocol OWGifServicing {
    var isGiphyAvailable: Bool { get }
    func gifSelectionVC() -> UIViewController?
    var giphyBridge: OWGiphySDKBridge { get }
    var didCancel: Observable<Void> { get }
    var didSelectMedia: Observable<OWCommentGif> { get }
}

class OWGifService: OWGifServicing {
    fileprivate unowned let sharedServicesProvider: OWSharedServicesProviding
    let giphyBridge: OWGiphySDKBridge
    fileprivate static let giphyApiKey = "3ramR4915VrqRb5U5FBcybtsTvSGFJu8"

    fileprivate let disposeBag = DisposeBag()

    var isGiphyAvailable: Bool {
        OWGiphySDKBridge.giphySDKAvailable()
    }

    fileprivate var _didCancel = PublishSubject<Void>()
    var didCancel: Observable<Void> {
        return _didCancel
            .asObservable()
    }

    fileprivate var _didSelectMedia = PublishSubject<OWCommentGif>()
    var didSelectMedia: Observable<OWCommentGif> {
        return _didSelectMedia
            .asObservable()
    }

    init(sharedServicesProvider: OWSharedServicesProviding) {
        self.sharedServicesProvider = sharedServicesProvider
        giphyBridge = OWGiphySDKBridge()
        giphyBridge.delegate = self
        configure()
        setupObservers()
    }

    func gifSelectionVC() -> UIViewController? {
        let vc = giphyBridge.gifSelectionVC()
        giphyBridge.setThemeMode(sharedServicesProvider.themeStyleService().currentStyle == .dark)
        return vc
    }
}

fileprivate extension OWGifService {
    func configure() {
        giphyBridge.configure(OWGifService.giphyApiKey)
    }

    func setupObservers() {
        sharedServicesProvider.themeStyleService()
            .style
            .subscribe(onNext: { [weak self] style in
                guard let self = self else { return }
                self.giphyBridge.setThemeMode(style == .dark ? true : false)
            })
            .disposed(by: disposeBag)
    }
}

extension OWGifService: OWGiphySDKBridgeDelegate {
    func didSelectMedia(withGiphyViewController giphyViewController: UIViewController, media: OWGiphyMedia) {
        _didSelectMedia
            .onNext(OWCommentGif(previewWidth: media.previewWidth,
                                 previewHeight: media.previewHeight,
                                 originalWidth: media.originalWidth,
                                 originalHeight: media.originalHeight,
                                 originalUrl: media.originalUrl,
                                 title: media.title,
                                 previewUrl: media.previewUrl))
    }

    func didDismiss(with controller: UIViewController) {
        _didCancel.onNext()
    }
}
