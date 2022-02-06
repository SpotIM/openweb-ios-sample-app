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
    func indicationViewClicked()
}

final class TotalTypingIndicationView: BaseView {
    
    weak var delegate: TotalTypingIndicationViewDelegate?
    
    private let animationImageView: BaseUIImageView = .init()
    private let typingLabel: BaseLabel = .init()
    private let newCommentsArrowImageView: BaseUIImageView = .init()
    
    private var panGesture: UIPanGestureRecognizer?
    private var animationImageWidthConstraint: NSLayoutConstraint?
    private var arrowImageWidthConstraint: NSLayoutConstraint?
    
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
    
    func setCount(count: Int, isBlitz: Bool) {
        if isBlitz {
            typingLabel.text = "\(count) " + LocalizationManager.localizedString(key: count > 1 ? "New Comments" : "New Comment")
        } else {
            typingLabel.text = "\(count) " + LocalizationManager.localizedString(key: "Typing")
        }
        typingLabel.font = UIFont.preferred(style: isBlitz ? .bold : .regular, of: 15.0)
        newCommentsArrowImageView.isHidden = !isBlitz
        animationImageView.isHidden = isBlitz
        animationImageWidthConstraint?.constant = isBlitz ? 0 : 23
        arrowImageWidthConstraint?.constant = isBlitz ? 8.8 : 0
        
        UIView.animate(
            withDuration: 0.3,
            animations: {
                self.layoutIfNeeded()
            })
    }
    
    private func setup() {
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(detectPan(recognizer:)))
        addGestureRecognizer(panGesture!)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(detectTap))
        addGestureRecognizer(tapGesture)
        addSubviews(animationImageView, typingLabel, newCommentsArrowImageView)
        configureAnimatedView()
        configureTypingLabel()
        configureArrowImage()
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
            $0.leading.equal(to: animationImageView.trailingAnchor, offsetBy: 10.0)
//            $0.trailing.equal(to: trailingAnchor, offsetBy: -29.0)
        }
    }
    
    private func configureAnimatedView() {
        animationImageView.animationImages = UIImage.animationImages(with: "Typing")
        animationImageView.contentMode = .scaleAspectFill
        animationImageView.animationDuration = 1.5
        animationImageView.animationRepeatCount = 0
        animationImageView.startAnimating()
        animationImageView.layout {
            $0.centerY.equal(to: centerYAnchor)
            $0.leading.equal(to: leadingAnchor, offsetBy: 29.0)
            $0.height.equal(to: 5.0)
            animationImageWidthConstraint = $0.width.equal(to: 23.0)
        }
    }
    
    private func configureArrowImage() {
        newCommentsArrowImageView.image = UIImage(spNamed: "newCommentsArrow")
        newCommentsArrowImageView.contentMode = .scaleAspectFill
        
        newCommentsArrowImageView.layout {
            $0.centerY.equal(to: centerYAnchor)
            $0.leading.equal(to: typingLabel.trailingAnchor, offsetBy: 5)
            $0.height.equal(to: 12.8)
            arrowImageWidthConstraint = $0.width.equal(to: 8.8)
            $0.trailing.equal(to: trailingAnchor, offsetBy: -29.0)
        }
        
        newCommentsArrowImageView.isHidden = true
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
    
    @objc
    private func detectTap() {
        // TODO - check if its blitz
        delegate?.indicationViewClicked()
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
