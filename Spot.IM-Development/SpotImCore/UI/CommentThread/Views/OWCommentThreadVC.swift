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
        setupObservers()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.inputs.viewDidLoad.onNext()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return OWSharedServicesProvider.shared.statusBarStyleService().currentStyle
    }
}

fileprivate extension OWCommentThreadVC {
    func setupViews() {
        view.addSubview(commentThreadView)
        commentThreadView.OWSnp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        self.setupNavControllerUI()
    }

    func setupNavControllerUI(_ style: OWThemeStyle = OWSharedServicesProvider.shared.themeStyleService().currentStyle) {
        let navController = self.navigationController

        title = OWLocalizationManager.shared.localizedString(key: "Replies")
    }

    func setupObservers() {
        OWSharedServicesProvider.shared.statusBarStyleService()
            .forceStatusBarUpdate
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.setNeedsStatusBarAppearanceUpdate()
            })
            .disposed(by: disposeBag)
    }
}
