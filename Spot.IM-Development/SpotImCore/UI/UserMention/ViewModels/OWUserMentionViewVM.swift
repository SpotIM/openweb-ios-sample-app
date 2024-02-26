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
    var _name: PublishSubject<String> { get }
}

protocol OWUserMentionViewViewModelingOutputs {
    var name: Observable<String> { get }
}

protocol OWUserMentionViewViewModeling: AnyObject {
    var inputs: OWUserMentionViewViewModelingInputs { get }
    var outputs: OWUserMentionViewViewModelingOutputs { get }
}

class OWUserMentionViewVM: OWUserMentionViewViewModelingInputs, OWUserMentionViewViewModelingOutputs, OWUserMentionViewViewModeling {

    fileprivate struct Metrics {
        static let usersCount = 10
    }

    var inputs: OWUserMentionViewViewModelingInputs { return self }
    var outputs: OWUserMentionViewViewModelingOutputs { return self }

    fileprivate let disposeBag = DisposeBag()
    fileprivate let servicesProvider: OWSharedServicesProviding

    var _name = PublishSubject<String>()
    var name: Observable<String> {
        return _name
            .asObservable()
    }

    fileprivate var _users = PublishSubject<Array<OWUserMention>>()
    fileprivate var users: Observable<Array<OWUserMention>> {
        return _users
            .asObservable()

    }

    lazy var usersCellViewModels: Observable<[OWUserMentionCellViewModeling]> = {
        users
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
    }
}

fileprivate extension OWUserMentionViewVM {
    func setupObservers() {
        _name
            .subscribe(onNext: { [weak self] name in
                self?.getUsers(name: name)
            })
            .disposed(by: disposeBag)
    }

    func getUsers(name: String) {
        _ = servicesProvider.netwokAPI()
            .userMention
            .getUsers(name: name, count: Metrics.usersCount)
            .response
            .materialize()
            .map { $0.element }
            .unwrap()
            .bind(to: _users)
    }
}
