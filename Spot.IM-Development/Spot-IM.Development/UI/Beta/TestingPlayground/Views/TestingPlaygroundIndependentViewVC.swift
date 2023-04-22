//
//  TestingPlaygroundIndependentViewVC.swift
//  Spot-IM.Development
//
//  Created by Alon Haiut on 20/04/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

#if BETA

class TestingPlaygroundIndependentViewVC: UIViewController {
    fileprivate struct Metrics {
        static let verticalMargin: CGFloat = 40
        static let loggerHeight: CGFloat = 0.3 * (UIApplication.shared.delegate?.window??.screen.bounds.height ?? 800)
        static let identifier = "testing_playground_independent_view_vc_id"
    }

    fileprivate let viewModel: TestingPlaygroundIndependentViewModeling
    fileprivate let disposeBag = DisposeBag()

    fileprivate lazy var contentView: UIView = {
        let view = UIView()
            .backgroundColor(.clear)
        return view
    }()

    fileprivate var testingPlaygroundView: UIView? = nil

    fileprivate lazy var loggerView: UILoggerView = {
        return UILoggerView(viewModel: viewModel.outputs.loggerViewModel)
    }()

    init(viewModel: TestingPlaygroundIndependentViewModeling) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
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

fileprivate extension TestingPlaygroundIndependentViewVC {
    func applyAccessibility() {
        view.accessibilityIdentifier = Metrics.identifier
    }

    func setupViews() {
        view.backgroundColor = ColorPalette.shared.color(type: .lightGrey)

        view.addSubview(loggerView)
        loggerView.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(Metrics.loggerHeight)
        }

        view.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide)
            make.top.equalTo(loggerView.snp.bottom)
        }
    }

    func setupObservers() {
        title = viewModel.outputs.title

        viewModel.outputs.testingPlaygroundView
            .subscribe(onNext: { [weak self] view in
                guard let self = self else { return }
                self.testingPlaygroundView = view
                self.contentView.addSubview(view)
                view.snp.makeConstraints { make in
                    make.edges.equalToSuperview()
                }
            })
            .disposed(by: disposeBag)
    }
}

#endif
