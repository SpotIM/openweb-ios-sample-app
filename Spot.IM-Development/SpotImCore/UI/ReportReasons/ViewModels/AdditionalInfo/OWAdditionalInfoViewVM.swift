//
//  OWAdditionalInfoVM.swift
//  SpotImCore
//
//  Created by Refael Sommer on 01/05/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

protocol OWAdditionalInfoViewViewModelingInputs {
    var cancelAdditionalInfoTap: PublishSubject<Void> { get }
    var submitAdditionalInfoTap: PublishSubject<String> { get }
}

protocol OWAdditionalInfoViewViewModelingOutputs {
    var cancelAdditionalInfoTapped: Observable<Void> { get }
    var submitAdditionalInfoTapped: Observable<String> { get }
    var textViewVM: OWTextViewViewModeling { get }
    var cancelButtonText: String { get }
    var submitButtonText: String { get }
    var titleText: String { get }
    var shouldShowTitleView: Bool { get }
}

protocol OWAdditionalInfoViewViewModeling {
    var inputs: OWAdditionalInfoViewViewModelingInputs { get }
    var outputs: OWAdditionalInfoViewViewModelingOutputs { get }
}

class OWAdditionalInfoViewViewModel: OWAdditionalInfoViewViewModelingInputs, OWAdditionalInfoViewViewModelingOutputs, OWAdditionalInfoViewViewModeling {
    fileprivate struct Metrics {
        static let titleKey = "AdditionalInfoTitle"
        static let cancelKey = "Cancel"
        static let submitKey = "Submit"
        static let textViewMaxCharecters = 280
    }

    var inputs: OWAdditionalInfoViewViewModelingInputs { return self }
    var outputs: OWAdditionalInfoViewViewModelingOutputs { return self }

    var titleText: String {
        return LocalizationManager.localizedString(key: Metrics.titleKey)
    }

    var cancelButtonText: String {
        return LocalizationManager.localizedString(key: Metrics.cancelKey)
    }

    var submitButtonText: String {
        return LocalizationManager.localizedString(key: Metrics.submitKey)
    }

    var cancelAdditionalInfoTap = PublishSubject<Void>()
    var cancelAdditionalInfoTapped: Observable<Void> {
        return cancelAdditionalInfoTap.asObservable()
    }

    var submitAdditionalInfoTap = PublishSubject<String>()
    var submitAdditionalInfoTapped: Observable<String> {
        return submitAdditionalInfoTap.asObservable()
    }

    var shouldShowTitleView: Bool {
        return viewableMode == .independent
    }

    let textViewVM: OWTextViewViewModeling
    fileprivate let viewableMode: OWViewableMode

    init(viewableMode: OWViewableMode, placeholderText: String, textViewText: String, textViewMaxCharecters: Int = Metrics.textViewMaxCharecters) {
        self.viewableMode = viewableMode
        self.textViewVM = OWTextViewViewModel(textViewMaxCharecters: textViewMaxCharecters,
                                              placeholderText: placeholderText,
                                              textViewText: textViewText,
                                              isEditable: true)
        setupObservers()
    }
}

fileprivate extension OWAdditionalInfoViewViewModel {
    func setupObservers() { }
}
