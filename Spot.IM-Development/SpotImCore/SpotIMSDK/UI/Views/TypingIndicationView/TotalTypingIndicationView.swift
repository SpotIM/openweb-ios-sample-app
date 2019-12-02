//
//  TotalTypingIndicationView.swift
//  SpotImCore
//
//  Created by Eugene on 14.11.2019.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import UIKit

protocol TotalTypingIndicationViewDelegate: class {
    
    func horisontalPositionChangeDidEnd()
    func horisontalPositionDidChange(transition: CGFloat)
}

final class TotalTypingIndicationView: BaseView {
    
    weak var delegate: TotalTypingIndicationViewDelegate?
    
    private let animationImageView: BaseUIImageView = .init()
    private let countLabel: BaseLabel = .init()
    private let typingLabel: BaseLabel = .init()
    
    private var panGesture: UIPanGestureRecognizer?
    
    override var bounds: CGRect {
        didSet {
            dropShadowIfNeeded()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addCornerRadius(18.0)
        clipsToBounds = false
        setup()
    }
    
    func setTypingCount(_ count: Int) {
        countLabel.text = "\(count)"
    }
    
    private func setup() {
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(detectPan(recognizer:)))
        addGestureRecognizer(panGesture!)
        addSubviews(animationImageView, countLabel, typingLabel)
        configureAnimatedView()
        configureCountLabel()
        configureTypingLabel()
    }
    
    private func configureCountLabel() {
        countLabel.textColor = .spForeground1
        countLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        countLabel.backgroundColor = .spBackground0
        countLabel.textAlignment = .center
        countLabel.font = UIFont.preferred(style: .regular, of: 15.0)
        countLabel.layout {
            $0.centerY.equal(to: centerYAnchor)
            $0.leading.equal(to: animationImageView.trailingAnchor, offsetBy: 13.0)
        }
    }
    
    private func configureTypingLabel() {
        typingLabel.text = LocalizationManager.localizedString(key: "Typing")
        typingLabel.textColor = .spForeground1
        typingLabel.textAlignment = .center
        typingLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        typingLabel.backgroundColor = .spBackground0
        typingLabel.font = UIFont.preferred(style: .regular, of: 15.0)
        typingLabel.layout {
            $0.centerY.equal(to: centerYAnchor)
            $0.leading.equal(to: countLabel.trailingAnchor, offsetBy: 10.0)
            $0.trailing.equal(to: trailingAnchor, offsetBy: -29.0)
        }
    }
    
    private func configureAnimatedView() {
        animationImageView.animationImages = UIImage.animationImages(with: "Typing")
        animationImageView.contentMode = .scaleAspectFit
        animationImageView.animationDuration = 1.5
        animationImageView.animationRepeatCount = 0
        animationImageView.startAnimating()
        animationImageView.layout {
            $0.centerY.equal(to: centerYAnchor)
            $0.leading.equal(to: leadingAnchor, offsetBy: 29.0)
            $0.height.equal(to: 5.0)
            $0.width.equal(to: 23.0)
        }
    }
    
    @objc
    private func detectPan(recognizer: UIPanGestureRecognizer) {
        guard let superView = superview else { return }
        
        switch recognizer.state {
        case .changed, .began:
            let translation = recognizer.translation(in: superView)
            delegate?.horisontalPositionDidChange(transition: translation.x)
            
        case .ended:
            delegate?.horisontalPositionChangeDidEnd()
            
        default:
            break
        }
    }
    
    private func dropShadowIfNeeded() {
        let shadowRect = CGRect(x: 0.0, y: 7.0, width: bounds.width, height: bounds.height)
        let shadowPath = UIBezierPath(rect: shadowRect)
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        layer.shadowOpacity = 0.18
        layer.shadowRadius = 18.0
        layer.shadowPath = shadowPath.cgPath
    }
}
