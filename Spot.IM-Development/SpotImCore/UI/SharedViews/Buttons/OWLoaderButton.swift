//
//  OWLoaderButton.swift
//  SpotImCore
//
//  Created by Refael Sommer on 16/04/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class OWLoaderButton: UIButton {
    var spinner = UIActivityIndicatorView()

    var isLoading = false {
        didSet {
            updateView()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    func setupView() {
        spinner.hidesWhenStopped = true
        spinner.color = .white
        addSubview(spinner)
        spinner.OWSnp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }

    func updateView() {
        if isLoading {
            spinner.startAnimating()
            titleLabel?.alpha = 0
            imageView?.alpha = 0
            // Prevent multiple clicks while in process
            isEnabled = false
        } else {
            spinner.stopAnimating()
            titleLabel?.alpha = 1
            imageView?.alpha = 0
            isEnabled = true
        }
    }
}

extension Reactive where Base: OWLoaderButton {
    var isLoading: Binder<Bool> {
        return Binder(self.base) { _, value in
            base.isLoading = value
        }
    }
}
