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
    private let backgroundView: UIView = .init()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .clear
        setupUI()
    }
    
    func startLoader() {
        loader.startAnimating()
    }
    
    func stopLoader() {
        loader.stopAnimating()
    }
    
    private func setupUI() {
        addSubviews(backgroundView, loader)
        configureBackgroundView()
        configureActivityView()
    }
    
    private func configureBackgroundView() {
        backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.2)
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
