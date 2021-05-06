//
//  GifWebView.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 06/05/2021.
//  Copyright © 2021 Spot.IM. All rights reserved.
//

import Foundation
import WebKit

internal final class GifWebView: BaseView, WKUIDelegate {
    let gifWebView: WKWebView = WKWebView(frame: .zero, configuration: WKWebViewConfiguration())
    
    private var gifWebViewHeightConstraint: NSLayoutConstraint?
    private var gifWebViewWidthConstraint: NSLayoutConstraint?
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        setupUI()
    }
    
    private func setupUI() {
        addSubviews(gifWebView)
        configureGifWebView()
    }
    
    func configure(with data: CommentViewModel) {
        updateGifWebView(with: data)
    }
    
    private func updateGifWebView(with dataModel: CommentViewModel) {
        if let url = dataModel.commentGifUrl {
            // set url into html template
            let htmlFile = Bundle(for: type(of: self)).path(forResource: "gifWebViewTemplate", ofType: "html")
            var htmlString = try? String(contentsOfFile: htmlFile!, encoding: String.Encoding.utf8)
            htmlString = htmlString?.replacingOccurrences(of: "IMAGE", with: url)
            // set bundle for placeholder image
            let path = Bundle(for: type(of: self)).bundlePath
            let baseUrl = URL(fileURLWithPath: path)
            gifWebView.loadHTMLString(htmlString!, baseURL: baseUrl)
            // calculate GIF width according to height ratio
            let (height, width) = dataModel.calculateGifSize()
            gifWebViewHeightConstraint?.constant = CGFloat(height)
            gifWebViewWidthConstraint?.constant = CGFloat(width)
        } else {
            gifWebViewHeightConstraint?.constant = 0
            gifWebViewWidthConstraint?.constant = 0
        }
    }
    
    private func configureGifWebView() {
        gifWebView.uiDelegate = self
        gifWebView.layer.cornerRadius = 6
        gifWebView.layer.masksToBounds = true
        gifWebView.scrollView.isScrollEnabled = false
        gifWebView.isUserInteractionEnabled = false
        gifWebView.layout {
            gifWebViewHeightConstraint = $0.height.equal(to: 0)
            gifWebViewWidthConstraint = $0.width.equal(to: 0)
            $0.top.equal(to: self.topAnchor)
            $0.bottom.equal(to: self.bottomAnchor)
        }
    }
}
