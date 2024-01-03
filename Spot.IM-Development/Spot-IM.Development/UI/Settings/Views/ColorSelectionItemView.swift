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
        static let colorViewBorderSize: CGFloat = 1
        static let colorViewCornerRadius: CGFloat = 4
        static let generalSpacing: CGFloat = 14
        static let colorLabelSpacing: CGFloat = 8
        static let colorRectangleSize: CGFloat = 16
    }

    fileprivate let disposeBag: DisposeBag

    fileprivate lazy var title: UILabel = {
        return viewModel.outputs.title
            .label
            .font(FontBook.paragraph)
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

    fileprivate let viewModel: ColorSelectionItemViewModeling
    init(viewModel: ColorSelectionItemViewModeling) {
        self.viewModel = viewModel
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
            make.leading.greaterThanOrEqualTo(title.snp.trailing).offset(Metrics.generalSpacing)
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
        lightTapGesture.rx.event
            .voidify()
            .map { [weak self] in self?.lightPicker}
            .unwrap()
            .bind(to: viewModel.inputs.displayPicker)
            .disposed(by: disposeBag)

        darkTapGesture.rx.event
            .voidify()
            .map { [weak self] in self?.darkPicker}
            .unwrap()
            .bind(to: viewModel.inputs.displayPicker)
            .disposed(by: disposeBag)

        viewModel.outputs.color
            .take(1)
            .subscribe(onNext: { [weak self] color in
                guard let color = color else { return }
                self?.lightPicker.selectedColor = color.lightColor
                self?.darkPicker.selectedColor = color.darkColor
                self?.lightColorRectangleView.backgroundColor = color.lightColor
                self?.darkColorRectangleView.backgroundColor = color.darkColor
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
        .bind(to: viewModel.inputs.colorChanged)
        .disposed(by: disposeBag)

        lightPicker.rx.didSelectColor
            .bind(to: lightColorRectangleView.rx.backgroundColor)
            .disposed(by: disposeBag)

        darkPicker.rx.didSelectColor
            .bind(to: darkColorRectangleView.rx.backgroundColor)
            .disposed(by: disposeBag)

        enableCheckbox.rx.isOn
            .bind(to: viewModel.inputs.isEnabled)
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
