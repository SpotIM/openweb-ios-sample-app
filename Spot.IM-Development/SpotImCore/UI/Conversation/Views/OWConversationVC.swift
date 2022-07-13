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
    fileprivate let conversationViewVM: OWConversationViewViewModeling
    fileprivate let disposeBag = DisposeBag()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(viewModel: OWConversationViewModeling) {
        self.viewModel = viewModel
        // We can pass here stuff from the main view model to this view model
        conversationViewVM = OWConversationViewViewModel()
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

fileprivate extension OWConversationVC {
    func setupViews() {
        
    }
}
