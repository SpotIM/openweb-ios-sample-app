//
//  GifWebView.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 06/05/2021.
//  Copyright © 2021 Spot.IM. All rights reserved.
//

import Foundation
import WebKit

internal final class GifWebView: OWBaseView, WKUIDelegate {
    let gifWebView: WKWebView = WKWebView(frame: .zero, configuration: WKWebViewConfiguration())

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        setupUI()
    }

    private func setupUI() {
        addSubviews(gifWebView)
        configureGifWebView()
    }

    func configure(gifUrl: String?) {
        updateGifWebView(with: gifUrl)
    }

    private func updateGifWebView(with gifUrl: String?) {
        if let url = gifUrl {
            // set url into html template
            let htmlFile = Bundle(for: type(of: self)).path(forResource: "gifWebViewTemplate", ofType: "html")
            var htmlString = try? String(contentsOfFile: htmlFile!, encoding: String.Encoding.utf8)
            htmlString = htmlString?.replacingOccurrences(of: "IMAGE", with: url)
            // set bundle for placeholder image
            let path = Bundle(for: type(of: self)).bundlePath
            let baseUrl = URL(fileURLWithPath: path)
            gifWebView.loadHTMLString(htmlString!, baseURL: baseUrl)
        }
    }

    private func configureGifWebView() {
        gifWebView.uiDelegate = self
        gifWebView.layer.cornerRadius = SPCommonConstants.commentMediaCornerRadius
        gifWebView.layer.masksToBounds = true
        gifWebView.scrollView.isScrollEnabled = false
        gifWebView.isUserInteractionEnabled = false
        gifWebView.OWSnp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
