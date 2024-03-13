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

    var replaceData: PublishSubject<OWTextViewReplaceData> { get }
    var textViewText: PublishSubject<String> { get }
    var cursorRange: PublishSubject<Range<String.Index>> { get }

    var attributedTextChange: PublishSubject<NSAttributedString> { get }
    var textChange: PublishSubject<String> { get }
    var cursorRangeChange: PublishSubject<Range<String.Index>> { get }
}

protocol OWUserMentionViewViewModelingOutputs {
    var cellsViewModels: Observable<[OWUserMentionCellViewModeling]> { get }
    var mentionsData: Observable<OWUserMentionData> { get }
    var currentMentionRange: Observable<Range<String.Index>?> { get }
    var tappedMention: Observable<OWUserMentionData> { get }

    var attributedTextChanged: Observable<NSAttributedString> { get }
    var textChanged: Observable<String> { get }
    var cursorRangeChanged: Observable<Range<String.Index>> { get }
}

protocol OWUserMentionViewViewModeling: AnyObject {
    var inputs: OWUserMentionViewViewModelingInputs { get }
    var outputs: OWUserMentionViewViewModelingOutputs { get }
}

class OWUserMentionViewVM: OWUserMentionViewViewModelingInputs, OWUserMentionViewViewModelingOutputs, OWUserMentionViewViewModeling {

    fileprivate struct Metrics {
        static let usersCount = 10
        static let throttleGetUsers = 150
        static let debounceTextChange = 10
    }

    var inputs: OWUserMentionViewViewModelingInputs { return self }
    var outputs: OWUserMentionViewViewModelingOutputs { return self }

    fileprivate let disposeBag = DisposeBag()
    fileprivate let servicesProvider: OWSharedServicesProviding

    var replaceData = PublishSubject<OWTextViewReplaceData>()
    var textViewText = PublishSubject<String>()
    var cursorRange = PublishSubject<Range<String.Index>>()

    var attributedTextChange = PublishSubject<NSAttributedString>()
    var textChange = PublishSubject<String>()
    var cursorRangeChange = PublishSubject<Range<String.Index>>()
    var textChanged: Observable<String> {
        return textChange
            .asObservable()
    }
    var cursorRangeChanged: Observable<Range<String.Index>> {
        return cursorRangeChange
            .asObservable()
    }
    var attributedTextChanged: Observable<NSAttributedString> {
        return attributedTextChange
            .asObservable()
    }

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

    var tappedMentionAction = PublishSubject<OWUserMentionData>()
    var tappedMention: Observable<OWUserMentionData> {
        return tappedMentionAction
            .asObservable()
    }

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

