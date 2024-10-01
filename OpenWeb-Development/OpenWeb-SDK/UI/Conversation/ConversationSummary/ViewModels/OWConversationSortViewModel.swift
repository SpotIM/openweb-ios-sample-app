//
//  OWConversationSortViewModel.swift
//  OpenWebSDK
//
//  Created by Revital Pisman on 20/03/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

protocol OWConversationSortViewModelingInputs {
    var sortTapped: PublishSubject<OWUISource> { get }
    var sortSelected: PublishSubject<OWSortOption> { get }
    var triggerCustomizeSortByLabelUI: PublishSubject<UILabel> { get }
}

protocol OWConversationSortViewModelingOutputs {
    var selectedSortOption: Observable<OWSortOption> { get }
    var openSort: Observable<OWUISource> { get }
    var customizeSortByLabelUI: Observable<UILabel> { get }
}

protocol OWConversationSortViewModeling {
    var inputs: OWConversationSortViewModelingInputs { get }
    var outputs: OWConversationSortViewModelingOutputs { get }
}

class OWConversationSortViewModel: OWConversationSortViewModeling,
                                   OWConversationSortViewModelingInputs,
                                   OWConversationSortViewModelingOutputs {
    var inputs: OWConversationSortViewModelingInputs { return self }
    var outputs: OWConversationSortViewModelingOutputs { return self }

    // Required to work with BehaviorSubject in the RX chain as the final subscriber begin after the initial publish subjects send their first elements
    private let _triggerCustomizeSortByLabelUI = BehaviorSubject<UILabel?>(value: nil)

    var triggerCustomizeSortByLabelUI = PublishSubject<UILabel>()
    var sortTapped = PublishSubject<OWUISource>()
    var sortSelected = PublishSubject<OWSortOption>()

    var customizeSortByLabelUI: Observable<UILabel> {
        return _triggerCustomizeSortByLabelUI
            .unwrap()
            .asObservable()
    }

    private let _selectedSortOption = BehaviorSubject<OWSortOption?>(value: nil)
    var selectedSortOption: Observable<OWSortOption> {
        _selectedSortOption
            .unwrap()
    }

    var openSort: Observable<OWUISource> {
        sortTapped.asObservable()
    }

    private let servicesProvider: OWSharedServicesProviding
    private let disposeBag = DisposeBag()

    private var postId: OWPostId {
        return OWManager.manager.postId ?? ""
    }

    init (servicesProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared) {
        self.servicesProvider = servicesProvider

        self.setupObservers()
    }
}

private extension OWConversationSortViewModel {
    func setupObservers() {
        // Observable for the sort option
        let sortOptionObservable = self.servicesProvider
            .sortDictateService()
            .sortOption(perPostId: self.postId)

        sortOptionObservable.subscribe(onNext: { [weak self] sortOption in
            guard let self = self else { return }

            self._selectedSortOption.onNext(sortOption)
        })
        .disposed(by: disposeBag)

        triggerCustomizeSortByLabelUI
            .bind(to: _triggerCustomizeSortByLabelUI)
            .disposed(by: disposeBag)
    }
}
