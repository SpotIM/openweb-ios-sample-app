//
//  OWCommentCreationView.swift
//  SpotImCore
//
//  Created by Alon Shprung on 17/08/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import UIKit

internal protocol OWCommentCreationEntryViewDelegate: AnyObject {
    func labelContainerDidTap()
    func userAvatarDidTap()
}

class OWCommentCreationEntryView: UIView {
    fileprivate struct Metrics {
        static let separatorHeight: CGFloat = 1
        static let userAvatarSize: CGFloat = 40
        static let callToActionLeading: CGFloat = 12
        static let callToActionHeight: CGFloat = 48
        static let fontSize: CGFloat = 16
        static let identifier = "comment_creation_entry_id"
        static let labelIdentifier = "comment_creation_entry_label_id"
    }
    
    fileprivate lazy var userAvatarView: SPAvatarView = {
        let avatarView = SPAvatarView()
        avatarView.backgroundColor = .clear
        return avatarView
    }()
    
    fileprivate lazy var labelContainer: UIView = {
        let currentStyle = OWSharedServicesProvider.shared.themeStyleService().currentStyle
        return UIView()
            .border(
                width: 1.0,
                color: OWColorPalette.shared.color(type: .borderColor, themeStyle: currentStyle))
            .corner(radius: 6.0)
            .backgroundColor(OWColorPalette.shared.color(type: .background1Color, themeStyle: currentStyle))
            .userInteractionEnabled(true)
    }()
    
    fileprivate lazy var label: UILabel = {
        let currentStyle = OWSharedServicesProvider.shared.themeStyleService().currentStyle
        return UILabel()
            .font(UIFont.preferred(style: .regular, of: Metrics.fontSize))
            .text(LocalizationManager.localizedString(key: "What do you think?"))
            .textColor(OWColorPalette.shared.color(type: .foreground2Color, themeStyle: currentStyle))
    }()
    
    fileprivate lazy var tapGesture: UITapGestureRecognizer = {
        let tapGesture = UITapGestureRecognizer()
        labelContainer.addGestureRecognizer(tapGesture)
        return tapGesture
    }()
    
    fileprivate var viewModel: OWCommentCreationEntryViewModeling!
    fileprivate var disposeBag = DisposeBag()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(with viewModel: OWCommentCreationEntryViewModeling) {
        super.init(frame: .zero)
        disposeBag = DisposeBag()
        self.viewModel = viewModel
        userAvatarView.configure(with: viewModel.outputs.avatarViewVM)
        setupObservers()
        setupViews()
    }
    
    private func applyAccessibility() {
        self.accessibilityIdentifier = Metrics.identifier
        label.accessibilityIdentifier = Metrics.labelIdentifier
    }
    
    init() {
        super.init(frame: .zero)
        setupViews()
    }
    
    func configure(with viewModel: OWCommentCreationEntryViewModeling, delegate: OWCommentCreationEntryViewDelegate) {
        disposeBag = DisposeBag()
        self.viewModel = viewModel
        self.viewModel.inputs.configure(delegate: delegate)
        userAvatarView.configure(with: viewModel.outputs.avatarViewVM)
        setupObservers()
    }
    
    func updateColorsAccordingToStyle() {
        labelContainer.backgroundColor = .spBackground1
        labelContainer.layer.borderColor = UIColor.spBorder.cgColor
        label.textColor = .spForeground2
    }
    
    func handleUICustomizations(customUIDelegate: OWCustomUIDelegate, isPreConversation: Bool) {
        customUIDelegate.customizeView (
            .sayControl (
                labelContainer: labelContainer,
                label: label
            ),
            source: isPreConversation ? .preConversation : .conversation
        )
    }
}

fileprivate extension OWCommentCreationEntryView {
    func setupViews() {
        applyAccessibility()
        addSubview(userAvatarView)
        userAvatarView.OWSnp.makeConstraints { make in
            make.centerY.leading.equalToSuperview()
            make.size.equalTo(Metrics.userAvatarSize)
        }
        
        addSubview(labelContainer)
        labelContainer.OWSnp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.trailing.equalToSuperview().offset(-15)
            make.leading.equalTo(userAvatarView.OWSnp.trailing).offset(12.0)
            make.height.equalTo(48.0)
        }
        
        labelContainer.addSubview(label)
        label.OWSnp.makeConstraints { make in
            make.centerY.trailing.equalToSuperview()
            make.leading.equalToSuperview().offset(Metrics.callToActionLeading)
            make.height.equalTo(Metrics.callToActionHeight)
        }
    }
    
    func setupObservers() {
        viewModel.outputs.ctaText
            .bind(to: label.rx.text)
            .disposed(by: disposeBag)
        
        tapGesture.rx.event.voidify()
        .bind(to: viewModel.inputs.tap)
        .disposed(by: disposeBag)
    }
}
