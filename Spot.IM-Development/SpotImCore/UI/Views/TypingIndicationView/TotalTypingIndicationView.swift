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

final class TotalTypingIndicationView: OWBaseView {
    
    weak var delegate: TotalTypingIndicationViewDelegate?
    
    private let animationImageView: OWBaseUIImageView = .init()
    private let typingLabel: OWBaseLabel = .init()
    
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
        typingLabel.text = "\(count) " + LocalizationManager.localizedString(key: "Typing")
    }
    
    private func setup() {
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(detectPan(recognizer:)))
        addGestureRecognizer(panGesture!)
        addSubviews(animationImageView, typingLabel)
        configureAnimatedView()
        configureTypingLabel()
    }
    
    private func configureTypingLabel() {
        typingLabel.text = LocalizationManager.localizedString(key: "Typing")
        typingLabel.textColor = .spForeground1
        typingLabel.textAlignment = .center
        typingLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        typingLabel.backgroundColor = .spBackground0
        typingLabel.font = UIFont.preferred(style: .regular, of: 15.0)
        typingLabel.OWSnp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(animationImageView.OWSnp.trailing).offset(10.0)
            make.trailing.equalToSuperview().offset(-29.0)
        }
    }
    
    private func configureAnimatedView() {
        animationImageView.animationImages = UIImage.animationImages(with: "Typing")
        animationImageView.contentMode = .scaleAspectFill
        animationImageView.animationDuration = 1.5
        animationImageView.animationRepeatCount = 0
        animationImageView.startAnimating()
        animationImageView.OWSnp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(29.0)
            make.height.equalTo(5.0)
            make.width.equalTo(23.0)
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
        let shadowRect = CGRect(x: 2.0, y: 7.0, width: bounds.width, height: bounds.height-7)
        let shadowPath = UIBezierPath(rect: shadowRect)
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        layer.shadowOpacity = 0.10
        layer.shadowRadius = 17.5
        layer.shadowPath = shadowPath.cgPath
    }
}
