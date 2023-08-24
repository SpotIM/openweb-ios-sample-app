//
//  OWTypingAnimationView.swift
//  SpotImCore
//
//  Created by Revital Pisman on 22/08/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import UIKit
import RxSwift

class OWTypingAnimationView: UIView {
    struct Metrics {
        static let verticalPositionOffsetDivisor: CGFloat = 4
        static let jumpingPositionOffset: CGFloat = 2.0
        static let numberOfDots: Int = 3
        static let dotSpacingDivisor: CGFloat = 2
        static let secondDotOpacity: CGFloat = 0.65
        static let thirdDotOpacity: CGFloat = 0.30
        static let animationSpeed: Double = 0.2
        
        static var animationKey = "position.y"
        static var typingLayerAnimationIdentifier = "typingLayerAnimationIdentifier"
        static var typingAnimationIndexKey = "typingAnimationIndex"
    }

    fileprivate var dotLayers: [CAShapeLayer] = []
    // swiftlint:disable line_length
    fileprivate var dotColors: [UIColor] = [OWColorPalette.shared.color(type: .typingDotsColor, themeStyle: OWSharedServicesProvider.shared.themeStyleService().currentStyle),
                                            OWColorPalette.shared.color(type: .typingDotsColor, themeStyle: OWSharedServicesProvider.shared.themeStyleService().currentStyle).withAlphaComponent(Metrics.secondDotOpacity),
                                            OWColorPalette.shared.color(type: .typingDotsColor, themeStyle: OWSharedServicesProvider.shared.themeStyleService().currentStyle).withAlphaComponent(Metrics.thirdDotOpacity)] {
        // swiftlint:enable line_lenght
        didSet {
            for (index, dotLayer) in dotLayers.enumerated() {
                if index < dotColors.count {
                    dotLayer.fillColor = dotColors[index].cgColor
                }
            }
        }
    }

    fileprivate var verticalPositionOffset: CGFloat {
        return (dotDiameter / Metrics.verticalPositionOffsetDivisor) - Metrics.jumpingPositionOffset
    }

    fileprivate var dotDiameter: CGFloat {
        return min(bounds.width / 5, bounds.height)
    }

    fileprivate var dotSpacing: CGFloat {
        return dotDiameter / Metrics.dotSpacingDivisor
    }

    fileprivate let disposeBag = DisposeBag()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupDots()
        setupObservers()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupDots()
        setupObservers()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        for (index, dotLayer) in dotLayers.enumerated() {
            dotLayer.path = UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: dotDiameter, height: dotDiameter)).cgPath
            dotLayer.position = CGPoint(x: CGFloat(index) * (dotDiameter + dotSpacing) + dotDiameter / 2, y: bounds.midY)
        }
    }

    func startAnimating() {
        animateDot(at: 0)
    }

    func stopAnimating() {
        for dotLayer in dotLayers {
            dotLayer.removeAnimation(forKey: Metrics.typingLayerAnimationIdentifier)
        }
    }
}

extension OWTypingAnimationView: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if let dotIndex = anim.value(forKey: Metrics.typingAnimationIndexKey) as? Int, dotIndex < dotLayers.count - 1 {
            animateDot(at: dotIndex + 1)
        } else {
            // Start from the first dot after a short delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.animateDot(at: 0)
            }
        }
    }
}

fileprivate extension OWTypingAnimationView {
    func setupObservers() {
        OWSharedServicesProvider.shared.themeStyleService()
            .style
            .subscribe(onNext: { [weak self] currentStyle in
                guard let self = self else { return }
                self.dotColors = [OWColorPalette.shared.color(type: .typingDotsColor, themeStyle: currentStyle),
                                  OWColorPalette.shared.color(type: .typingDotsColor, themeStyle: currentStyle).withAlphaComponent(Metrics.secondDotOpacity),
                                  OWColorPalette.shared.color(type: .typingDotsColor, themeStyle: currentStyle).withAlphaComponent(Metrics.thirdDotOpacity)]
            })
            .disposed(by: disposeBag)
    }

    func setupDots() {
        for index in 0..<Metrics.numberOfDots {
            let dotLayer = CAShapeLayer()
            dotLayer.fillColor = dotColors[index].cgColor
            layer.addSublayer(dotLayer)
            dotLayers.append(dotLayer)
        }
    }

    func animateDot(at index: Int) {
        guard index < dotLayers.count else { return }

        let dotLayer = dotLayers[index]
        let animation = CABasicAnimation(keyPath: Metrics.animationKey)
        animation.toValue = dotLayer.position.y - self.verticalPositionOffset
        animation.duration = Metrics.animationSpeed
        animation.autoreverses = true
        animation.repeatCount = 1
        animation.delegate = self
        animation.setValue(index, forKey: Metrics.typingAnimationIndexKey)
        dotLayer.add(animation, forKey: Metrics.typingLayerAnimationIdentifier)
    }
}
