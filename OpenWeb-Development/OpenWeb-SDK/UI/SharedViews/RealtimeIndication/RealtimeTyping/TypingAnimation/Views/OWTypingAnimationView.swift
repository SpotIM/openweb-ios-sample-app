//
//  OWTypingAnimationView.swift
//  OpenWebSDK
//
//  Created by Revital Pisman on 22/08/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
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

    private var dotLayers: [CAShapeLayer] = []
    private var dotColors: [UIColor] = [
        OWColorPalette.shared.color(type: .typingDotsColor, themeStyle: OWSharedServicesProvider.shared.themeStyleService().currentStyle),
        OWColorPalette.shared.color(type: .typingDotsColor, themeStyle: OWSharedServicesProvider.shared.themeStyleService().currentStyle).withAlphaComponent(Metrics.secondDotOpacity),
        OWColorPalette.shared.color(type: .typingDotsColor, themeStyle: OWSharedServicesProvider.shared.themeStyleService().currentStyle).withAlphaComponent(Metrics.thirdDotOpacity)
    ] {
        didSet {
            for (index, dotLayer) in dotLayers.enumerated() {
                if index < dotColors.count {
                    dotLayer.fillColor = dotColors[index].cgColor
                }
            }
        }
    }

    private var dotDiameter: CGFloat {
        return min(bounds.width / 5, bounds.height)
    }

    private var dotSpacing: CGFloat {
        return dotDiameter / Metrics.dotSpacingDivisor
    }

    private let disposeBag = DisposeBag()

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

    func castToInt(_ value: Any?) throws -> Int {
        if let intValue = value as? Int {
            return intValue
        } else {
            throw OWTypeCastingError.invalidType
        }
    }
}

extension OWTypingAnimationView: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        do {
            let dotIndex = anim.value(forKey: Metrics.typingAnimationIndexKey)
            let dotIndexCasted = try castToInt(dotIndex)
            if dotIndexCasted < dotLayers.count - 1 {
                animateDot(at: dotIndexCasted + 1)
            } else {
                // Start from the first dot after a short delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
                    self?.animateDot(at: 0)
                }
            }
        } catch OWTypeCastingError.invalidType {
            print("OWTypingAnimationView Error: The value is not of type Int.")
        } catch {
            print("OWTypingAnimationView An unexpected error occurred: \(error).")
        }
    }
}

private extension OWTypingAnimationView {
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
        animation.toValue = dotLayer.position.y - (dotDiameter / Metrics.verticalPositionOffsetDivisor) - Metrics.jumpingPositionOffset
        animation.duration = Metrics.animationSpeed
        animation.autoreverses = true
        animation.repeatCount = 1
        animation.delegate = self
        animation.setValue(index, forKey: Metrics.typingAnimationIndexKey)
        dotLayer.add(animation, forKey: Metrics.typingLayerAnimationIdentifier)
    }
}
