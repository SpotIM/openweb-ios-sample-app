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
        
        addCornerRadius(Metrics.viewCornerRadius)
        clipsToBounds = false
        setup()
    }
    
    func setCount(count: Int, isBlitz: Bool) {
        if isBlitz {
            typingLabel.text = "\(count) " + LocalizationManager.localizedString(key: count > 1 ? "New Comments" : "New Comment")
        } else {
            typingLabel.text = "\(count) " + LocalizationManager.localizedString(key: "Typing")
        }
        typingLabel.font = UIFont.preferred(style: isBlitz ? .bold : .regular, of: Metrics.labelTextSize)
        newCommentsArrowImageView.isHidden = !isBlitz
        animationImageView.isHidden = isBlitz
        animationImageWidthConstraint?.update(offset: isBlitz ? 0 : Metrics.animationImageWidth)
        arrowImageWidthConstraint?.update(offset: isBlitz ? Metrics.arrowImageWidth : 0)
        
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
        typingLabel.font = UIFont.preferred(style: .regular, of: Metrics.labelTextSize)
        typingLabel.OWSnp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(animationImageView.OWSnp.trailing).offset(Metrics.typingLabelLeadingOffset)
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
            make.leading.equalToSuperview().offset(Metrics.animationImageLeadingOffset)
            make.height.equalTo(Metrics.animationImageHeight)
            animationImageWidthConstraint = make.width.equalTo(Metrics.animationImageWidth).constraint
        }
    }
    
    private func configureArrowImage() {
        newCommentsArrowImageView.contentMode = .scaleAspectFill
        newCommentsArrowImageView.OWSnp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(typingLabel.OWSnp.trailing).offset(Metrics.arrowImageLeadingOffset)
            make.height.equalTo(Metrics.arrowImageHeight)
            arrowImageWidthConstraint = make.width.equalTo(Metrics.arrowImageWidth).constraint
            make.trailing.equalToSuperview().offset(-Metrics.arrowImageTrailingOffset)
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
        let shadowRect = CGRect(x: Metrics.shadowRectX, y: Metrics.shadowRectY, width: bounds.width, height: bounds.height-7)
        let shadowPath = UIBezierPath(rect: shadowRect)
        layer.masksToBounds = false
        layer.shadowColor = SPUserInterfaceStyle.isDarkMode ? UIColor.white.cgColor : UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        layer.shadowOpacity = Metrics.shadowOpacity
        layer.shadowRadius = Metrics.shadowRadius
        layer.shadowPath = shadowPath.cgPath
    }
}

fileprivate struct Metrics {
    static let viewCornerRadius: CGFloat = 18
    static let labelTextSize: CGFloat = 15
    static let shadowRectX: CGFloat = 2
    static let shadowRectY: CGFloat = 7
    static let shadowOpacity: Float = 0.10
    static let shadowRadius: CGFloat = 17.5

    static let typingLabelLeadingOffset: CGFloat = 10
    static let animationImageWidth: CGFloat = 23
    static let animationImageHeight: CGFloat = 5
    static let animationImageLeadingOffset: CGFloat = 29
    static let arrowImageWidth: CGFloat = 8.8
    static let arrowImageHeight: CGFloat = 12.8
    static let arrowImageLeadingOffset: CGFloat = 5
    static let arrowImageTrailingOffset: CGFloat = 29
}
