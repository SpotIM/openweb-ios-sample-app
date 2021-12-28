//
//  SPLoaderView.swift
//  Spot.IM-Core
//
//  Created by Eugene on 8/6/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import UIKit

class SPLoaderView: BaseView {

    private let loader: UIActivityIndicatorView = .init(style: .whiteLarge)
    private let backgroundView: BaseView = .init()
    private let backgroundOpacity: CGFloat
    
    init(frame: CGRect = .zero, backgroundOpacity: CGFloat = 0.2) {
        self.backgroundOpacity = backgroundOpacity
        super.init(frame: frame)
        
        backgroundColor = .clear
        setupUI()
    }
    
    func startLoader() {
        isHidden = false
        loader.startAnimating()
    }
    
    func stopLoader() {
        isHidden = true
        loader.stopAnimating()
    }
    
    private func setupUI() {
        addSubviews(backgroundView, loader)
        configureBackgroundView()
        configureActivityView()
    }
    
    private func configureBackgroundView() {
        backgroundView.backgroundColor = UIColor.black.withAlphaComponent(backgroundOpacity)
        backgroundView.pinEdges(to: self)
    }
    
    private func configureActivityView() {
        loader.tintColor = .black
        loader.layout {
            $0.centerX.equal(to: centerXAnchor)
            $0.centerY.equal(to: centerYAnchor)
        }
    }
    
}
