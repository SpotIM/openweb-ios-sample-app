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
        static let verticalMainPadding: CGFloat = 18
        static let linesPadding: CGFloat = 10

        static let identifier = "error_state_view_id"
        static let headerIconIdentifier = "error_state_header_image_view_id"
        static let retryIconIdentifier = "error_state_retry_image_view_id"
        static let titleLabelIdentifier = "error_state_title_label_id"
        static let ctaLabelIdentifier = "error_state_cta_label_id"
        static let ctaViewIdentifier = "error_state_cta_view_id"
    }

    fileprivate var disposeBag = DisposeBag()
    fileprivate var viewModel: OWErrorStateViewViewModeling!

    fileprivate lazy var headerIcon: UIImageView = {
       return UIImageView()
            .contentMode(.scaleAspectFit)
            .wrapContent()
            .image(UIImage(spNamed: "errorStateIcon", supportDarkMode: true)!)
    }()

    fileprivate lazy var retryIcon: UIImageView = {
       return UIImageView()
            .contentMode(.scaleAspectFit)
            .wrapContent()
            .image(UIImage(spNamed: "errorStateRetryIcon", supportDarkMode: true)!)
    }()

    fileprivate lazy var titleLabel: UILabel = {
       return UILabel()
            .font(OWFontBook.shared.font(typography: .footnoteText, forceOpenWebFont: false))
            .text(viewModel.outputs.title)
            .textAlignment(.center)
            .enforceSemanticAttribute()
    }()

    fileprivate lazy var ctaLabel: UILabel = {
       return UILabel()
            .attributedText(viewModel.outputs.tryAgainText)
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

        setupViews()
        setupObservers()
        applyAccessibility()
    }

    init() {
        super.init(frame: .zero)
    }

    // Only when using ErrorStateView as a cell
    func configure(with viewModel: OWErrorStateViewViewModeling) {
        self.viewModel = viewModel
        self.disposeBag = DisposeBag()
        self.setupViews()
        self.setupObservers()
        self.applyAccessibility()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

fileprivate extension OWErrorStateView {
    func setupViews() {
        self.corner(radius: Metrics.borderRadius)

        addSubview(headerIcon)
        headerIcon.OWSnp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().inset(Metrics.verticalMainPadding)
        }

        addSubview(titleLabel)
        titleLabel.OWSnp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(headerIcon).inset(Metrics.linesPadding)
        }

        ctaView.addSubviews(ctaLabel, retryIcon)

        ctaLabel.OWSnp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
            make.trailing.equalTo(retryIcon)
        }

        retryIcon.OWSnp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.trailing.equalToSuperview()
        }

        addSubview(ctaView)
        ctaView.OWSnp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(titleLabel).inset(Metrics.linesPadding)
            make.bottom.equalToSuperview().inset(Metrics.verticalMainPadding)
        }
    }

    func setupObservers() {
        OWSharedServicesProvider.shared.themeStyleService()
            .style
            .subscribe(onNext: { [weak self] currentStyle in
                guard let self = self else { return }
                self.border(width: Metrics.borderWidth, color: OWColorPalette.shared.color(type: .borderColor2, themeStyle: currentStyle))
                self.titleLabel.textColor(OWColorPalette.shared.color(type: .textColor3, themeStyle: currentStyle))
            })
            .disposed(by: disposeBag)

        ctaTapGesture.rx.event
            .voidify()
            .bind(to: viewModel.inputs.tryAgainTapped)
            .disposed(by: disposeBag)
    }

    func applyAccessibility() {
        self.accessibilityIdentifier = Metrics.identifier
        headerIcon.accessibilityIdentifier = Metrics.headerIconIdentifier
        retryIcon.accessibilityIdentifier = Metrics.retryIconIdentifier
        titleLabel.accessibilityIdentifier = Metrics.titleLabelIdentifier
        ctaLabel.accessibilityIdentifier = Metrics.ctaLabelIdentifier
        ctaView.accessibilityIdentifier = Metrics.ctaViewIdentifier
    }
}
