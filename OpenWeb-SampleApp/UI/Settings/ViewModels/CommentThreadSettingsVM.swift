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
    var openCommentIdSelected: PublishSubject<String> { get }
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

    var openCommentIdSelected = PublishSubject<String>()
    var openCommentId: Observable<String> {
        return userDefaultsProvider.values(key: .openCommentId, defaultValue: OWCommentThreadSettings.defaultCommentId)
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
            .takeLast(1)
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
