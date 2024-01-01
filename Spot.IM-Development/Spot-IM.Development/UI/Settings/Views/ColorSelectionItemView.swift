//
//  ColorSelectionItemView.swift
//  Spot-IM.Development
//
//  Created by  Nogah Melamed on 01/01/2024.
//  Copyright © 2024 Spot.IM. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

@available(iOS 14.0, *)
class ColorSelectionItemView: UIView {

    fileprivate let item: ThemeColorItem
    fileprivate let showPicker: (UIColorPickerViewController) -> Void
    fileprivate let disposeBag: DisposeBag

    fileprivate lazy var title: UILabel = {
        return UILabel()
    }()

    fileprivate lazy var colorRectangleView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.borderWidth = 1.0
        view.layer.borderColor = UIColor.black.cgColor
        view.corner(radius: 4)
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(tapGesture)
        return view
    }()

    fileprivate lazy var tapGesture: UITapGestureRecognizer = {
        let tap = UITapGestureRecognizer()
        self.addGestureRecognizer(tap)
        self.isUserInteractionEnabled = true

        return tap
    }()

    fileprivate lazy var enableCheckbox: UISwitch = {
        let switchView =  UISwitch()
        switchView.isOn = true
        switchView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        return switchView
    }()

    fileprivate let picker = UIColorPickerViewController()

    init(item: ThemeColorItem, showPicker: @escaping (UIColorPickerViewController) -> Void) {
        self.item = item
        self.showPicker = showPicker
        self.disposeBag = DisposeBag()
        super.init(frame: .zero)

        setupViews()
        setupObservers()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

@available(iOS 14.0, *)
fileprivate extension ColorSelectionItemView {
    func setupViews() {
        self.addSubview(title)
        title.snp.makeConstraints { make in
            make.top.bottom.leading.equalToSuperview()
        }

        self.addSubview(colorRectangleView)
        colorRectangleView.snp.makeConstraints { make in
            make.leading.equalTo(title.snp.trailing).offset(12)
            make.size.equalTo(16)
            make.centerY.equalToSuperview()
        }

        self.addSubview(enableCheckbox)
        enableCheckbox.snp.makeConstraints { make in
            make.leading.equalTo(colorRectangleView.snp.trailing).offset(12)
            make.trailing.equalToSuperview()
            make.centerY.equalToSuperview()
        }
    }

    func setupObservers() {
        title.text = item.title

        tapGesture.rx.event
            .voidify()
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.showPicker(self.picker)
            })
            .disposed(by: disposeBag)

        picker.rx.didSelectColor
            .bind(to: colorRectangleView.rx.backgroundColor)
            .disposed(by: disposeBag)
    }
}

@available(iOS 14.0, *)
fileprivate extension Reactive where Base: UIColorPickerViewController {
    var didSelectColor: Observable<UIColor?> {
        return Observable.create { observer in
            let token = self.base.observe(\.selectedColor) { _, _ in
                observer.onNext(self.base.selectedColor)
            }

            return Disposables.create {
                token.invalidate()
            }
        }
    }
}
