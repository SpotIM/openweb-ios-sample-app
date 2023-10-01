//
//  OWRealtimeIndicationView.swift
//  SpotImCore
//
//  Created by Revital Pisman on 02/08/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import UIKit
import RxSwift

class OWRealtimeIndicationView: UIView {
    fileprivate struct Metrics {
        static let containerShdowOpacity: Float = 0.20
        static let containerShdowRadius: CGFloat = 20
        static let viewsPadding: CGFloat = 10
        static let verticalSeparatorWidth: CGFloat = 1
        static let cornerRadiusDivisor: CGFloat = 2

        static let margins: UIEdgeInsets = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)

        static let identifier = "realtime_indication_view_id"
    }

    fileprivate lazy var typingView: OWRealtimeTypingView = {
        return OWRealtimeTypingView(viewModel: viewModel.outputs.realtimeTypingViewModel)
            .userInteractionEnabled(false)
    }()

    fileprivate lazy var newCommentsView: OWRealtimeNewCommentsView = {
        return OWRealtimeNewCommentsView(viewModel: viewModel.outputs.realtimeNewCommentsViewModel)
            .userInteractionEnabled(false)
    }()

    fileprivate lazy var container: UIView = {
        let view = UIView()
        let currentThemeStyle = OWSharedServicesProvider.shared.themeStyleService().currentStyle

        // Setup shadow
        view.apply(shadow: .custom(offset: .zero,
                                   opacity: Metrics.containerShdowOpacity,
                                   radius: Metrics.containerShdowRadius,
                                   color: OWColorPalette.shared.color(type: .shadowColor,
                                                                      themeStyle: currentThemeStyle)),
                   direction: .all)

        return view
            .userInteractionEnabled(true)
            .backgroundColor(OWColorPalette.shared.color(type: .backgroundColor2,
                                                         themeStyle: currentThemeStyle))
            .border(width: 1,
                    color: OWColorPalette.shared.color(type: .borderColor2,
                                                       themeStyle: currentThemeStyle))
            .enforceSemanticAttribute()
    }()

    fileprivate lazy var verticalSeparatorBetweenTypingAndNewComments: UIView = {
        return UIView()
            .backgroundColor(OWColorPalette.shared.color(type: .separatorColor2,
                                                         themeStyle: OWSharedServicesProvider.shared.themeStyleService().currentStyle))
    }()

    fileprivate lazy var tapGesture: UITapGestureRecognizer = {
        let tapGesture = UITapGestureRecognizer()
        container.addGestureRecognizer(tapGesture)
        return tapGesture
    }()

    fileprivate lazy var panGesture: UIPanGestureRecognizer = {
        let panGesture = UIPanGestureRecognizer()
        container.addGestureRecognizer(panGesture)
        return panGesture
    }()

    fileprivate lazy var stackView: UIStackView = {
        return UIStackView()
            .spacing(Metrics.viewsPadding)
            .axis(.horizontal)
            .userInteractionEnabled(false)
    }()

    fileprivate var viewModel: OWRealtimeIndicationViewModeling
    fileprivate let disposeBag = DisposeBag()

    init(viewModel: OWRealtimeIndicationViewModeling) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupUI()
        setupObservers()
        applyAccessibility()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let height = self.frame.size.height
        container.layer.cornerRadius = height / Metrics.cornerRadiusDivisor
    }
}

fileprivate extension OWRealtimeIndicationView {
    func setupUI() {
        layer.masksToBounds = false

        self.addSubview(container)
        container.OWSnp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        stackView.addArrangedSubview(typingView)
        stackView.addArrangedSubview(verticalSeparatorBetweenTypingAndNewComments)
        stackView.addArrangedSubview(newCommentsView)

        self.addSubview(stackView)
        stackView.OWSnp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(Metrics.margins.top)
            make.leading.trailing.equalToSuperview().inset(Metrics.margins.right)
        }

        verticalSeparatorBetweenTypingAndNewComments.OWSnp.makeConstraints { make in
            make.width.equalTo(Metrics.verticalSeparatorWidth)
        }
    }

    func setupObservers() {
        tapGesture.rx.event.voidify()
            .bind(to: viewModel.inputs.tap)
            .disposed(by: disposeBag)

        panGesture.rx.event
            .subscribe(onNext: { [weak self] recognizer in
                guard let self = self, let superView = self.superview else { return }

                switch recognizer.state {
                case .changed, .began:
                    let translation = recognizer.translation(in: superView)
                    self.viewModel.inputs.panHorisontalPositionDidChange.onNext(translation.x)

                case .ended:
                    self.viewModel.inputs.panHorisontalPositionChangeDidEnd.onNext()

                default:
                    break
                }
            })
            .disposed(by: disposeBag)

        let shouldShowTypingLabel = viewModel.outputs.shouldShowTypingLabel
        let shouldShowNewCommentsLabel = viewModel.outputs.shouldShowNewCommentsLabel

        shouldShowTypingLabel
            .map { !$0 }
            .bind(to: typingView.rx.isHiddenAnimated)
            .disposed(by: disposeBag)

        shouldShowNewCommentsLabel
            .map { !$0 }
            .bind(to: newCommentsView.rx.isHiddenAnimated)
            .disposed(by: disposeBag)

        Observable.combineLatest(shouldShowTypingLabel, shouldShowNewCommentsLabel)
            .map { shouldShowTypingLabel, shouldShowNewCommentsLabel -> Bool in
                return !(shouldShowTypingLabel && shouldShowNewCommentsLabel)
            }
            .bind(to: verticalSeparatorBetweenTypingAndNewComments.rx.isHidden)
            .disposed(by: disposeBag)

        OWSharedServicesProvider.shared.themeStyleService()
            .style
            .subscribe(onNext: { [weak self] currentStyle in
                guard let self = self else { return }
                self.container.backgroundColor = OWColorPalette.shared.color(type: .backgroundColor2, themeStyle: currentStyle)
                self.container.layer.borderColor = OWColorPalette.shared.color(type: .borderColor2, themeStyle: currentStyle).cgColor
                self.verticalSeparatorBetweenTypingAndNewComments.backgroundColor = OWColorPalette.shared.color(type: .separatorColor2,
                                                                                                                themeStyle: currentStyle)
            })
            .disposed(by: disposeBag)
    }

    func applyAccessibility() {
        self.accessibilityIdentifier = Metrics.identifier
    }
}
