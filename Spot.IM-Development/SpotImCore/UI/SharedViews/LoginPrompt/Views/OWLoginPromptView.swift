//
//  OWLoginPromptView.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 17/10/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

class OWLoginPromptView: UIView {
    fileprivate struct Metrics {
        static let identifier = "login_promt_view_id"

        static let labelHorizontalPadding: CGFloat = 4
    }

    fileprivate lazy var icon: UIImageView = {
       return UIImageView()
            .contentMode(.scaleAspectFit)
            .wrapContent()
            .image(UIImage(spNamed: "loginPromptIcon", supportDarkMode: false)!)
            .tintColor(OWColorPalette.shared.color(type: .brandColor, themeStyle: .light))
    }()

    fileprivate lazy var label: UILabel = {
        return UILabel()
            .attributedText(
                "Authorize to participate" // TODO: translations
                    .attributedString
                    .underline(1)
            )
            .font(OWFontBook.shared.font(typography: .bodyInteraction))
            .textColor(OWColorPalette.shared.color(type: .brandColor, themeStyle: .light))
    }()

    fileprivate lazy var arrow: UIImageView = {
        return UIImageView()
            .contentMode(.scaleAspectFit)
            .wrapContent()
            .image(UIImage(spNamed: "loginPromptArrow", supportDarkMode: false)!)
            .tintColor(OWColorPalette.shared.color(type: .brandColor, themeStyle: .light))
    }()

    fileprivate lazy var tapGesture: UITapGestureRecognizer = {
        let tap = UITapGestureRecognizer()
        self.addGestureRecognizer(tap)
        self.isUserInteractionEnabled = true

        return tap
    }()

    fileprivate var zeroHeighConstraint: OWConstraint? = nil

    fileprivate var viewModel: OWLoginPromptViewModeling
    fileprivate var disposeBag: DisposeBag

    init(with viewModel: OWLoginPromptViewModeling) {
        self.viewModel = viewModel
        self.disposeBag = DisposeBag()
        super.init(frame: .zero)
        setupUI()
        setupObservers()
        applyAccessibility()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

fileprivate extension OWLoginPromptView {
    func setupUI() {
        self.OWSnp.makeConstraints { make in
            zeroHeighConstraint = make.height.equalTo(0).constraint
        }
        zeroHeighConstraint?.isActive = false

        self.addSubview(icon)
        icon.OWSnp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview()
        }

        self.addSubview(label)
        label.OWSnp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.equalTo(icon.OWSnp.trailing).offset(Metrics.labelHorizontalPadding)
        }

        self.addSubview(arrow)
        arrow.OWSnp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(label.OWSnp.trailing).offset(Metrics.labelHorizontalPadding)
            make.trailing.equalToSuperview()
        }
    }

    func setupObservers() {
        viewModel.outputs.shouldShowView
            .map { !$0 }
            .bind(to: self.rx.isHidden)
            .disposed(by: disposeBag)

        if let constraint = zeroHeighConstraint {
            viewModel.outputs.shouldShowView
                .map { !$0 }
                .bind(to: constraint.rx.isActive)
                .disposed(by: disposeBag)
        }

        tapGesture.rx.event
            .voidify()
            .bind(to: viewModel.inputs.loginPromptTap)
            .disposed(by: disposeBag)

        OWSharedServicesProvider.shared.appLifeCycle()
            .didChangeContentSizeCategory
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.label.font = OWFontBook.shared.font(typography: .bodyInteraction)
            })
            .disposed(by: disposeBag)
    }

    func applyAccessibility() {
        self.accessibilityIdentifier = Metrics.identifier
    }
}
