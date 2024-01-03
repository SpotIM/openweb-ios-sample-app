//
//  ColorsCustomizationVC.swift
//  Spot-IM.Development
//
//  Created by  Nogah Melamed on 31/12/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

@available(iOS 14.0, *)
class ColorsCustomizationVC: UIViewController {
    fileprivate struct Metrics {
        static let horizontalOffset: CGFloat = 40
        static let verticalOffset: CGFloat = 24
        static let stackViewSpacing: CGFloat = 20
    }

    fileprivate let viewModel: ColorsCustomizationViewModeling
    fileprivate let disposeBag = DisposeBag()

    fileprivate lazy var scrollView: UIScrollView = {
        return UIScrollView()
    }()

    fileprivate lazy var explainLabel: UILabel = {
        let label = UILabel()
        label.font = FontBook.paragraphBold
        label.text = "Both light and dark colors should be set in order to override OWTheme"
        label.numberOfLines = 0
        return label
    }()

    fileprivate lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.spacing = Metrics.stackViewSpacing
        return stackView
    }()

    init(viewModel: ColorsCustomizationViewModeling) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        super.loadView()
        setupViews()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupObservers()
    }
}

@available(iOS 14.0, *)
fileprivate extension ColorsCustomizationVC {
    func setupViews() {
        view.backgroundColor = ColorPalette.shared.color(type: .background)
        applyLargeTitlesIfNeeded()

        title = viewModel.outputs.title

        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide)
        }

        scrollView.addSubview(explainLabel)
        explainLabel.snp.makeConstraints { make in
            make.top.equalTo(scrollView.contentLayoutGuide).offset(Metrics.horizontalOffset)
            make.leading.equalTo(scrollView).inset(Metrics.verticalOffset)
            make.trailing.equalTo(view.safeAreaLayoutGuide).inset(Metrics.verticalOffset)
        }

        scrollView.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.top.equalTo(explainLabel.snp.bottom).offset(Metrics.horizontalOffset)
            make.bottom.equalTo(scrollView.contentLayoutGuide).inset(Metrics.horizontalOffset)
            make.leading.trailing.equalTo(scrollView)
        }

        viewModel.outputs.colorItemsVM.forEach { vm in
            let view = ColorSelectionItemView(viewModel: vm)
            stackView.addArrangedSubview(view)
        }
    }

    func setupObservers() {
        viewModel.outputs.openPicker
            .subscribe(onNext: { [weak self] picker in
                self?.showPicker(picker: picker)
            })
            .disposed(by: disposeBag)
    }

    func showPicker(picker: UIColorPickerViewController) {
        self.present(picker, animated: true)
    }
}
