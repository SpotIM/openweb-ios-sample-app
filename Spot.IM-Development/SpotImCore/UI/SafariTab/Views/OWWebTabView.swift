//
//  OWSafariTabView.swift
//  SpotImCore
//
//  Created by Alon Haiut on 02/10/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import UIKit
import RxSwift
import WebKit

class OWWebTabView: UIView, OWThemeStyleInjectorProtocol {
    fileprivate struct Metrics {
        static let horizontalOffset: CGFloat = 16.0
        static let titleViewHeight: CGFloat = 56
        static let identifier = "web_tab_view_id"
        static let titleHeaderIdentifier = "web_tab_title_header"
    }

    fileprivate lazy var webView: WKWebView = {
        let preferences = WKPreferences()

        // uncomment if you want to inspect the webview with safari
        // preferences.setValue(true, forKey: "developerExtrasEnabled")

        let configuration = WKWebViewConfiguration()
        configuration.preferences = preferences

        // disable local storage persistance
        configuration.websiteDataStore = WKWebsiteDataStore.nonPersistent()

        let webView = WKWebView(frame: .zero, configuration: configuration)

        // uncomment if you want to inspect the webview with safari on iOS > 16.4
        // if #available(iOS 16.4, *) {
        //    webView.isInspectable = true
        // }

        return webView
    }()

    fileprivate lazy var titleView: OWTitleView = {
        let titleView = OWTitleView(title: viewModel.outputs.options.title,
                                    prefixIdentifier: Metrics.titleHeaderIdentifier, viewModel: viewModel.outputs.titleViewVM)
        return titleView
    }()

    fileprivate let viewModel: OWWebTabViewViewModeling
    fileprivate let disposeBag = DisposeBag()

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(viewModel: OWWebTabViewViewModeling) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupViews()
        setupObservers()
        applyAccessibility()
    }
}

fileprivate extension OWWebTabView {

    func applyAccessibility() {
        self.accessibilityIdentifier = Metrics.identifier
    }

    func setupViews() {
        self.useAsThemeStyleInjector()

        if viewModel.outputs.shouldShowTitleView {
            self.addSubview(titleView)
            titleView.OWSnp.makeConstraints { make in
                make.leading.trailing.top.equalToSuperviewSafeArea()
                make.height.equalTo(Metrics.titleViewHeight)
            }
        }

        self.addSubview(webView)
        webView.OWSnp.makeConstraints { make in
            if viewModel.outputs.shouldShowTitleView {
                make.top.equalTo(titleView.OWSnp.bottom)
            } else {
                make.top.equalToSuperview()
            }
            make.leading.trailing.bottom.equalToSuperview()
        }
    }

    func setupObservers() {
        OWSharedServicesProvider.shared.themeStyleService()
            .style
            .subscribe(onNext: { [weak self] currentStyle in
                guard let self = self else { return }
                self.backgroundColor = OWColorPalette.shared.color(type: .backgroundColor2, themeStyle: currentStyle)
            })
            .disposed(by: disposeBag)

        // Load the url
        let request = URLRequest(url: viewModel.outputs.options.url)
        webView.load(request)
    }
}
