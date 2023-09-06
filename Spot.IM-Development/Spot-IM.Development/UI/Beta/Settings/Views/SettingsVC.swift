//
//  SettingsVC.swift
//  Spot-IM.Development
//
//  Created by Revital Pisman on 18/12/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import UIKit
import RxSwift

#if NEW_API

class SettingsVC: UIViewController {

    fileprivate struct Metrics {
        static let identifier = "settings_vc_id"
        static let verticalOffset: CGFloat = 40
        static let verticalBetweenSettingViewsOffset: CGFloat = 80
    }

    fileprivate lazy var scrollView: UIScrollView = {
        var scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()

    fileprivate lazy var settingViews: [UIView] = {
        let views = viewModel.outputs.settingsVMs.map { SettingsViewsFactory.factor(from: ($0)) }.unwrap()
        return views
    }()

    fileprivate let viewModel: SettingsViewModeling
    fileprivate let disposeBag = DisposeBag()

    init(viewModel: SettingsViewModeling) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        super.loadView()
        setupViews()
        applyAccessibility()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

fileprivate extension SettingsVC {
    func applyAccessibility() {
        view.accessibilityIdentifier = Metrics.identifier
    }

    func setupViews() {
        view.backgroundColor = ColorPalette.shared.color(type: .background)
        applyLargeTitlesIfNeeded()

        title = viewModel.outputs.title

        // Adding scroll view
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.top.equalToSuperview()
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide)
        }

        var previousView: UIView? = nil
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

        // keyboard will show
        NotificationCenter.default.rx
            .notification(UIResponder.keyboardWillShowNotification)
            .subscribe(onNext: { [weak self] notification in
                guard
                    let self = self,
                    let expandedKeyboardHeight = notification.keyboardSize?.height,
                    let animationDuration = notification.keyboardAnimationDuration
                    else { return }
                self.scrollView.snp.updateConstraints { make in
                    make.bottom.equalToSuperview().offset(-expandedKeyboardHeight)
                }
                UIView.animate(withDuration: animationDuration) { [weak self] in
                    guard let self = self else { return }
                    self.view.layoutIfNeeded()
                } completion: { finished in
                    if finished,
                       let firstResponder = self.view.firstResponder {
                        self.scrollToView(toView: firstResponder)
                    }
                }
            })
            .disposed(by: disposeBag)

        // keyboard will hide
        NotificationCenter.default.rx
            .notification(UIResponder.keyboardWillHideNotification)
            .voidify()
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.scrollView.snp.updateConstraints { make in
                    make.bottom.equalToSuperview()
                }
            })
            .disposed(by: disposeBag)
    }

    func scrollToView(toView: UIView) {
        if let origin = toView.superview {
            // Get the Y position of your child view
            let childStartPoint = origin.convert(toView.frame.origin, to: scrollView)
            scrollView.setContentOffset(CGPoint(x: 0, y: childStartPoint.y - self.view.frame.height / 3), animated: true)
        }
    }
}

#endif
