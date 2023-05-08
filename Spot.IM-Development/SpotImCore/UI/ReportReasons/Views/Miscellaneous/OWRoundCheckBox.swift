//
//  OWRoundCheckBox.swift
//  SpotImCore
//
//  Created by Refael Sommer on 17/04/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import UIKit
import RxSwift

class OWRoundCheckBox: UIView {
    fileprivate struct Metrics {
        static let outerSize: CGFloat = 24
        static let innerSize: CGFloat = 16
        static let outerRadius: CGFloat = outerSize/2
        static let innerRadius: CGFloat = innerSize/2
        static let circleCenter: CGFloat = outerSize/2
        static let outerCircleName = "OuterCircle"
        static let innerCircleName = "InnerCircle"
    }

    var setSelected = BehaviorSubject(value: false)

    fileprivate let disposeBag = DisposeBag()

    fileprivate lazy var checkBoxView: UIView = {
        let checkBoxView = UIView()
        let outerCirclePath = UIBezierPath(
            arcCenter: CGPoint(
                x: Metrics.circleCenter,
                y: Metrics.circleCenter
            ),
            radius: CGFloat(Metrics.outerRadius),
            startAngle: CGFloat(0),
            endAngle: CGFloat(Double.pi * 2),
            clockwise: true
        )
        let outerShapeLayer = CAShapeLayer()
        outerShapeLayer.name = Metrics.outerCircleName
        outerShapeLayer.path = outerCirclePath.cgPath

        // Change the fill color
        outerShapeLayer.fillColor = UIColor.clear.cgColor
        // You can change the stroke color
        outerShapeLayer.strokeColor = UIColor.black.cgColor
        // You can change the line width
        outerShapeLayer.lineWidth = 1.0

        let innerCirclePath = UIBezierPath(
            arcCenter: CGPoint(
                x: Metrics.circleCenter,
                y: Metrics.circleCenter
            ),
            radius: CGFloat(Metrics.innerRadius),
            startAngle: CGFloat(0),
            endAngle: CGFloat(Double.pi * 2),
            clockwise: true
        )
        let innerShapeLayer = CAShapeLayer()
        innerShapeLayer.name = Metrics.innerCircleName
        innerShapeLayer.path = innerCirclePath.cgPath

        // Change the fill color
        innerShapeLayer.fillColor = UIColor.clear.cgColor
        // You can change the stroke color
        innerShapeLayer.strokeColor = UIColor.clear.cgColor
        // You can change the line width
        innerShapeLayer.lineWidth = 0

        checkBoxView.layer.addSublayer(outerShapeLayer)
        checkBoxView.layer.addSublayer(innerShapeLayer)

        outerShapeLayer.frame.origin = checkBoxView.center
        innerShapeLayer.frame.origin = checkBoxView.center

        return checkBoxView
    }()

    init() {
        super.init(frame: .zero)
        setupViews()
        setupObservers()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupViews() {
        self.OWSnp.makeConstraints { make in
            make.height.width.equalTo(Metrics.outerSize)
        }

        self.addSubview(checkBoxView)
        checkBoxView.OWSnp.makeConstraints { make in
            make.height.width.equalTo(Metrics.outerSize)
        }
    }

    func setupObservers() {
        setSelected
            .subscribe(onNext: { [weak self] selected in
                guard let self = self,
                      let outerCircleShape = self.checkBoxView.layer.sublayers?.first(where: { $0.name == Metrics.outerCircleName }) as? CAShapeLayer,
                        let innerCircleShape = self.checkBoxView.layer.sublayers?.first(where: { $0.name == Metrics.innerCircleName }) as? CAShapeLayer
                else { return }
                let selectedColor = OWColorPalette.shared.color(type: .brandColor, themeStyle: OWSharedServicesProvider.shared.themeStyleService().currentStyle).cgColor
                let unselectedColor = OWColorPalette.shared.color(type: .textColor1, themeStyle: OWSharedServicesProvider.shared.themeStyleService().currentStyle).cgColor
                outerCircleShape.strokeColor = selected ? selectedColor : unselectedColor
                innerCircleShape.fillColor = selected ? selectedColor : UIColor.clear.cgColor
            })
            .disposed(by: disposeBag)

        Observable.combineLatest(OWSharedServicesProvider.shared.themeStyleService().style, setSelected)
            .subscribe(onNext: { [weak self] currentStyle, selected in
                guard let self = self,
                      let outerCircleShape = self.checkBoxView.layer.sublayers?.first(where: { $0.name == Metrics.outerCircleName }) as? CAShapeLayer,
                      let innerCircleShape = self.checkBoxView.layer.sublayers?.first(where: { $0.name == Metrics.innerCircleName }) as? CAShapeLayer
                else { return }
                let selectedColor = OWColorPalette.shared.color(type: .brandColor, themeStyle: currentStyle).cgColor
                let unselectedColor = OWColorPalette.shared.color(type: .textColor1, themeStyle: currentStyle).cgColor
                outerCircleShape.strokeColor = selected ? selectedColor : unselectedColor
                innerCircleShape.fillColor = selected ? selectedColor : UIColor.clear.cgColor
            })
            .disposed(by: disposeBag)
    }
}
