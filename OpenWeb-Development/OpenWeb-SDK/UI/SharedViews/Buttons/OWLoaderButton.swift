//
//  OWLoaderButton.swift
//  SpotImCore
//
//  Created by Refael Sommer on 16/04/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class OWLoaderButton: UIButton {
    fileprivate let disposeBag = DisposeBag()
    fileprivate var spinner = UIActivityIndicatorView()
    fileprivate var isLoading = false {
        didSet {
            if isLoading != oldValue {
                updateView()
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupObservers()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
        setupObservers()
    }

    fileprivate func setupView() {
        spinner.hidesWhenStopped = true
        spinner.color = OWColorPalette.shared.color(type: .textColor2, themeStyle: OWSharedServicesProvider.shared.themeStyleService().currentStyle)
        addSubview(spinner)
        spinner.OWSnp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }

    fileprivate var image: UIImage?
    fileprivate var originalTextColor: UIColor?
    fileprivate func updateView() {
        if isLoading {
            spinner.startAnimating()

            image = image(for: .normal)
            setImage(nil, for: .normal)

            // Changing the text color to transparent to keep original button size
            originalTextColor = titleLabel?.textColor
            textColor(.clear)

            // Prevent multiple clicks while in process
            isEnabled = false
        } else {
            spinner.stopAnimating()
            if let image = image {
                setImage(image, for: .normal)
            }
            if let originalTextColor = originalTextColor {
                textColor(originalTextColor)
            }
            isEnabled = true
        }
    }
}

fileprivate extension OWLoaderButton {
    func setupObservers() {
        OWSharedServicesProvider.shared.themeStyleService()
            .style
            .subscribe(onNext: { [weak self] currentStyle in
                guard let self = self else { return }
                self.spinner.color = OWColorPalette.shared.color(type: .textColor2, themeStyle: currentStyle)
            })
            .disposed(by: disposeBag)
    }
}

extension Reactive where Base: OWLoaderButton {
    var isLoading: Binder<Bool> {
        return Binder(self.base) { _, value in
            base.isLoading = value
        }
    }
}
