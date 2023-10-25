//
//  OWErrorStateView.swift
//  SpotImCore
//
//  Created by Refael Sommer on 10/09/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import RxSwift
import Foundation

class OWErrorStateView: UIView {
    fileprivate struct Metrics {
        static let borderWidth: CGFloat = 1
        static let borderRadius: CGFloat = 12
        static let verticalMainPadding: CGFloat = 12
        static let ctaHorizontalPadding: CGFloat = 4
        static let ctaVerticalPadding: CGFloat = 5
        static let linesPadding: CGFloat = 10
        static let headerIconSize: CGFloat = 36
        static let retryIconSize: CGFloat = 14

        static let identifier = "error_state_view_id"
        static let containerViewIdentifier = "error_state_container_view_id"
        static let headerIconIdentifier = "error_state_header_image_view_id"
        static let retryIconIdentifier = "error_state_retry_image_view_id"
        static let titleLabelIdentifier = "error_state_title_label_id"
        static let ctaLabelIdentifier = "error_state_cta_label_id"
        static let ctaViewIdentifier = "error_state_cta_view_id"
    }

    fileprivate var disposeBag = DisposeBag()
    fileprivate var viewModel: OWErrorStateViewViewModeling!

    fileprivate lazy var containerView: UIView = {
       return UIView()
            .backgroundColor(.clear)
    }()

    fileprivate lazy var headerIcon: UIImageView = {
       return UIImageView()
            .contentMode(.scaleAspectFit)
            .image(UIImage(spNamed: "errorStateIcon", supportDarkMode: false)!)
    }()

    fileprivate lazy var retryIcon: UIImageView = {
       return UIImageView()
            .contentMode(.scaleAspectFit)
            .image(UIImage(spNamed: "errorStateRetryIcon", supportDarkMode: false)!)
    }()

    fileprivate lazy var titleLabel: UILabel = {
       return UILabel()
            .font(OWFontBook.shared.font(typography: .footnoteLink, forceOpenWebFont: false))
            .textAlignment(.center)
            .enforceSemanticAttribute()
    }()

    fileprivate lazy var ctaLabel: UILabel = {
       return UILabel()
            .enforceSemanticAttribute()
    }()

    fileprivate lazy var ctaView: UIView = {
        let tryAgainView = UIView()
            .backgroundColor(.clear)
        tryAgainView.addGestureRecognizer(ctaTapGesture)
        return tryAgainView
    }()

    fileprivate lazy var ctaTapGesture: UITapGestureRecognizer = {
        return UITapGestureRecognizer()
    }()

    init(with viewModel: OWErrorStateViewViewModeling) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        self.setupUI()
        self.applyAccessibility()
        self.setupObservers()
    }

    init() {
        super.init(frame: .zero)
        self.setupUI()
        self.applyAccessibility()
    }

    // Only when using ErrorStateView as a cell
    func configure(with viewModel: OWErrorStateViewViewModeling) {
        self.viewModel = viewModel
        self.disposeBag = DisposeBag()
        self.setupObservers()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

fileprivate extension OWErrorStateView {
    func setupUI() {
        self.corner(radius: Metrics.borderRadius)

        addSubview(containerView)
        containerView.OWSnp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.centerY.equalToSuperview()
        }

        containerView.addSubview(headerIcon)
        headerIcon.OWSnp.makeConstraints { make in
            make.size.equalTo(Metrics.headerIconSize)
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().inset(Metrics.verticalMainPadding)
        }

        containerView.addSubview(titleLabel)
        titleLabel.OWSnp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(headerIcon.OWSnp.bottom).offset(Metrics.linesPadding)
        }

        ctaView.addSubviews(ctaLabel, retryIcon)

        ctaLabel.OWSnp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.bottom.top.equalToSuperview().inset(Metrics.ctaVerticalPadding)
        }

        retryIcon.OWSnp.makeConstraints { make in
            make.leading.equalTo(ctaLabel.OWSnp.trailing).offset(Metrics.ctaHorizontalPadding)
            make.size.equalTo(Metrics.retryIconSize)
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview()
        }

        containerView.addSubview(ctaView)
        ctaView.OWSnp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(titleLabel.OWSnp.bottom).offset(Metrics.linesPadding)
            make.bottom.equalToSuperview().inset(Metrics.verticalMainPadding)
        }

        self.OWSnp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(containerView.OWSnp.height)
            make.height.greaterThanOrEqualTo(0)
        }
    }

    func setupObservers() {
        self.titleLabel.text(viewModel.outputs.title)
        self.ctaLabel.attributedText(viewModel.outputs.tryAgainText)

        OWSharedServicesProvider.shared.themeStyleService()
            .style
            .subscribe(onNext: { [weak self] currentStyle in
                guard let self = self else { return }
                let borderColor: UIColor = self.viewModel.outputs.shouldHaveBorder ? OWColorPalette.shared.color(type: .borderColor2, themeStyle: currentStyle) : .clear
                self.border(width: Metrics.borderWidth, color: borderColor)
                self.ctaLabel.textColor(OWColorPalette.shared.color(type: .textColor7, themeStyle: currentStyle))
                self.titleLabel.textColor(OWColorPalette.shared.color(type: .textColor3, themeStyle: currentStyle))
            })
            .disposed(by: disposeBag)

        ctaTapGesture.rx.event
            .voidify()
            .bind(to: viewModel.inputs.tryAgainTap)
            .disposed(by: disposeBag)

        viewModel.outputs.height
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] newHeight in
                guard let self = self else { return }
                self.OWSnp.updateConstraints { make in
                    // We use here greaterThen since the default newHeight is 0 in this constraint
                    // So that it will be tied to the components constraints inside this view
                    // When the newHeight is larger then the components constraints need
                    // they will be centered and the view will be larger and constraint to
                    // the size of newHeight
                    make.height.greaterThanOrEqualTo(newHeight)
                }
                self.layoutIfNeeded()
            })
            .disposed(by: disposeBag)

        OWSharedServicesProvider.shared.appLifeCycle()
            .didChangeContentSizeCategory
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.titleLabel.font = OWFontBook.shared.font(typography: .footnoteLink)
                self.ctaLabel.attributedText = self.viewModel.outputs.tryAgainText
            })
            .disposed(by: disposeBag)
    }

    func applyAccessibility() {
        self.accessibilityIdentifier = Metrics.identifier
        containerView.accessibilityIdentifier = Metrics.containerViewIdentifier
        headerIcon.accessibilityIdentifier = Metrics.headerIconIdentifier
        retryIcon.accessibilityIdentifier = Metrics.retryIconIdentifier
        titleLabel.accessibilityIdentifier = Metrics.titleLabelIdentifier
        ctaLabel.accessibilityIdentifier = Metrics.ctaLabelIdentifier
        ctaView.accessibilityIdentifier = Metrics.ctaViewIdentifier
    }
}
