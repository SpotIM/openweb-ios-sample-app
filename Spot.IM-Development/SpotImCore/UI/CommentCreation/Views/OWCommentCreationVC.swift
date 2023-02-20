//
//  OWCommentCreationVC.swift
//  SpotImCore
//
//  Created by Alon Shprung on 05/09/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class OWCommentCreationVC: UIViewController {
    fileprivate struct Metrics {

    }

    fileprivate let viewModel: OWCommentCreationViewModeling
    fileprivate let disposeBag = DisposeBag()

    fileprivate lazy var commentCreationView: OWCommentCreationView = {
        let commentCreationView = OWCommentCreationView(viewModel: viewModel.outputs.commentCreationViewVM)
        return commentCreationView
    }()

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(viewModel: OWCommentCreationViewModeling) {
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

fileprivate extension OWCommentCreationVC {
    func setupViews() {
        view.addSubview(commentCreationView)
        commentCreationView.OWSnp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
