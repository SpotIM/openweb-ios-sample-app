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
    var name: Observable<String> { get }
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

    fileprivate var _name = PublishSubject<String>()
    var name: Observable<String> {
        return _name
            .asObservable()
    }

    fileprivate var _users = PublishSubject<Array<OWUserMention>>()
    fileprivate var users: Observable<Array<OWUserMention>> {
        return _users
            .asObservable()

    }

    lazy var cellsViewModels: Observable<[OWUserMentionCellViewModeling]> = {
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

    let searchCaptureGroupName = "search"

    func searchText(text: String) {
        let searchRange = NSRange(location: 0, length: text.count)
        // 2
        let mentionsRegexPattern = "(?:\\s|^)(?<\(searchCaptureGroupName)>(@)\\w*(?: \\w*)?))"
        let regex = try! NSRegularExpression(
            pattern: mentionsRegexPattern,
            options: .caseInsensitive
        )
        // 3
        let matches = regex.matches(in: text, options: [], range: searchRange)
        print("matches = \(matches)")
    }
}

fileprivate extension OWUserMentionViewVM {
    func setupObservers() {
        _name
            .throttle(.milliseconds(Metrics.throttleGetUsers), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] name in
                self?.getUsers(name: name)
            })
            .disposed(by: disposeBag)

        text
            .subscribe(onNext: { [weak self] text in
                self?.searchText(text: text)
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
