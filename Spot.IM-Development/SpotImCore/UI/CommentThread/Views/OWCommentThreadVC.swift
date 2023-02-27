//
//  OWCommentThreadVC.swift
//  SpotImCore
//
//  Created by Alon Shprung on 30/01/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class OWCommentThreadVC: UIViewController {
    fileprivate struct Metrics {

    }

    fileprivate let viewModel: OWCommentThreadViewModeling
    fileprivate let disposeBag = DisposeBag()

    fileprivate lazy var commentThreadView: OWCommentThreadView = {
        let commentThreadView = OWCommentThreadView(viewModel: viewModel.outputs.commentThreadViewVM)
        return commentThreadView
    }()

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(viewModel: OWCommentThreadViewModeling) {
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

fileprivate extension OWCommentThreadVC {
    func setupViews() {
        view.addSubview(commentThreadView)
        commentThreadView.OWSnp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
