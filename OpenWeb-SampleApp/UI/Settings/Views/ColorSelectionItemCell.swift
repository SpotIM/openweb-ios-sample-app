//
//  ColorSelectionItemCell.swift
//  OpenWeb-Development
//
//  Created by  Nogah Melamed on 01/01/2024.
//  Copyright © 2024 OpenWeb. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import OpenWebSDK

@available(iOS 14.0, *)
class ColorSelectionItemCell: UITableViewCell {
    private struct Metrics {
        static let colorViewBorderSize: CGFloat = 1
        static let colorViewCornerRadius: CGFloat = 4
        static let generalSpacing: CGFloat = 14
        static let colorLabelSpacing: CGFloat = 8
        static let colorRectangleSize: CGFloat = 16
    }

    private lazy var title: UILabel = {
        return UILabel()
            .font(FontBook.paragraph)
    }()

    private lazy var enableCheckbox: UISwitch = {
        let switchView = UISwitch()
        switchView.isOn = true
        switchView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        return switchView
    }()

    private lazy var lightLabel: UILabel = {
        let label = UILabel()
        label.font = FontBook.helper
        label.text = "light"
        return label
    }()

    private lazy var lightNoColorRedLine: CAShapeLayer = {
        return diagonalRedLine()
    }()
    private lazy var lightColorRectangleView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.borderWidth = Metrics.colorViewBorderSize
        view.layer.borderColor = UIColor.black.cgColor
        view.corner(radius: Metrics.colorViewCornerRadius)
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(lightTapGesture)
        return view
    }()

    private lazy var darkLabel: UILabel = {
        let label = UILabel()
        label.font = FontBook.helper
        label.text = "dark"
        return label
    }()

    private lazy var darkNoColorRedLine: CAShapeLayer = {
        return diagonalRedLine()
    }()
    private lazy var darkColorRectangleView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.borderWidth = Metrics.colorViewBorderSize
        view.layer.borderColor = UIColor.black.cgColor
        view.corner(radius: Metrics.colorViewCornerRadius)
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(darkTapGesture)
        return view
    }()

    private lazy var lightTapGesture: UITapGestureRecognizer = {
        let tap = UITapGestureRecognizer()
        self.addGestureRecognizer(tap)
        self.isUserInteractionEnabled = true

        return tap
    }()

    private lazy var darkTapGesture: UITapGestureRecognizer = {
        let tap = UITapGestureRecognizer()
        self.addGestureRecognizer(tap)
        self.isUserInteractionEnabled = true

        return tap
    }()

    private var viewModel: ColorSelectionItemCellViewModeling!
    private var disposeBag: DisposeBag

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        self.disposeBag = DisposeBag()
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }

    func configure(with viewModel: ColorSelectionItemCellViewModeling) {
        self.viewModel = viewModel
        self.disposeBag = DisposeBag()

        setupObservers()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

@available(iOS 14.0, *)
private extension ColorSelectionItemCell {
    func setupViews() {
        self.contentView.isUserInteractionEnabled = false

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
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(Metrics.generalSpacing)
        }
    }

    func setupObservers() {
        title.text = viewModel.outputs.title

        lightTapGesture.rx.event
            .voidify()
            .map { .light }
            .bind(to: viewModel.inputs.displayPicker)
            .disposed(by: disposeBag)

        darkTapGesture.rx.event
            .voidify()
            .map { .dark }
            .bind(to: viewModel.inputs.displayPicker)
            .disposed(by: disposeBag)

        viewModel.outputs.color
            .take(1)
            .subscribe(onNext: { [weak self] color in
                guard let color = color else { return }
                self?.lightColorRectangleView.backgroundColor = color.lightColor
                self?.darkColorRectangleView.backgroundColor = color.darkColor
            })
            .disposed(by: disposeBag)

        viewModel.outputs.lightColorObservable
            .map { $0 !== nil }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] isColorSet in
                guard let self = self else { return }
                if isColorSet {
                    self.lightNoColorRedLine.removeFromSuperlayer()
                } else {
                    self.lightColorRectangleView.layer.addSublayer(self.lightNoColorRedLine)
                }
            })
            .disposed(by: disposeBag)

        viewModel.outputs.lightColorObservable
            .bind(to: lightColorRectangleView.rx.backgroundColor)
            .disposed(by: disposeBag)

        viewModel.outputs.darkColorObservable
            .map { $0 !== nil }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] isColorSet in
                guard let self = self else { return }
                if isColorSet {
                    self.darkNoColorRedLine.removeFromSuperlayer()
                } else {
                    self.darkColorRectangleView.layer.addSublayer(self.darkNoColorRedLine)
                }
            })
            .disposed(by: disposeBag)

        viewModel.outputs.darkColorObservable
            .bind(to: darkColorRectangleView.rx.backgroundColor)
            .disposed(by: disposeBag)

        enableCheckbox.rx.isOn
            .bind(to: viewModel.inputs.isEnabled)
            .disposed(by: disposeBag)
    }

    func diagonalRedLine() -> CAShapeLayer {
        let linePath = UIBezierPath()
        linePath.move(to: CGPoint(x: 0, y: Metrics.colorRectangleSize))
        linePath.addLine(to: CGPoint(x: Metrics.colorRectangleSize, y: 0))
        linePath.close()

        let shapeLayer = CAShapeLayer()
        shapeLayer.path = linePath.cgPath
        shapeLayer.lineWidth = 1.0
        shapeLayer.strokeColor = UIColor.red.cgColor
        return shapeLayer
    }
}
