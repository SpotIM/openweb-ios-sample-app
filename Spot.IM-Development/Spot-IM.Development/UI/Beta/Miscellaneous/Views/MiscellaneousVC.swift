//
//  MiscellaneousVC.swift
//  Spot-IM.Development
//
//  Created by Revital Pisman on 04/12/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

#if NEW_API

class MiscellaneousVC: UIViewController {
    
    fileprivate struct Metrics {
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
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupObservers()
    }
}

fileprivate extension MiscellaneousVC {
    func setupViews() {
        view.backgroundColor = ColorPalette.shared.color(type: .background)
        
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
            
            //Move to last view in scroll view
            make.bottom.equalTo(scrollView.contentLayoutGuide).offset(-Metrics.verticalMargin)
        }
    }
    
    func setupObservers() {
        title = viewModel.outputs.title
    }
}

#endif
