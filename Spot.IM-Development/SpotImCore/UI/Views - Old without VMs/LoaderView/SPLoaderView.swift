//
//  SPLoaderView.swift
//  Spot.IM-Core
//
//  Created by Eugene on 8/6/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import UIKit

class SPLoaderView: OWBaseView {

    private let loader: UIActivityIndicatorView = .init(style: .whiteLarge)
    private let backgroundView: OWBaseView = .init()
    private let backgroundOpacity: CGFloat
    
    init(frame: CGRect = .zero, backgroundOpacity: CGFloat = 0.2) {
        self.backgroundOpacity = backgroundOpacity
        super.init(frame: frame)
        
        backgroundColor = .clear
        backgroundView.backgroundColor = .clear
        setupUI()
    }
    
    func startLoader() {
        isHidden = false
        backgroundView.backgroundColor = UIColor.black.withAlphaComponent(backgroundOpacity)
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
        backgroundView.OWSnp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func configureActivityView() {
        loader.tintColor = .black
        loader.OWSnp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
}
