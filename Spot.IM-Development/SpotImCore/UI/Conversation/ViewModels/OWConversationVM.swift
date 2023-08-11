//
//  OWConversationVM.swift
//  SpotImCore
//
//  Created by Alon Haiut on 06/07/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

protocol OWConversationViewModelingInputs {
    var triggerCustomizeNavigationItemUI: PublishSubject<UINavigationItem> { get }
    var triggerCustomizeNavigationBarUI: PublishSubject<UINavigationBar> { get }
    // String is the commentId
    var highlightComment: PublishSubject<String> { get }
    var viewDidLoad: PublishSubject<Void> { get }
    var closeConversationTapped: PublishSubject<Void> { get }
    var changeIsLargeTitleDisplay: PublishSubject<Bool> { get }
}

protocol OWConversationViewModelingOutputs {
    var customizeNavigationItemUI: Observable<UINavigationItem> { get }
    var customizeNavigationBarUI: Observable<UINavigationBar> { get }
    var conversationViewVM: OWConversationViewViewModeling { get }
    var highlightedComment: Observable<String> { get }
    var loadedToScreen: Observable<Void> { get }
    var shouldCustomizeNavigationBar: Bool { get }
    var shouldShowCloseButton: Bool { get }
    var closeConversation: Observable<Void> { get }
    var isLargeTitleDisplay: Observable<Bool> { get }
}

protocol OWConversationViewModeling {
    var inputs: OWConversationViewModelingInputs { get }
    var outputs: OWConversationViewModelingOutputs { get }
}

class OWConversationViewModel: OWConversationViewModeling,
                                OWConversationViewModelingInputs,
                               OWConversationViewModelingOutputs {

    var inputs: OWConversationViewModelingInputs { return self }
    var outputs: OWConversationViewModelingOutputs { return self }

    fileprivate let servicesProvider: OWSharedServicesProviding
    fileprivate let conversationData: OWConversationRequiredData
    fileprivate let viewableMode: OWViewableMode
    fileprivate let disposeBag = DisposeBag()

    // Required to work with BehaviorSubject in the RX chain as the final subscriber begin after the initial publish subjects send their first elements
    fileprivate let _triggerCustomizeNavigationItemUI = BehaviorSubject<UINavigationItem?>(value: nil)
    fileprivate let _triggerCustomizeNavigationBarUI = BehaviorSubject<UINavigationBar?>(value: nil)
    fileprivate let _shouldShowCustomizeNavigationItemLabel = BehaviorSubject<Bool?>(value: nil)

    var triggerCustomizeNavigationItemUI = PublishSubject<UINavigationItem>()
    var triggerCustomizeNavigationBarUI = PublishSubject<UINavigationBar>()

    var customizeNavigationItemUI: Observable<UINavigationItem> {
        return _triggerCustomizeNavigationItemUI
            .unwrap()
            .asObservable()
    }

    var customizeNavigationBarUI: Observable<UINavigationBar> {
        return _triggerCustomizeNavigationBarUI
            .unwrap()
            .asObservable()
    }

    lazy var conversationViewVM: OWConversationViewViewModeling = {
        return OWConversationViewViewModel(conversationData: conversationData,
                                           viewableMode: self.viewableMode)
    }()

    var shouldCustomizeNavigationBar: Bool {
        let isSampleAppNavigationController: Bool = OWHostApplicationHelper.isOpenWebSampleApp()
        var isInternalPresentModeNavigationController: Bool = false
        if case OWPresentationalModeCompact.present(_) = conversationData.presentationalStyle,
           viewableMode == .partOfFlow {
            isInternalPresentModeNavigationController = true
        }

        return isInternalPresentModeNavigationController || isSampleAppNavigationController
    }

    var shouldShowCloseButton: Bool {
        guard case OWPresentationalModeCompact.present(_) = conversationData.presentationalStyle else { return false }
        return true
    }

    var highlightComment = PublishSubject<String>()
    fileprivate var _highlightedComment = BehaviorSubject<String?>(value: nil)
    var highlightedComment: Observable<String> {
        return _highlightedComment
            .unwrap()
            .asObservable()
    }

    var viewDidLoad = PublishSubject<Void>()
    var _viewDidLoad = BehaviorSubject<Void?>(value: nil)
    var loadedToScreen: Observable<Void> {
        return _viewDidLoad
            .unwrap()
            .asObservable()
    }

    var closeConversationTapped = PublishSubject<Void>()
    var closeConversation: Observable<Void> {
        return closeConversationTapped.asObservable()
    }

    fileprivate lazy var _isLargeTitleDisplay: BehaviorSubject<Bool> = {
        return BehaviorSubject<Bool>(value: true)
    }()

    var changeIsLargeTitleDisplay = PublishSubject<Bool>()
    var isLargeTitleDisplay: Observable<Bool> {
        return _isLargeTitleDisplay
    }

    init (conversationData: OWConversationRequiredData,
          servicesProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared,
          viewableMode: OWViewableMode) {
        self.servicesProvider = servicesProvider
        self.conversationData = conversationData
        self.viewableMode = viewableMode
        setupObservers()
    }
}

fileprivate extension OWConversationViewModel {
    func setupObservers() {
        // Using BehaviorSubject behind the scene as the view create only after the coordinator initiated `viewModel.inputs.highlightComment.onNext(...)`
        highlightComment
            .bind(to: _highlightedComment)
            .disposed(by: disposeBag)

        // Same reason
        viewDidLoad
            .bind(to: _viewDidLoad)
            .disposed(by: disposeBag)

        triggerCustomizeNavigationItemUI
            .bind(to: _triggerCustomizeNavigationItemUI)
            .disposed(by: disposeBag)

        triggerCustomizeNavigationBarUI
            .bind(to: _triggerCustomizeNavigationBarUI)
            .disposed(by: disposeBag)

        changeIsLargeTitleDisplay
            .bind(to: _isLargeTitleDisplay)
            .disposed(by: disposeBag)
    }
}
