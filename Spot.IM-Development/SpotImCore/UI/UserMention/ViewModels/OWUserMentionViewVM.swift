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
    var textData: PublishSubject<OWUserMentionTextData> { get }
    var tappedMentionIndex: PublishSubject<Int> { get }
}

protocol OWUserMentionViewViewModelingOutputs {
    var cellsViewModels: Observable<[OWUserMentionCellViewModeling]> { get }
    var mentionsData: Observable<OWUserMentionData> { get }
    var currentMentionRange: Observable<Range<String.Index>?> { get }
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

    var getUsersForName: String = ""
    var textData = PublishSubject<OWUserMentionTextData>()

    fileprivate lazy var _currentMentionRange = BehaviorSubject<Range<String.Index>?>(value: nil)
    lazy var currentMentionRange: Observable<Range<String.Index>?> = {
        return _currentMentionRange
            .asObservable()
    }()

    fileprivate var name = BehaviorSubject<String>(value: "")
    var tappedMentionIndex = PublishSubject<Int>()

    fileprivate lazy var _mentionsData = BehaviorSubject<OWUserMentionData>(value: OWUserMentionData())
    lazy var mentionsData: Observable<OWUserMentionData> = {
        return _mentionsData
            .asObservable()
    }()

    fileprivate lazy var _users = PublishSubject<[OWUserMention]>()
    fileprivate lazy var users: Observable<[OWUserMention]> = {
        return _users
            .asObservable()

    }()

    fileprivate lazy var getUsers: Observable<[OWUserMention]> = {
        return name
            .do(onNext: { [weak self] name in
                self?.getUsersForName = name
            })
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
                        guard let self = self,
                              self.getUsersForName == name else { return nil }
                        switch event {
                        case .next(let userMentionResponse):
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
            guard let range = text.range(of: text),
                  let nsRange = text.nsRange(from: range) else { return }
            regex.enumerateMatches(in: text, range: nsRange) { [weak self] result, _, _ in
                guard let self = self else { return }

                if let r = result?.range(at: 0), let range = Range(r, in: text) {
                    self._currentMentionRange.onNext(range)
                    let substring = String(text[range].dropFirst())
                    results.append(substring)
                }
            }
            guard let lastResult = results.last else {
                _users.onNext([])
                return
            }
            name.onNext(lastResult.isEmpty ? "a" : lastResult)
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
        textData
            .filter { $0.replacingText == nil }
            .subscribe(onNext: { [weak self] textData in
                guard let self = self else { return }
                self.getUsersForName = ""
                var textToCursor = textData.text
                if textData.cursorRange.lowerBound <= textData.text.endIndex {
                    textToCursor = String(textData.text[..<textData.cursorRange.lowerBound])
                }
                self.searchText(text: textToCursor)
            })
            .disposed(by: disposeBag)

        textData
            .filter { $0.replacingText != nil }
            .withLatestFrom(mentionsData) { ($0, $1) }
            .subscribe(onNext: { [weak self] textData, mentionsData in
                guard let self = self,
                      let replacingText = textData.replacingText else { return }
                var mentions: [OWUserMentionObject] = []
                var textWithoutOldText = textData.text
                textWithoutOldText.removeSubrange(textData.cursorRange)
                let newMutableText = NSMutableString(string: textWithoutOldText)
                newMutableText.insert(replacingText, at: textData.text.distance(from: textData.text.startIndex, to: textData.cursorRange.lowerBound))
                let newText = String(newMutableText)
                for mention in mentionsData.mentions {
                    if let mentionRange = Range(mention.range, in: textData.text),
                       !(mentionRange ~= textData.cursorRange) {
                        // update mention that replace is affecting
                        if textData.cursorRange.upperBound < mentionRange.lowerBound { // Update mentionRange since replacing text before this mention
                            let distance = textData.text.utf16.distance(from: textData.cursorRange.lowerBound, to: textData.cursorRange.upperBound)
                            let addToRange = -distance + replacingText.utf16.count
                            let updatedMentionRange: Range = {
                                if distance > 0 {
                                    let from = textData.text.utf16.index(mentionRange.lowerBound, offsetBy: addToRange)
                                    let to = textData.text.utf16.index(mentionRange.upperBound, offsetBy: addToRange)
                                    return Range(uncheckedBounds: (from, to))
                                } else {
                                    let from = newText.utf16.index(mentionRange.lowerBound, offsetBy: addToRange)
                                    let to = newText.utf16.index(mentionRange.upperBound, offsetBy: addToRange)
                                    return Range(uncheckedBounds: (from, to))
                                }
                            }()

                            guard let range = newText.nsRange(from: updatedMentionRange) else { return }
                            mention.range = range

                        }
                        mentions.append(mention)
                    }
                }
                mentionsData.mentions = mentions
                self._mentionsData.onNext(mentionsData)
            })
            .disposed(by: disposeBag)

        getUsers
            .bind(to: _users)
            .disposed(by: disposeBag)

        // If users is empty then current mention range needs to be cleared
        getUsers
            .filter { $0.isEmpty }
            .subscribe(onNext: { [weak self] _ in
                self?._currentMentionRange.onNext(nil)
            })
            .disposed(by: disposeBag)

        tappedMentionIndex
            .withLatestFrom(cellsViewModels) { ($0, $1) }
            .flatMapLatest { index, cellsViewModels -> Observable<(String, String)> in
                guard index < cellsViewModels.count else { return .empty() }
                let selectedCellVM = cellsViewModels[index]
                let id = selectedCellVM.outputs.id
                let selectedDisplayName = selectedCellVM.outputs.displayName
                return selectedDisplayName.map { ($0, id) }
            }
            .withLatestFrom(textData) { ($0.0, $0.1, $1) }
            .withLatestFrom(mentionsData) { ($0.0, $0.1, $0.2, $1) }
            .asObservable()
            .subscribe(onNext: { [weak self] displayName, id, textData, mentionsData in
                let textToCursor = textData.textToCursor
                let mentionDisplayText = "@" + displayName
                guard let indexOfMention = textToCursor.lastIndex(of: "@") else { return }
                let textWithMention = String(textToCursor[..<indexOfMention]) + mentionDisplayText
                guard let self = self,
                      let lastIndex = textWithMention.lastIndex(of: "@"),
                      let range = textWithMention.range(of: mentionDisplayText),
                      let selectedRange = textWithMention.nsRange(from: range) else { return }
                let userMentionObject = OWUserMentionObject(id: id, text: mentionDisplayText, range: selectedRange)
                mentionsData.mentions.append(userMentionObject)
                self._mentionsData.onNext(mentionsData)
            })
            .disposed(by: disposeBag)
    }
}
