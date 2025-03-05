//
//  SingleAdExampleVC.swift
//  OpenWeb-SampleApp
//
//  Created by Anael on 26/11/2024.
//

import Foundation
import UIKit
import Combine

class SingleAdExampleVC: UIViewController {
    private struct Metrics {
        static let identifier = "uiviews_monetization_independent_example_id"
        static let adViewIdentifier = "social_monetization_ad_view_id"
        static let loggerHeight: CGFloat = 0.3 * (UIApplication.shared.delegate?.window??.screen.bounds.height ?? 800)
        static let adViewTopMargin: CGFloat = 16
        static let adViewHorizontalMargin: CGFloat = -16
    }

    private let viewModel: SingleAdExampleViewModeling
    private var cancellables = Set<AnyCancellable>()

    private lazy var loggerView: UILoggerView = {
        return UILoggerView(viewModel: viewModel.outputs.loggerViewModel)
    }()

    init(viewModel: SingleAdExampleViewModeling) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        super.loadView()
        applyAccessibility()
        setupViews()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupObservers()
    }
}

private extension SingleAdExampleVC {
    func applyAccessibility() {
        view.accessibilityIdentifier = Metrics.identifier
    }

    func setupViews() {
        view.backgroundColor = ColorPalette.shared.color(type: .background)
        self.navigationItem.largeTitleDisplayMode = .never

        self.view.addSubview(self.loggerView)
        self.loggerView.snp.makeConstraints { make in
            make.top.equalTo(self.view.layoutMarginsGuide.snp.top)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(Metrics.loggerHeight)
        }
    }

    func setupObservers() {
        title = viewModel.outputs.title

        viewModel.outputs.adView
            .receive(on: DispatchQueue.main)
            .sink { [weak self] adView in
                guard let self else { return }
                view.addSubview(adView)
                adView.snp.makeConstraints { make in
                    make.top.equalTo(self.loggerView.snp.bottom).offset(Metrics.adViewTopMargin)
                    make.centerX.equalToSuperview()
                    make.width.equalToSuperview().offset(Metrics.adViewHorizontalMargin)
                }
                adView.accessibilityIdentifier = Metrics.adViewIdentifier
            }
            .store(in: &cancellables)
    }
}
