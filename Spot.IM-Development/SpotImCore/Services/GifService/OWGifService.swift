//
//  OWGifService.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 28/02/2024.
//  Copyright © 2024 Spot.IM. All rights reserved.
//

#if canImport(GiphyUISDK)
import Foundation
import GiphyUISDK
import RxSwift

// TODO: Check if giphy sdk is available and import accordingly
protocol OWGifServicing {
    func gifSelectionVC() -> GiphyViewController
}

class OWGifService: OWGifServicing {
    fileprivate unowned let sharedServicesProvider: OWSharedServicesProviding

    fileprivate var giphyVC: GiphyViewController? = nil
    fileprivate var theme: GPHTheme = GPHTheme()

    fileprivate let disposeBag = DisposeBag()

    init(sharedServicesProvider: OWSharedServicesProviding) {
        self.sharedServicesProvider = sharedServicesProvider

        configure()
        setupObservers()
    }

    func gifSelectionVC() -> GiphyViewController {
        let giphy = GiphyViewController()
        self.giphyVC = giphy
        giphy.theme = theme

        return giphy
    }
}

fileprivate extension OWGifService {
    func configure() {
        Giphy.configure(apiKey: "3ramR4915VrqRb5U5FBcybtsTvSGFJu8") // TODO: key should not be here
    }

    func setupObservers() {
        // TODO: check why changing theme while open mess with alignement
        sharedServicesProvider.themeStyleService()
            .style
            .subscribe(onNext: { [weak self] style in
                guard let self = self else { return }
                switch style {
                case .dark:
                    self.theme = GPHTheme(type: .dark)
                case .light:
                    self.theme = GPHTheme(type: .light)
                }
                self.giphyVC?.theme = self.theme
            })
            .disposed(by: disposeBag)
    }
}
#endif
