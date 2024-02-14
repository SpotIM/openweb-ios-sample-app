//
//  MiscellaneousVC.swift
//  OpenWeb-Development
//
//  Created by Revital Pisman on 04/12/2022.
//  Copyright © 2022 OpenWeb. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

class MiscellaneousVC: UIViewController {

    fileprivate struct Metrics {
        static let identifier = "miscellaneous_vc_id"
        static let btnConversationCounterIdentifier = "btn_conversation_counter_id"
        static let verticalMargin: CGFloat = 40
        static let horizontalMargin: CGFloat = 50
        static let buttonHeight: CGFloat = 50
    }

    fileprivate let viewModel: MiscellaneousViewModeling
    fileprivate let disposeBag = DisposeBag()

    fileprivate lazy var scrollView: UIScrollView = {
        var scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()

    fileprivate lazy var btnConversationCounter: UIButton = {
        return NSLocalizedString("ConversationCounter", comment: "").blueRoundedButton
    }()

    init(viewModel: MiscellaneousViewModeling) {
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

fileprivate extension MiscellaneousVC {
    func applyAccessibility() {
        view.accessibilityIdentifier = Metrics.identifier
        btnConversationCounter.accessibilityIdentifier = Metrics.btnConversationCounterIdentifier
    }

    func setupViews() {
        view.backgroundColor = ColorPalette.shared.color(type: .background)
        self.navigationItem.largeTitleDisplayMode = .never

        // Adding scroll view
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide)
        }

        // Adding conversation counter button
        scrollView.addSubview(btnConversationCounter)
        btnConversationCounter.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.height.equalTo(Metrics.buttonHeight)
            make.leading.equalToSuperview().offset(Metrics.horizontalMargin)
            make.top.equalTo(scrollView.contentLayoutGuide).offset(Metrics.verticalMargin)

            // Move to last view in scroll view
            make.bottom.equalTo(scrollView.contentLayoutGuide).offset(-Metrics.verticalMargin)
        }
    }

    func setupObservers() {
        title = viewModel.outputs.title

        btnConversationCounter.rx.tap
            .bind(to: viewModel.inputs.conversationCounterTapped)
            .disposed(by: disposeBag)

        viewModel.outputs.openConversationCounters
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                let conversationCounterVM = ConversationCountersNewAPIViewModel()
                let conversationCounterVC = ConversationCountersNewAPIVC(viewModel: conversationCounterVM)
                self.navigationController?.pushViewController(conversationCounterVC, animated: true)
            })
            .disposed(by: disposeBag)
    }
}
