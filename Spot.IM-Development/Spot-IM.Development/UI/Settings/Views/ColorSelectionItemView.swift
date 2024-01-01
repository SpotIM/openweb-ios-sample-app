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
import SpotImCore

@available(iOS 14.0, *)
class ColorSelectionItemView: UIView {
    fileprivate struct Metrics {
        static let identifier = "colors_customization_vc_id"
        static let colorViewBorderSize: CGFloat = 1
        static let colorViewCornerRadius: CGFloat = 4
        static let generalSpacing: CGFloat = 14
        static let colorLabelSpacing: CGFloat = 8
        static let colorRectangleSize: CGFloat = 16
    }

    fileprivate let item: ThemeColorItem
    fileprivate let showPicker: (UIColorPickerViewController) -> Void
    fileprivate let disposeBag: DisposeBag

    fileprivate lazy var title: UILabel = {
        let label = UILabel()
        label.font = FontBook.paragraph
        return label
    }()

    fileprivate lazy var enableCheckbox: UISwitch = {
        let switchView =  UISwitch()
        switchView.isOn = true
        switchView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        return switchView
    }()

    fileprivate lazy var lightLabel: UILabel = {
        let label = UILabel()
        label.font = FontBook.helper
        label.text = "light"
        return label
    }()

    fileprivate lazy var lightColorRectangleView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.borderWidth = Metrics.colorViewBorderSize
        view.layer.borderColor = UIColor.black.cgColor
        view.corner(radius: Metrics.colorViewCornerRadius)
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(lightTapGesture)
        return view
    }()

    fileprivate lazy var darkLabel: UILabel = {
        let label = UILabel()
        label.font = FontBook.helper
        label.text = "dark"
        return label
    }()

    fileprivate lazy var darkColorRectangleView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.borderWidth = Metrics.colorViewBorderSize
        view.layer.borderColor = UIColor.black.cgColor
        view.corner(radius: Metrics.colorViewCornerRadius)
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(darkTapGesture)
        return view
    }()

    fileprivate lazy var lightTapGesture: UITapGestureRecognizer = {
        let tap = UITapGestureRecognizer()
        self.addGestureRecognizer(tap)
        self.isUserInteractionEnabled = true

        return tap
    }()

    fileprivate lazy var darkTapGesture: UITapGestureRecognizer = {
        let tap = UITapGestureRecognizer()
        self.addGestureRecognizer(tap)
        self.isUserInteractionEnabled = true

        return tap
    }()

    fileprivate let lightPicker = UIColorPickerViewController()
    fileprivate let darkPicker = UIColorPickerViewController()

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
        self.addSubview(enableCheckbox)
        enableCheckbox.snp.makeConstraints { make in
            make.leading.centerY.equalToSuperview()
        }

        self.addSubview(title)
        title.snp.makeConstraints { make in
            make.leading.equalTo(enableCheckbox.snp.trailing).offset(Metrics.generalSpacing)
            make.top.bottom.equalToSuperview()
        }

        self.addSubview(lightLabel)
        lightLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(title.snp.trailing).offset(Metrics.generalSpacing)
        }

        self.addSubview(lightColorRectangleView)
        lightColorRectangleView.snp.makeConstraints { make in
            make.leading.equalTo(lightLabel.snp.trailing).offset(Metrics.colorLabelSpacing)
            make.size.equalTo(Metrics.colorRectangleSize)
            make.centerY.equalToSuperview()
        }

        self.addSubview(darkLabel)
        darkLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(lightColorRectangleView.snp.trailing).offset(Metrics.generalSpacing)
        }

        self.addSubview(darkColorRectangleView)
        darkColorRectangleView.snp.makeConstraints { make in
            make.leading.equalTo(darkLabel.snp.trailing).offset(Metrics.colorLabelSpacing)
            make.size.equalTo(Metrics.colorRectangleSize)
            make.centerY.trailing.equalToSuperview()
        }
    }

    func setupObservers() {
        title.text = item.title

        lightTapGesture.rx.event
            .voidify()
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.showPicker(self.lightPicker)
            })
            .disposed(by: disposeBag)

        darkTapGesture.rx.event
            .voidify()
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.showPicker(self.darkPicker)
            })
            .disposed(by: disposeBag)

        item.selectedColor
            .take(1)
            .debug("NOGAH: selectedColor")
            .subscribe(onNext: { [weak self] color in
                guard let color = color else { return }
                self?.lightPicker.selectedColor = color.lightColor
                self?.darkPicker.selectedColor = color.darkColor
            })
            .disposed(by: disposeBag)

        Observable.combineLatest(
            lightPicker.rx.didSelectColor,
            darkPicker.rx.didSelectColor
        )
        .map { light, dark in
            guard let light = light,
                  let dark = dark else { return nil }
            return OWColor(lightColor: light, darkColor: dark)
        }
        .unwrap()
        .bind(to: self.item.selectedColor)
        .disposed(by: disposeBag)

        item.selectedColor
            .unwrap()
            .map { $0.lightColor }
            .bind(to: lightColorRectangleView.rx.backgroundColor)
            .disposed(by: disposeBag)

        item.selectedColor
            .unwrap()
            .map { $0.darkColor }
            .bind(to: darkColorRectangleView.rx.backgroundColor)
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
