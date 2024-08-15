//
//  UIFlowsViewModel.swift
//  OpenWeb-Development
//
//  Created by Revital Pisman on 04/12/2022.
//  Copyright © 2022 OpenWeb. All rights reserved.
//

import Foundation
import RxSwift
import OpenWebSDK

protocol UIFlowsViewModelingInputs {
    var preConversationTapped: PublishSubject<PresentationalModeCompact> { get }
    var fullConversationTapped: PublishSubject<PresentationalModeCompact> { get }
    var commentCreationTapped: PublishSubject<PresentationalModeCompact> { get }
    var commentThreadTapped: PublishSubject<PresentationalModeCompact> { get }
}

protocol UIFlowsViewModelingOutputs {
    var title: String { get }
    // Usually the coordinator layer will handle this, however current architecture is missing a coordinator layer until we will do a propper refactor
    var openMockArticleScreen: Observable<SDKUIFlowActionSettings> { get }
    var presentStyle: OWModalPresentationStyle { get }
}

protocol UIFlowsViewModeling {
    var inputs: UIFlowsViewModelingInputs { get }
    var outputs: UIFlowsViewModelingOutputs { get }
}

class UIFlowsViewModel: UIFlowsViewModeling, UIFlowsViewModelingOutputs, UIFlowsViewModelingInputs {
    var inputs: UIFlowsViewModelingInputs { return self }
    var outputs: UIFlowsViewModelingOutputs { return self }

    fileprivate let dataModel: SDKConversationDataModel

    fileprivate let disposeBag = DisposeBag()

    let preConversationTapped = PublishSubject<PresentationalModeCompact>()
    let fullConversationTapped = PublishSubject<PresentationalModeCompact>()
    let commentCreationTapped = PublishSubject<PresentationalModeCompact>()
    let commentThreadTapped = PublishSubject<PresentationalModeCompact>()

    fileprivate let _openMockArticleScreen = BehaviorSubject<SDKUIFlowActionSettings?>(value: nil)
    var openMockArticleScreen: Observable<SDKUIFlowActionSettings> {
        return _openMockArticleScreen
            .unwrap()
            .asObservable()
    }

    var presentStyle: OWModalPresentationStyle {
        // swiftlint:disable line_length
        return OWModalPresentationStyle.presentationStyle(fromIndex: UserDefaultsProvider.shared.get(key: .modalStyleIndex, defaultValue: OWModalPresentationStyle.default.index))
        // swiftlint:enable line_length
    }

    lazy var title: String = {
        return NSLocalizedString("UIFlows", comment: "")
    }()

    init(dataModel: SDKConversationDataModel) {
        self.dataModel = dataModel
        setupObservers()
    }
}

fileprivate extension UIFlowsViewModel {

    func setupObservers() {
        let postId = dataModel.postId

        let fullConversationTappedModel = fullConversationTapped
            .map { mode -> SDKUIFlowActionSettings in
                let action = SDKUIFlowActionType.fullConversation(presentationalMode: mode)
                let model = SDKUIFlowActionSettings(postId: postId, actionType: action)
                return model
            }

        let commentCreationTappedModel = commentCreationTapped
            .map { mode -> SDKUIFlowActionSettings in
                let action = SDKUIFlowActionType.commentCreation(presentationalMode: mode)
                let model = SDKUIFlowActionSettings(postId: postId, actionType: action)
                return model
            }

        let commentThreadTappedModel = commentThreadTapped
            .map { mode -> SDKUIFlowActionSettings in
                let action = SDKUIFlowActionType.commentThread(presentationalMode: mode)
                let model = SDKUIFlowActionSettings(postId: postId, actionType: action)
                return model
            }

        let preConversationTappedModel = preConversationTapped
            .map { mode -> SDKUIFlowActionSettings in
                let action = SDKUIFlowActionType.preConversation(presentationalMode: mode)
                let model = SDKUIFlowActionSettings(postId: postId, actionType: action)
                return model
            }

        Observable.merge(fullConversationTappedModel, commentCreationTappedModel, commentThreadTappedModel, preConversationTappedModel)
            .map { return $0 }
            .bind(to: _openMockArticleScreen)
            .disposed(by: disposeBag)
    }
}
