//
//  IndependentMonetizationExampleVC.swift
//  OpenWeb-SampleApp
//
//  Created by Anael on 26/11/2024.
//

import Foundation
import UIKit
import RxSwift

class IndependentMonetizationExampleVC: UIViewController {
    private struct Metrics {
        static let identifier = "uiviews_monetization_independent_example_id"
    }

    private let viewModel: IndependentMonetizationExampleViewModeling
    private let disposeBag = DisposeBag()

    init(viewModel: IndependentMonetizationExampleViewModeling) {
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

private extension IndependentMonetizationExampleVC {
    func applyAccessibility() {
        view.accessibilityIdentifier = Metrics.identifier
    }
    
    func setupViews() {
        view.backgroundColor = ColorPalette.shared.color(type: .background)
        self.navigationItem.largeTitleDisplayMode = .never
    }
    
    func setupObservers() {
        title = viewModel.outputs.title
        
        viewModel.outputs.showAdView
            .observe(on: MainScheduler.instance)
            .subscribe { [weak self] adView in
                guard let self else { return }
                view.addSubview(adView)
                adView.backgroundColor = .red
                adView.snp.makeConstraints { make in
                    make.top.equalTo(self.view.layoutMarginsGuide.snp.top)
                    make.centerX.equalToSuperview()
                    make.width.equalToSuperview().offset(-16)
                }
            }
            .disposed(by: disposeBag)
    }
}
