//
//  ConversationCounterVC.swift
//  Spot-IM.Development
//
//  Created by Alon Haiut on 22/08/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import UIKit
import RxSwift
import SnapKit

class ConversationCounterVC: UIViewController {
    fileprivate struct Metrics {
        static let verticalMargin: CGFloat = 40
        static let horizontalMargin: CGFloat = 20
    }
    
    fileprivate let viewModel: ConversationCounterViewModeling
    fileprivate let disposeBag = DisposeBag()
    
    fileprivate lazy var lblPostId: UILabel = {
        let txt = NSLocalizedString("PostId", comment: "") + ": "
        return txt
            .label
            .font(FontBook.mainHeading)
            .textColor(ColorPalette.blackish)
    }()
    
    fileprivate lazy var loader: UIActivityIndicatorView = {
        let style: UIActivityIndicatorView.Style
        if #available(iOS 13.0, *) {
            style = .large
        } else {
            style = .whiteLarge
        }
        let loader = UIActivityIndicatorView(style: style)
        loader.isHidden = true
        return loader
    }()
    
    init(viewModel: ConversationCounterViewModeling) {
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
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupObservers()
    }
}

fileprivate extension ConversationCounterVC {
    func setupViews() {
        view.backgroundColor = .white
        
        view.addSubview(lblPostId)
        lblPostId.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(2*Metrics.verticalMargin)
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(Metrics.horizontalMargin)
        }
        
       
        
        view.addSubview(loader)
        loader.snp.makeConstraints { make in
            make.center.equalTo(view.safeAreaLayoutGuide)
        }
    }

    func setupObservers() {
        title = viewModel.outputs.title
        
        let showLoaderObservable = viewModel.outputs.showLoader
            .share(replay: 0)
        
        showLoaderObservable
            .map { !$0 }
            .bind(to: loader.rx.isHidden)
            .disposed(by: disposeBag)
        
        showLoaderObservable
            .bind(to: loader.rx.isAnimating)
            .disposed(by: disposeBag)
    }
}
