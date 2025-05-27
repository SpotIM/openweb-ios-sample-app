//
//  SettingsVC.swift
//  OpenWeb-Development
//
//  Created by Revital Pisman on 18/12/2022.
//  Copyright © 2022 OpenWeb. All rights reserved.
//

import UIKit
import Combine
import CombineCocoa

class SettingsVC: UIViewController {

    private struct Metrics {
        static let identifier = "settings_vc_id"
        static let resetButtonId = "settings_reset_button_id"
        static let verticalOffset: CGFloat = 40
        static let verticalBetweenSettingViewsOffset: CGFloat = 80
        static let resetButtonHeight: CGFloat = 50
        static let resetButtonVerticalPadding: CGFloat = 20
    }

    private lazy var scrollView: UIScrollView = {
        var scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()

    private lazy var resetButton: UIButton = {
        return NSLocalizedString("ResetToDefaults", comment: "")
            .blueRoundedButton
    }()

    private lazy var settingViews: [UIView] = {
        let views = viewModel.outputs.settingsVMs.map { SettingsViewsFactory.factor(from: ($0)) }.unwrap()
        return views
    }()

    private let viewModel: SettingsViewModeling
    private var cancellables = Set<AnyCancellable>()

    init(viewModel: SettingsViewModeling) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        setupObservers()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        super.loadView()
        setupViews()
        applyAccessibility()
    }
}

private extension SettingsVC {
    func applyAccessibility() {
        view.accessibilityIdentifier = Metrics.identifier
        resetButton.accessibilityIdentifier = Metrics.resetButtonId
    }

    @objc func setupViews() {
        view.backgroundColor = ColorPalette.shared.color(type: .background)
        applyLargeTitlesIfNeeded()

        title = viewModel.outputs.title

        view.addSubview(resetButton)
        resetButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(Metrics.resetButtonVerticalPadding)
            make.height.equalTo(Metrics.resetButtonHeight)
        }

        // Adding scroll view
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.bottom.equalTo(resetButton.snp.top).offset(-Metrics.resetButtonVerticalPadding)
            make.top.equalToSuperview()
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide)
        }

        var previousView: UIView?
        for (index, settingsView) in settingViews.enumerated() {
            scrollView.addSubview(settingsView)
            settingsView.snp.makeConstraints { make in
                make.leading.trailing.equalTo(view.safeAreaLayoutGuide)
                if let topView = previousView {
                    // This is an intermidiate settingsView, Set the top constraint to previous settingsView
                    make.top.equalTo(topView.snp.bottom).offset(Metrics.verticalBetweenSettingViewsOffset)
                } else {
                    // Telling the scroll view that this is the first settingsView
                    make.top.equalTo(scrollView.contentLayoutGuide).offset(Metrics.verticalOffset)
                }
                if index == settingViews.count - 1 {
                    // Telling the scroll view that this is the last settingsView
                    make.bottom.equalTo(scrollView.contentLayoutGuide).offset(-Metrics.verticalOffset)
                }
                previousView = settingsView
            }
        }
    }

    func scrollToView(toView: UIView) {
        if let origin = toView.superview {
            // Get the Y position of your child view
            let childStartPoint = origin.convert(toView.frame.origin, to: scrollView)
            // swiftlint:disable:next no_magic_numbers
            scrollView.setContentOffset(CGPoint(x: 0, y: childStartPoint.y - self.view.frame.height / 3), animated: true)
        }
    }

    func setupObservers() {
        resetButton.tapPublisher
            .bind(to: viewModel.inputs.resetToDefaultTap)
            .store(in: &cancellables)

        // keyboard will show
        NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
            .sink { [weak self] notification in
                guard
                    let self,
                    let expandedKeyboardHeight = notification.keyboardSize?.height,
                    let animationDuration = notification.keyboardAnimationDuration
                    else { return }
                self.resetButton.snp.updateConstraints { make in
                    make.bottom.equalToSuperview().offset(-expandedKeyboardHeight)
                }
                UIView.animate(withDuration: animationDuration) { [weak self] in
                    guard let self else { return }
                    self.view.layoutIfNeeded()
                } completion: { [weak self] finished in
                    guard let self else { return }
                    if finished,
                       let firstResponder = self.view.firstResponder {
                        self.scrollToView(toView: firstResponder)
                    }
                }
            }
            .store(in: &cancellables)

        // keyboard will hide
        NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
            .sink { [weak self] _ in
                guard let self else { return }
                self.resetButton.snp.updateConstraints { make in
                    make.bottom.equalToSuperview().offset(-Metrics.resetButtonVerticalPadding)
                }
            }
            .store(in: &cancellables)
    }
}