    func searchText(text: String, mentions: [OWUserMentionObject]) {
        do {
            let regex = try NSRegularExpression(pattern: "\\@[^\\@]*$", options: [])
            var results = [String]()
            guard let range = text.range(of: String(text.utf16)),
                  let nsRange = text.nsRange(from: range) else {
                _users.onNext([])
                return
            }
            regex.enumerateMatches(in: text, range: nsRange) { [weak self] result, _, _ in
                guard let self = self else { return }

                if let r = result?.range(at: 0), let range = Range(r, in: String(text.utf16)) {
                    if !(mentions.contains(where: { mention in
                        let mentionRange = Range(mention.range, in: text)
                        return range.lowerBound == mentionRange?.lowerBound
                    })) {
                        if let substring = String(text.utf16[range].dropFirst()) {
                            self._currentMentionRange.onNext(range)
                            results.append(substring)
                        }
                    }
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
        let atLeastOneContained = userMentions.contains(where: { $0.displayName.lowercased().contains(name) || $0.userName.lowercased().contains(name) })
        return atLeastOneContained
    }
}

fileprivate extension OWUserMentionViewVM {
    // swiftlint:disable function_body_length
    func setupObservers() {
        replaceData
            .withLatestFrom(textViewText) { ($0, $1) }
            .subscribe(onNext: { [weak self] replaceData, text in
                guard let self = self else { return }
                let utf8Range = replaceData.range
                let startIndex = text.utf16.index(text.utf16.startIndex, offsetBy: utf8Range.lowerBound)
                let endIndex = text.utf16.index(startIndex, offsetBy: utf8Range.length)
                let stringRange = startIndex..<endIndex
                let textData = OWUserMentionTextData(text: text, cursorRange: stringRange, replacingText: replaceData.text)
                self.textData.onNext(textData)
            })
            .disposed(by: disposeBag)

        Observable.combineLatest(textViewText, cursorRange)
            .filter { $1.lowerBound == $1.upperBound }
            .subscribe(onNext: { [weak self] text, cursorRange in
                guard let self = self else { return }
                let textData = OWUserMentionTextData(text: text, cursorRange: cursorRange, replacingText: nil)
                self.textData.onNext(textData)
            })
            .disposed(by: disposeBag)

        tappedMention
            .withLatestFrom(currentMentionRange) { ($0, $1) }
            .withLatestFrom(textViewText) { ($0.0, $0.1, $1) }
            .subscribe(onNext: { [weak self] mentionsData, currentMentionRange, textViewText in
                guard let self = self,
                      let currentMentionRange = currentMentionRange,
                      let tappedMentionString = mentionsData.tappedMentionString,
                      let textAfterMention = String(textViewText.utf16[currentMentionRange.upperBound...])
                else { return }
                let tappedMentionWithSpace = tappedMentionString + " "
                let utf8Range = NSRange(location: 0, length: tappedMentionWithSpace.utf16.count)
                let text = tappedMentionWithSpace + textAfterMention
                let startIndex = tappedMentionWithSpace.utf16.index(tappedMentionWithSpace.utf16.startIndex, offsetBy: utf8Range.lowerBound)
                let endIndex = tappedMentionWithSpace.utf16.index(startIndex, offsetBy: utf8Range.length)
                let stringRange = endIndex..<endIndex
                textChange.onNext(text)
                cursorRangeChange.onNext(stringRange)
            })
            .disposed(by: disposeBag)

        let styleChangedObserver = OWSharedServicesProvider.shared.themeStyleService().style

        Observable.combineLatest(styleChangedObserver, mentionsData, currentMentionRange)
            .withLatestFrom(textViewText) { ($0.1, $0.2, $1) }
            .subscribe(onNext: { [weak self] mentionsData, currentMentionRange, textViewText in
                guard let self = self,
                      !textViewText.isEmpty else { return }

                let attributedText: NSMutableAttributedString = NSMutableAttributedString(string: textViewText)

                let brandColor = OWColorPalette.shared.color(type: .brandColor, themeStyle: OWSharedServicesProvider.shared.themeStyleService().currentStyle)

                for mention in mentionsData.mentions {
                    attributedText.addAttribute(NSAttributedString.Key.foregroundColor,
                                                value: brandColor,
                                                range: mention.range)
                }

                if let currentMentionRange = currentMentionRange,
                   let range = textViewText.nsRange(from: currentMentionRange) {
                    attributedText.addAttribute(NSAttributedString.Key.foregroundColor,
                                                value: brandColor,
                                                range: range)
                }
                attributedTextChange.onNext(attributedText)
            })
            .disposed(by: disposeBag)

        textData
            .debounce(.microseconds(Metrics.debounceTextChange), scheduler: MainScheduler.instance)
            .filter { $0.replacingText == nil }
            .withLatestFrom(mentionsData) { ($0, $1) }
            .subscribe(onNext: { [weak self] textData, mentionsData in
                guard let self = self else { return }
                self.getUsersForName = ""
                self._currentMentionRange.onNext(nil)
                self.searchText(text: textData.textToCursor, mentions: mentionsData.mentions)
            })
            .disposed(by: disposeBag)

        textData
            .filter { $0.replacingText != nil }
            .withLatestFrom(mentionsData) { ($0, $1) }
            .subscribe(onNext: { textData, mentionsData in
                guard let replacingText = textData.replacingText,
                      let cursorRange = textData.text.nsRange(from: textData.cursorRange) else { return }
                var mentions: [OWUserMentionObject] = mentionsData.mentions.filter { cursorRange.location >= $0.range.location + $0.range.length }
                let mentionsToCheck = mentionsData.mentions.filter { cursorRange.location <= $0.range.location }
                for mention in mentionsToCheck {
                    if let mentionRange = Range(NSRange(location: mention.range.location + 1, length: mention.range.length - 1), in: textData.text),
                       !(textData.cursorRange ~= mentionRange) {
                        // update mention that replace is affecting
                        if textData.cursorRange.upperBound <= mentionRange.lowerBound { // Update mentionRange since replacing text before this mention
                            let distance = textData.text.utf16.distance(from: textData.cursorRange.lowerBound, to: textData.cursorRange.upperBound)
                            let addToRange = -distance + replacingText.utf16.count
                            let updatedMentionRange: NSRange = {
                                var range = mention.range
                                range.location += addToRange
                                range.length = mention.text.utf16.count
                                return range
                            }()
                            mention.range = updatedMentionRange
                        }
                        mentions.append(mention)
                    }
                }
                mentionsData.mentions = mentions
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
                let range = indexOfMention..<textWithMention.endIndex
                guard let self = self,
                      let selectedRange = textWithMention.nsRange(from: range) else { return }
                let userMentionObject = OWUserMentionObject(id: id, text: mentionDisplayText, range: selectedRange)

                let replaceRange = range.lowerBound..<textToCursor.utf16.endIndex
                if replaceRange.upperBound < textData.text.utf16.endIndex {
                    let mentions = mentionsData.mentions.filter { $0.range.location >= textToCursor.utf16.count }
                    for mention in mentions {
                        let replacedLength = textToCursor.utf16.distance(from: replaceRange.lowerBound, to: replaceRange.upperBound)
                        mention.range.location += mentionDisplayText.utf16.count - replacedLength + 1
                        mention.range.length = mention.text.utf16.count
                    }
                }

                mentionsData.mentions.append(userMentionObject)
                mentionsData.tappedMentionString = textWithMention
                self.tappedMentionAction.onNext(mentionsData)
            })
            .disposed(by: disposeBag)
    }
}
