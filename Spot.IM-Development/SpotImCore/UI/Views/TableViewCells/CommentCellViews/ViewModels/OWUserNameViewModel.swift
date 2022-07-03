//
//  OWUserNameViewModel.swift
//  SpotImCore
//
//  Created by Alon Shprung on 27/06/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import RxSwift
import RxCocoa
import UIKit

protocol OWUserNameViewModelingInputs {
    var tapUserName: PublishSubject<Void> { get }
    var tapMore: PublishSubject<UIButton> { get }
}

protocol OWUserNameViewModelingOutputs {
    var subscriberBadgeVM: OWUserSubscriberBadgeViewModeling { get }
}

protocol OWUserNameViewModeling {
    var inputs: OWUserNameViewModelingInputs { get }
    var outputs: OWUserNameViewModelingOutputs { get }
}

class OWUserNameViewModel: OWUserNameViewModeling,
                              OWUserNameViewModelingInputs,
                              OWUserNameViewModelingOutputs {

    var inputs: OWUserNameViewModelingInputs { return self }
    var outputs: OWUserNameViewModelingOutputs { return self }
    
    fileprivate let disposeBag = DisposeBag()
    
    init(user: SPUser?) {
        if let user = user {
            subscriberBadgeVM.inputs.configureUser(user: user)
        }
        self.setupObservers()
    }
    
    var tapUserName = PublishSubject<Void>()
    var tapMore = PublishSubject<UIButton>()
    
    let subscriberBadgeVM: OWUserSubscriberBadgeViewModeling = OWUserSubscriberBadgeViewModel()
    
    func setupObservers() {
    }
}
