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

final class TotalTypingIndicationView: OWBaseView {
    
    weak var delegate: TotalTypingIndicationViewDelegate?
    private let animationImageView: OWBaseUIImageView = .init()
    private let typingLabel: OWBaseLabel = .init()
    private let newCommentsArrowImageView: OWBaseUIImageView = .init()
    
    private var panGesture: UIPanGestureRecognizer?
    private var animationImageWidthConstraint: OWConstraint?
    private var arrowImageWidthConstraint: OWConstraint?
    
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
        animationImageWidthConstraint?.update(offset: isBlitz ? 0 : 23)
        arrowImageWidthConstraint?.update(offset: isBlitz ? 8.8 : 0)
        
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
        updateColorsAccordingToStyle()
    }
    
    func updateColorsAccordingToStyle() {
        typingLabel.textColor = .spForeground1
        typingLabel.backgroundColor = .spBackground0
        self.backgroundColor = .spBackground0
        newCommentsArrowImageView.image = UIImage(spNamed: "newCommentsArrow", supportDarkMode: true)
        dropShadowIfNeeded()
    }
    
    private func configureTypingLabel() {
        typingLabel.text = LocalizationManager.localizedString(key: "Typing")
        typingLabel.textAlignment = .center
        typingLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        typingLabel.font = UIFont.preferred(style: .regular, of: 15.0)
        typingLabel.OWSnp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(animationImageView.OWSnp.trailing).offset(10.0)
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
            animationImageWidthConstraint = make.width.equalTo(23.0).constraint
        }
    }
    
    private func configureArrowImage() {
        newCommentsArrowImageView.contentMode = .scaleAspectFill
        newCommentsArrowImageView.OWSnp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(typingLabel.OWSnp.trailing).offset(5)
            make.height.equalTo(12.8)
            arrowImageWidthConstraint = make.width.equalTo(8.8).constraint
            make.trailing.equalToSuperview().offset(-29)
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
        delegate?.indicationViewClicked()
    }
    
    private func dropShadowIfNeeded() {
        let shadowRect = CGRect(x: 2.0, y: 7.0, width: bounds.width, height: bounds.height-7)
        let shadowPath = UIBezierPath(rect: shadowRect)
        layer.masksToBounds = false
        layer.shadowColor = SPUserInterfaceStyle.isDarkMode ? UIColor.white.cgColor : UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        layer.shadowOpacity = 0.10
        layer.shadowRadius = 17.5
        layer.shadowPath = shadowPath.cgPath
    }
}
