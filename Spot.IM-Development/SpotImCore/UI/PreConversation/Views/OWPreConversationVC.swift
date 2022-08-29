//
//  OWPreConversationVC.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 29/08/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class OWPreConversationVC: UIViewController {
    fileprivate struct Metrics {
        
    }
    
    fileprivate let viewModel: OWPreConversationViewModeling
    fileprivate let disposeBag = DisposeBag()
    
    fileprivate lazy var preConversationView: OWPreConversationView = {
        let preConversationView = OWPreConversationView(viewModel: viewModel.outputs.preConversationViewVM)
        return preConversationView
    }()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(viewModel: OWPreConversationViewModeling) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    override func loadView() {
        super.loadView()
        setupViews()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

fileprivate extension OWPreConversationVC {
    func setupViews() {
        view.addSubview(preConversationView)
        preConversationView.OWSnp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
