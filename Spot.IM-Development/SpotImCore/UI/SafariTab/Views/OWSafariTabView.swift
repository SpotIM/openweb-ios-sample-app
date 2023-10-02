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

class OWSafariTabView: UIView, OWThemeStyleInjectorProtocol {
    fileprivate struct Metrics {
        static let horizontalOffset: CGFloat = 16.0
        static let identifier = "web_tab_view_id"
        static let closeButtonIdentifier = "web_tab_close_button_id"
    }

    fileprivate lazy var webView: WKWebView = {
        let webView = WKWebView(frame: .zero,
                                configuration: WKWebViewConfiguration())
        return webView
    }()

    fileprivate let viewModel: OWSafariTabViewViewModeling
    fileprivate let disposeBag = DisposeBag()

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(viewModel: OWSafariTabViewViewModeling) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupViews()
        setupObservers()
        applyAccessibility()
    }
}

fileprivate extension OWSafariTabView {

    func applyAccessibility() {
        self.accessibilityIdentifier = Metrics.identifier
//        cancelButton.accessibilityIdentifier = Metrics.cancelButtonIdentifier
    }

    func setupViews() {
        self.useAsThemeStyleInjector()

        self.addSubview(webView)
        webView.OWSnp.makeConstraints { make in
            make.edges.equalToSuperview()
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
