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

protocol OWGifServicing {
    var isGiphyAvailable: Bool { get }
    func gifSelectionVC() -> UIViewController?
    var giphyBridg: OWGiphySDKInterop { get }
    var didCancel: Observable<Void> { get }
    var didSelectMedia: Observable<OWCommentGif> { get }
}

class OWGifService: OWGifServicing {
    fileprivate unowned let sharedServicesProvider: OWSharedServicesProviding
    let giphyBridg: OWGiphySDKInterop

//    fileprivate var giphyVC: GiphyViewController? = nil
//    fileprivate var theme: GPHTheme = GPHTheme()

    fileprivate let disposeBag = DisposeBag()

    var isGiphyAvailable: Bool {
        OWGiphySDKInterop.giphySDKAvailable()
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
        giphyBridg = OWGiphySDKInterop()
        giphyBridg.delegate = self
        configure()
        setupObservers()
    }

    func gifSelectionVC() -> UIViewController? {
        let giphy = giphyBridg.gifSelectionVC() // TODO: hanle nil ?
        return giphy
    }

//    func gifSelectionVC() -> GiphyViewController {
//        let giphy = GiphyViewController()
//        self.giphyVC = giphy
//        giphy.theme = theme
//
//        return giphy
//    }
}

fileprivate extension OWGifService {
    func configure() {
        giphyBridg.configure("3ramR4915VrqRb5U5FBcybtsTvSGFJu8") // TODO: key should not be here
    }

    func setupObservers() {
        // TODO: check why changing theme while open mess with alignement
//        sharedServicesProvider.themeStyleService()
//            .style
//            .subscribe(onNext: { [weak self] style in
//                guard let self = self else { return }
//                switch style {
//                case .dark:
//                    self.theme = GPHTheme(type: .dark)
//                case .light:
//                    self.theme = GPHTheme(type: .light)
//                }
//                self.giphyVC?.theme = self.theme
//            })
//            .disposed(by: disposeBag)
    }
}

extension OWGifService: OWGiphySDKInteropDelegate {
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
