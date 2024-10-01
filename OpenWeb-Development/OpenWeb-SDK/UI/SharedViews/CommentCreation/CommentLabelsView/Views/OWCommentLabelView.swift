//
//  OWCommentLabelView.swift
//  OpenWebSDK
//
//  Created by  Nogah Melamed on 15/12/2022.
//  Copyright © 2022 OpenWeb. All rights reserved.
//

import UIKit
import RxSwift

class OWCommentLabelView: UIView {
    fileprivate struct Metrics {
        static let identifier = "comment_label_id"
        static let labelIdentifier = "comment_label_label_id"
        static let cornerRaius: CGFloat = 3
        static let horizontalMargin: CGFloat = 10.0
        static let iconImageHeight: CGFloat = 24.0
        static let iconImageWidth: CGFloat = 14.0
        static let iconTrailingOffset: CGFloat = 5.0
        static var opacityDarkMode: CGFloat = 0.2
        static var opacityLightMode: CGFloat = 0.1
        static var selectedOpacityDarkMode: CGFloat = 0.7
        static var selectedOpacityLightMode: CGFloat = 1
        static var borderOpacityDarkMode: CGFloat = 0.7
        static var borderOpacityLightMode: CGFloat = 0.4
    }

    fileprivate lazy var labelContainer: UIView = {
        return UIView()
            .userInteractionEnabled(true)
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
            .font(OWFontBook.shared.font(typography: .bodyInteraction))
    }()
    fileprivate lazy var tapGesture: UITapGestureRecognizer = {
        let tapGesture = UITapGestureRecognizer()
        labelContainer.addGestureRecognizer(tapGesture)
        return tapGesture
    }()

    fileprivate var viewModel: OWCommentLabelViewModeling!
    fileprivate var disposeBag: DisposeBag!

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        applyAccessibility()
    }

    func configure(viewModel: OWCommentLabelViewModeling) {
        self.viewModel = viewModel
        disposeBag = DisposeBag()
        setupObservers()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

fileprivate extension OWCommentLabelView {
    func applyAccessibility() {
        self.accessibilityIdentifier = Metrics.identifier
        label.accessibilityIdentifier = Metrics.labelIdentifier
    }

    func setupUI() {
        addSubviews(labelContainer)
        labelContainer.OWSnp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        labelContainer.addSubview(label)
        label.OWSnp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.trailing.equalToSuperview().offset(-Metrics.horizontalMargin)
        }

        labelContainer.addSubview(iconImageView)
        iconImageView.OWSnp.makeConstraints { make in
            make.width.equalTo(Metrics.iconImageWidth)
            make.height.equalTo(Metrics.iconImageHeight)
            make.centerY.equalTo(label)
            make.leading.equalToSuperview().offset(Metrics.horizontalMargin)
            make.trailing.equalTo(label.OWSnp.leading).offset(-Metrics.iconTrailingOffset)
        }
    }

    func setupObservers() {
        let commentLabelSettingsObservable = viewModel.outputs.commentLabelSettings
            .share(replay: 1)

        commentLabelSettingsObservable
            .map { $0.iconUrl }
            .subscribe(onNext: { [weak self] url in
                guard let self = self else { return }
                self.iconImageView.setImage(with: url) { [weak self] image, _ in
                    self?.iconImageView.image = image?.withRenderingMode(.alwaysTemplate)
                }
            })
            .disposed(by: disposeBag)

        commentLabelSettingsObservable
            .map { $0.text }
            .bind(to: self.label.rx.text)
            .disposed(by: disposeBag)

        let labelDataObservable = Observable.combineLatest(viewModel.outputs.state, commentLabelSettingsObservable)

        OWSharedServicesProvider.shared.themeStyleService()
            .style
            .withLatestFrom(labelDataObservable) { style, data -> (OWThemeStyle, OWLabelState, UIColor) in
                return (style, data.0, data.1.color)
            }
            .subscribe { [weak self] style, state, color in
                guard let self = self else { return }
                self.setUIColors(state: state, labelColor: color, currentStyle: style)
            }
            .disposed(by: disposeBag)

        tapGesture.rx.event.voidify()
            .bind(to: viewModel.inputs.labelClicked)
            .disposed(by: disposeBag)

        OWSharedServicesProvider.shared.appLifeCycle()
            .didChangeContentSizeCategory
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.label.font = OWFontBook.shared.font(typography: .bodyInteraction)
            })
            .disposed(by: disposeBag)
    }

    func setUIColors(state: OWLabelState, labelColor: UIColor, currentStyle: OWThemeStyle) {
        // set background, border, image and text colors according to state
        let isDarkMode = currentStyle == .dark
        switch state {
            case .notSelected:
                labelContainer.backgroundColor = .clear
                labelContainer.layer.borderWidth = 1
                labelContainer.layer.borderColor = labelColor.withAlphaComponent(isDarkMode ? Metrics.borderOpacityDarkMode : Metrics.borderOpacityLightMode).cgColor
                iconImageView.tintColor = labelColor
                label.textColor = labelColor

            case .selected:
                labelContainer.backgroundColor = labelColor.withAlphaComponent(isDarkMode ? Metrics.selectedOpacityDarkMode : Metrics.selectedOpacityLightMode)
                labelContainer.layer.borderWidth = 0
                iconImageView.tintColor = .white
                label.textColor = .white

            case .readOnly:
                labelContainer.backgroundColor = labelColor.withAlphaComponent(isDarkMode ? Metrics.opacityDarkMode : Metrics.opacityLightMode)
                labelContainer.layer.borderWidth = 0
                iconImageView.tintColor = labelColor
                label.textColor = labelColor

        }
    }
}
