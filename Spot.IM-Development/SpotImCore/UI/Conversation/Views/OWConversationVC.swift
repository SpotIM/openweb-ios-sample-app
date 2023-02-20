//
//  OWConversationVC.swift
//  SpotImCore
//
//  Created by Alon Haiut on 06/07/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class OWConversationVC: UIViewController {
    fileprivate struct Metrics {

    }

    fileprivate let viewModel: OWConversationViewModeling
    fileprivate let disposeBag = DisposeBag()

    fileprivate lazy var conversationView: OWConversationView = {
        let conversationView = OWConversationView(viewModel: viewModel.outputs.conversationViewVM)
        return conversationView
    }()

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(viewModel: OWConversationViewModeling) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    override func loadView() {
        super.loadView()
        setupViews()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.inputs.viewDidLoad.onNext()
    }
}

fileprivate extension OWConversationVC {
    func setupViews() {
        view.addSubview(conversationView)
        conversationView.OWSnp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
