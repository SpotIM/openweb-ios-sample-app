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
    
    fileprivate lazy var lblComments: UILabel = {
        let txt = NSLocalizedString("Comments", comment: "") + ": "
        return txt
            .label
            .font(FontBook.secondaryHeading)
            .textColor(ColorPalette.blackish)
    }()
    
    fileprivate lazy var lblReplies: UILabel = {
        let txt = NSLocalizedString("Replies", comment: "") + ": "
        return txt
            .label
            .font(FontBook.secondaryHeading)
            .textColor(ColorPalette.blackish)
    }()
    
    init(viewModel: ConversationCounterViewModeling = ConversationCounterViewModel()) {
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
        
        view.addSubview(lblComments)
        lblComments.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(2*Metrics.verticalMargin)
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(Metrics.horizontalMargin)
        }

        view.addSubview(lblReplies)
        lblReplies.snp.makeConstraints { make in
            make.top.equalTo(lblComments.snp.bottom).offset(Metrics.verticalMargin)
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(Metrics.horizontalMargin)
        }
    }

    func setupObservers() {
        title = viewModel.outputs.title
              
    }
}
