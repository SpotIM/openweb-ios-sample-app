//
//  TestingPlaygroundVC.swift
//  Spot-IM.Development
//
//  Created by Alon Haiut on 20/04/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

import UIKit
import RxSwift
import RxCocoa
import SnapKit

#if BETA

class TestingPlaygroundVC: UIViewController {

    fileprivate struct Metrics {
        static let identifier = "testing_playground_vc_id"
        static let btnPlaygroundPushModeIdentifier = "btn_playground_push_mode_id"
        static let btnPlaygroundPresentModeIdentifier = "btn_playground_present_mode_id"
        static let btnPlaygroundIndependentModeIdentifier = "btn_playground_independent_mode_id"
        static let verticalMargin: CGFloat = 40
        static let horizontalMargin: CGFloat = 50
        static let buttonHeight: CGFloat = 50
    }

    fileprivate let viewModel: TestingPlaygroundViewModeling
    fileprivate let disposeBag = DisposeBag()

    fileprivate lazy var scrollView: UIScrollView = {
        var scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()

    fileprivate lazy var btnPlaygroundPushMode: UIButton = {
        return NSLocalizedString("PlaygroundPushMode", comment: "").blueRoundedButton
    }()

    fileprivate lazy var btnPlaygroundPresentMode: UIButton = {
        return NSLocalizedString("PlaygroundPresentMode", comment: "").blueRoundedButton
    }()

    fileprivate lazy var btnPlaygroundIndependentMode: UIButton = {
        return NSLocalizedString("PlaygroundIndependentMode", comment: "").blueRoundedButton
    }()

    init(viewModel: TestingPlaygroundViewModeling) {
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
        setupObservers()
    }
}

fileprivate extension TestingPlaygroundVC {
    func applyAccessibility() {
        view.accessibilityIdentifier = Metrics.identifier
        btnPlaygroundPushMode.accessibilityIdentifier = Metrics.btnPlaygroundPushModeIdentifier
        btnPlaygroundPresentMode.accessibilityIdentifier = Metrics.btnPlaygroundPresentModeIdentifier
        btnPlaygroundIndependentMode.accessibilityIdentifier = Metrics.btnPlaygroundIndependentModeIdentifier
    }

    func setupViews() {
        view.backgroundColor = ColorPalette.shared.color(type: .background)

        // Adding scroll view
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide)
        }

        // Adding buttons
        scrollView.addSubview(btnPlaygroundPushMode)
        btnPlaygroundPushMode.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.height.equalTo(Metrics.buttonHeight)
            make.leading.equalToSuperview().offset(Metrics.horizontalMargin)
            make.top.equalTo(scrollView.contentLayoutGuide).offset(Metrics.verticalMargin)
        }

        scrollView.addSubview(btnPlaygroundPresentMode)
        btnPlaygroundPresentMode.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.height.equalTo(Metrics.buttonHeight)
            make.leading.equalToSuperview().offset(Metrics.horizontalMargin)
            make.top.equalTo(btnPlaygroundPushMode.snp.bottom).offset(Metrics.verticalMargin)
        }

        scrollView.addSubview(btnPlaygroundIndependentMode)
        btnPlaygroundIndependentMode.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.height.equalTo(Metrics.buttonHeight)
            make.leading.equalToSuperview().offset(Metrics.horizontalMargin)
            make.top.equalTo(btnPlaygroundPresentMode.snp.bottom).offset(Metrics.verticalMargin)
            make.bottom.equalTo(scrollView.contentLayoutGuide).offset(-Metrics.verticalMargin)
        }
    }

    func setupObservers() {
        title = viewModel.outputs.title

        // Setting those in the VM for integration with the SDK
        viewModel.inputs.setNavigationController(self.navigationController)
        viewModel.inputs.setPresentationalVC(self)

        // Subscribing to buttons taps
        btnPlaygroundPushMode.rx.tap
            .bind(to: viewModel.inputs.playgroundPushModeTapped)
            .disposed(by: disposeBag)

        btnPlaygroundPresentMode.rx.tap
            .bind(to: viewModel.inputs.playgroundPresentModeTapped)
            .disposed(by: disposeBag)

        btnPlaygroundIndependentMode.rx.tap
            .bind(to: viewModel.inputs.playgroundIndependentModeTapped)
            .disposed(by: disposeBag)

        // Showing error if needed
        viewModel.outputs.showError
            .subscribe(onNext: { [weak self] message in
                self?.showError(message: message)
            })
            .disposed(by: disposeBag)

        viewModel.outputs.openTestingPlaygroundIndependent
            .subscribe(onNext: { [weak self] dataModel in
                guard let self = self else { return }
                let testingPlaygroundIndependentVM = TestingPlaygroundIndependentViewModel(dataModel: dataModel)
                let testingPlaygroundIndependentVC = TestingPlaygroundIndependentViewVC(viewModel: testingPlaygroundIndependentVM)
                self.navigationController?.pushViewController(testingPlaygroundIndependentVC, animated: true)
            })
            .disposed(by: disposeBag)
    }

    func showError(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

#endif
