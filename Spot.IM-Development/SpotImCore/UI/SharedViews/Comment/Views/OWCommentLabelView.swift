//
//  OWCommentLabelView.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 15/12/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import UIKit
import RxSwift

class OWCommentLabelView: UIView {
    fileprivate struct Metrics {
        static let identifier = "comment_label_id"
        
        static let cornerRaius: CGFloat = 3
        static let horizontalMargin: CGFloat = 10.0
        static let fontSize: CGFloat = 13.0
        static let iconImageHeight: CGFloat = 24.0
        static let iconImageWidth: CGFloat = 14.0
        static let iconTrailingOffset: CGFloat = 5.0
        static let commentLabelViewHeight: CGFloat = 28.0
    }
    
    fileprivate lazy var labelContainer: UIView = {
        return UIView()
            .corner(radius: Metrics.cornerRaius)
    }()
    fileprivate lazy var iconImageView: UIImageView = {
        return UIImageView()
            .contentMode(.scaleAspectFit)
            .backgroundColor(.clear)
            .tintAdjustmentMode(.normal)
            .clipsToBounds(true)
    }()
    fileprivate lazy var label: UILabel = {
        return UILabel()
            .font(.preferred(style: .medium, of: Metrics.fontSize))
    }()
    
    fileprivate var viewModel: OWCommentLabelViewModeling!
    fileprivate var disposeBag = DisposeBag()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.accessibilityIdentifier = Metrics.identifier
        setupUI()
    }
    
    func configure(viewModel: OWCommentLabelViewModeling) {
        self.viewModel = viewModel
        disposeBag = DisposeBag()
        setupObservers()
        // TODO: prepareForReuse
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

fileprivate extension OWCommentLabelView {
    func setupUI() {
        addSubviews(labelContainer)
        labelContainer.addSubviews(iconImageView, label)
        
        labelContainer.OWSnp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(Metrics.commentLabelViewHeight)
        }
        
        iconImageView.OWSnp.makeConstraints { make in
            make.width.equalTo(Metrics.iconImageWidth)
            make.height.equalTo(Metrics.iconImageHeight)
            make.centerY.equalTo(label)
            make.leading.equalToSuperview().offset(Metrics.horizontalMargin)
            make.trailing.equalTo(label.OWSnp.leading).offset(-Metrics.iconTrailingOffset)
        }
        
        label.OWSnp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.trailing.equalToSuperview().offset(-Metrics.horizontalMargin)
        }
    }
    
    func setupObservers() {
        viewModel.outputs.commentLabel
            .unwrap()
            .map {$0.iconUrl}
            .subscribe(onNext: { [weak self] url in
                guard let self = self else { return }
                self.iconImageView.setImage(with: url){ [weak self] (image, _) in
                    self?.iconImageView.image = image?.withRenderingMode(.alwaysTemplate)
                }
            })
            .disposed(by: disposeBag)
        
        viewModel.outputs.commentLabel
            .unwrap()
            .map {$0.text}
            .bind(to: self.label.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.outputs.state
            .withLatestFrom(viewModel.outputs.commentLabel) { state, label -> (LabelState, CommentLabel)? in
                guard let label = label else { return nil }
                return (state, label)
            }
            .unwrap()
            .subscribe(onNext: { [weak self] labelData in
                guard let self = self else { return }
                self.setUIColors(state: labelData.0, labelColor: labelData.1.color)
            })
            .disposed(by: disposeBag)
        
    }
    
    func setUIColors(state: LabelState, labelColor: UIColor) {
        // set background, border, image and text colors according to state
        // TODO: opacity should be set here and handle dark/light change propely
        switch state {
            case .notSelected:
                labelContainer.backgroundColor = .clear
                labelContainer.layer.borderWidth = 1
                labelContainer.layer.borderColor = labelColor.withAlphaComponent(UIColor.commentLabelBorderOpacity).cgColor
                iconImageView.tintColor = labelColor
                label.textColor = labelColor
                break
            case .selected:
                self.labelContainer.backgroundColor = labelColor.withAlphaComponent(UIColor.commentLabelSelectedBackgroundOpacity)
                labelContainer.layer.borderWidth = 0
                iconImageView.tintColor = .white
                label.textColor = .white
                break
            case .readOnly:
                labelContainer.backgroundColor = labelColor.withAlphaComponent(UIColor.commentLabelBackgroundOpacity)
                labelContainer.layer.borderWidth = 0
                iconImageView.tintColor = labelColor
                label.textColor = labelColor
                break
        }
    }
}

