//
//  UIViewsViewModel.swift
//  Spot-IM.Development
//
//  Created by Revital Pisman on 07/12/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

#if NEW_API

protocol UIViewsViewModelingInputs {
    var preConversationTapped: PublishSubject<Void> { get }
    var fullConversationTapped: PublishSubject<Void> { get }
    var commentCreationTapped: PublishSubject<Void> { get }
    var commentThreadTapped: PublishSubject<Void> { get }
    var independentAdUnitTapped: PublishSubject<Void> { get }
}

protocol UIViewsViewModelingOutputs {
    var title: String { get }
}

protocol UIViewsViewModeling {
    var inputs: UIViewsViewModelingInputs { get }
    var outputs: UIViewsViewModelingOutputs { get }
}

class UIViewsViewModel: UIViewsViewModeling, UIViewsViewModelingOutputs, UIViewsViewModelingInputs {
    var inputs: UIViewsViewModelingInputs { return self }
    var outputs: UIViewsViewModelingOutputs { return self }

    fileprivate let dataModel: SDKConversationDataModel

    fileprivate let disposeBag = DisposeBag()

    let preConversationTapped = PublishSubject<Void>()
    let fullConversationTapped = PublishSubject<Void>()
    let commentCreationTapped = PublishSubject<Void>()
    let commentThreadTapped = PublishSubject<Void>()
    let independentAdUnitTapped = PublishSubject<Void>()

    lazy var title: String = {
        return NSLocalizedString("UIViews", comment: "")
    }()

    init(dataModel: SDKConversationDataModel) {
        self.dataModel = dataModel
        setupObservers()
    }
}

fileprivate extension UIViewsViewModel {

    func setupObservers() { }
}

#endif

