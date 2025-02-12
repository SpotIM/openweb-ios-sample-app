//
//  CommentThreadSettingsVM.swift
//  OpenWeb-Development
//
//  Created by Refael Sommer on 09/05/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import Foundation
import RxSwift
import OpenWebSDK

protocol CommentThreadSettingsViewModelingInputs {
    var openCommentIdSelected: BehaviorSubject<String> { get }
}

protocol CommentThreadSettingsViewModelingOutputs {
    var title: String { get }
    var openCommentIdTitle: String { get }
    var openCommentId: Observable<String> { get }
}

protocol CommentThreadSettingsViewModeling {
    var inputs: CommentThreadSettingsViewModelingInputs { get }
    var outputs: CommentThreadSettingsViewModelingOutputs { get }
}

class CommentThreadSettingsVM: CommentThreadSettingsViewModeling, CommentThreadSettingsViewModelingInputs, CommentThreadSettingsViewModelingOutputs {
    var inputs: CommentThreadSettingsViewModelingInputs { return self }
    var outputs: CommentThreadSettingsViewModelingOutputs { return self }

    lazy var openCommentIdSelected = BehaviorSubject<String>(value: userDefaultsProvider.get(key: .openCommentId, defaultValue: OWCommentThreadSettings.defaultCommentId))
    var openCommentId: Observable<String> {
        return openCommentIdSelected.asObservable()
    }

    lazy var openCommentIdTitle: String = {
        return NSLocalizedString("OpenCommentId", comment: "")
    }()

    private var userDefaultsProvider: UserDefaultsProviderProtocol

    private let disposeBag = DisposeBag()

    lazy var title: String = {
        return NSLocalizedString("CommentThreadSettings", comment: "")
    }()

    init(userDefaultsProvider: UserDefaultsProviderProtocol = UserDefaultsProvider.shared) {
        self.userDefaultsProvider = userDefaultsProvider
        setupObservers()
    }
}

private extension CommentThreadSettingsVM {
    func setupObservers() {
        openCommentIdSelected
            .skip(1)
            .bind(to: userDefaultsProvider.rxProtocol
            .setValues(key: UserDefaultsProvider.UDKey<String>.openCommentId))
            .disposed(by: disposeBag)
    }
}

extension CommentThreadSettingsVM: SettingsGroupVMProtocol {
    func resetToDefault() {
        openCommentIdSelected.onNext(OWCommentThreadSettings.defaultCommentId)
    }
}
