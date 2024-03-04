//
//  OWUserMentionViewVM.swift
//  SpotImCore
//
//  Created by Refael Sommer on 26/02/2024.
//  Copyright © 2024 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

protocol OWUserMentionViewViewModelingInputs {
    var text: PublishSubject<String> { get }
}

protocol OWUserMentionViewViewModelingOutputs {
    var cellsViewModels: Observable<[OWUserMentionCellViewModeling]> { get }
}

protocol OWUserMentionViewViewModeling: AnyObject {
    var inputs: OWUserMentionViewViewModelingInputs { get }
    var outputs: OWUserMentionViewViewModelingOutputs { get }
}

class OWUserMentionViewVM: OWUserMentionViewViewModelingInputs, OWUserMentionViewViewModelingOutputs, OWUserMentionViewViewModeling {

    fileprivate struct Metrics {
        static let usersCount = 10
        static let throttleGetUsers = 150
    }

    var inputs: OWUserMentionViewViewModelingInputs { return self }
    var outputs: OWUserMentionViewViewModelingOutputs { return self }

    fileprivate let disposeBag = DisposeBag()
    fileprivate let servicesProvider: OWSharedServicesProviding

    var text = PublishSubject<String>()

    fileprivate var name = PublishSubject<String>()

    fileprivate var _users = PublishSubject<[OWUserMention]>()
    fileprivate var users: Observable<[OWUserMention]> {
        return _users
            .asObservable()

    }

    fileprivate lazy var getUsers: Observable<[OWUserMention]> = {
        return name
            .asObservable()
            .throttle(.milliseconds(Metrics.throttleGetUsers), scheduler: MainScheduler.instance)
            .flatMapLatest { [weak self] name -> Observable<[OWUserMention]> in
                guard let self = self else { return .empty() }
                return self.servicesProvider.netwokAPI()
                    .userMention
                    .getUsers(name: name, count: Metrics.usersCount)
                    .response
                    .materialize()
                    .map { [weak self] event in
                        switch event {
                        case .next(let userMentionResponse):
                            guard let self = self else { return nil }
                            let suggestions = userMentionResponse.suggestions ?? []
                            let atLeastOneContained = self.atLeastOneContained(name: name, userMentions: suggestions)
                            return atLeastOneContained ? suggestions : []
                        case .error(_):
                            return nil
                        default:
                            return nil
                        }
                    }
                    .unwrap()
            }
    }()

    lazy var cellsViewModels: Observable<[OWUserMentionCellViewModeling]> = {
        return users
            .map { users in
                var viewModels: [OWUserMentionCellViewModeling] = []
                for user in users {
                    viewModels.append(OWUserMentionCellVM(user: user))
                }
                return viewModels
            }
            .asObservable()
    }()

    init(servicesProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared) {
        self.servicesProvider = servicesProvider
        self.setupObservers()
    }

    func searchText(text: String) {
        do {
            let regex = try NSRegularExpression(pattern: "\\@[^\\@]*$", options: [])
            var results = [String]()
            regex.enumerateMatches(in: text, range: NSRange(location: 0, length: text.count)) { result, _, _ in
                if let r = result?.range(at: 0), let range = Range(r, in: text) {
                    let substring = String(text[range].dropFirst())
                    results.append(substring)
                }
            }
            guard let lastResult = results.last else {
                _users.onNext([])
                return
            }
            name.onNext(lastResult)
        } catch { }
    }

    func atLeastOneContained(name: String, userMentions: [OWUserMention]) -> Bool {
        guard !name.isEmpty else { return true }
        let name = name.lowercased()
        return userMentions.contains(where: { $0.displayName.lowercased().contains(name) || $0.userName.lowercased().contains(name) })
    }
}

fileprivate extension OWUserMentionViewVM {
    func setupObservers() {
        text
            .subscribe(onNext: { [weak self] text in
                self?.searchText(text: text)
            })
            .disposed(by: disposeBag)

        getUsers
            .bind(to: _users)
            .disposed(by: disposeBag)
    }
}
