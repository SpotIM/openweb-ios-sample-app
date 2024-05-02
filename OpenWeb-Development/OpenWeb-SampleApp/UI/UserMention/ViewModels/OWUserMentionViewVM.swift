//
//  OWUserMentionViewVM.swift
//  OpenWebSDK
//
//  Created by Refael Sommer on 26/02/2024.
//  Copyright © 2024 OpenWeb. All rights reserved.
//

import Foundation
import RxSwift

typealias UserMentionsDataSourceModel = OWAnimatableSectionModel<String, OWUserMentionsCellOption>

protocol OWUserMentionViewViewModelingInputs {
    var textData: PublishSubject<OWUserMentionTextData> { get }
    var tappedMentionIndex: PublishSubject<Int> { get }

    var replaceData: PublishSubject<OWTextViewReplaceData> { get }
    var textViewText: PublishSubject<String> { get }
    var cursorRange: PublishSubject<Range<String.Index>> { get }

    var attributedTextChange: PublishSubject<NSAttributedString> { get }
    var textChange: PublishSubject<String> { get }
    var cursorRangeChange: PublishSubject<Range<String.Index>> { get }
    var initialMentions: PublishSubject<[OWUserMentionObject]?> { get }
    var viewFrameChanged: BehaviorSubject<CGRect> { get }
}

protocol OWUserMentionViewViewModelingOutputs {
    var userMentionsDataSourceSections: Observable<[UserMentionsDataSourceModel]> { get }
    var mentionsData: Observable<OWUserMentionData> { get }
    var currentMentionRange: Observable<Range<String.Index>?> { get }
    var tappedMention: Observable<OWUserMentionData> { get }

    var attributedTextChanged: Observable<NSAttributedString> { get }
    var textChanged: Observable<String> { get }
    var cursorRangeChanged: Observable<Range<String.Index>> { get }
    func isUserMentionAt(point: CGPoint) -> Bool
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
        static let debounceCursorChange = 10
    }

    var inputs: OWUserMentionViewViewModelingInputs { return self }
    var outputs: OWUserMentionViewViewModelingOutputs { return self }

    fileprivate let disposeBag = DisposeBag()
    fileprivate let servicesProvider: OWSharedServicesProviding
    fileprivate let randomGenerator: OWRandomGeneratorProtocol

    var replaceData = PublishSubject<OWTextViewReplaceData>()
    var textViewText = PublishSubject<String>()
    var cursorRange = PublishSubject<Range<String.Index>>()
    fileprivate var viewFrame: CGRect = .zero
    fileprivate var tappedMentionInProgress = false
    fileprivate var textAfterMention = BehaviorSubject<String>(value: "")

    var viewFrameChanged = BehaviorSubject<CGRect>(value: .zero)

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

    var initialMentions = PublishSubject<[OWUserMentionObject]?>()
    fileprivate lazy var _mentionsData = BehaviorSubject<OWUserMentionData>(value: OWUserMentionData())
    lazy var mentionsData: Observable<OWUserMentionData> = {
        return _mentionsData
            .asObservable()
    }()

    fileprivate lazy var _users = BehaviorSubject<[OWUserMention]>(value: [])
    fileprivate lazy var users: Observable<[OWUserMention]> = {
        return _users
            .asObservable()

    }()

    fileprivate let isSearchingUsers = BehaviorSubject<Bool>(value: false)

    var tappedMentionAction = PublishSubject<OWUserMentionData>()
    var tappedMention: Observable<OWUserMentionData> {
        return tappedMentionAction
            .asObservable()
    }

    fileprivate lazy var getUsers: Observable<[OWUserMention]> = {
        return name
            .withLatestFrom(users) { ($0, $1) }
            .do(onNext: { [weak self] name, users in
                guard let self = self else { return }
                if name.count > 0, users.count == 0 {
                    self.isSearchingUsers.onNext(true)
                }
                self.getUsersForName = name
            })
            .asObservable()
            .throttle(.milliseconds(Metrics.throttleGetUsers), scheduler: MainScheduler.instance)
            .flatMapLatest { [weak self] name, _ -> Observable<[OWUserMention]> in
                guard let self = self else { return .empty() }
                return self.servicesProvider.networkAPI()
                    .userMention
                    .getUsers(name: name, count: Metrics.usersCount)
                    .response
                    .materialize()
                    .map { [weak self] event in
                        guard let self = self,
                              self.getUsersForName == name else { return nil }
                        self.isSearchingUsers.onNext(false)
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

    fileprivate lazy var cellsViewModels: Observable<[OWUserMentionsCellOption]> = {
        return Observable.combineLatest(users, isSearchingUsers)
            .flatMapLatest({ [weak self] result -> Observable<[OWUserMentionsCellOption]> in
                let (users,
                     isSearchingUsers) = result
                if isSearchingUsers {
                    return Observable.just([OWUserMentionsCellOption.loading(viewModel: OWUserMentionLoadingCellViewModel())])
                }
                var viewModels: [OWUserMentionsCellOption] = []
                for user in users {
                    let viewModel = OWUserMentionCellViewModel(user: user)
                    viewModels.append(OWUserMentionsCellOption.mention(viewModel: viewModel))
                }
                return Observable.just(viewModels)
            })
            .asObservable()
    }()

    var userMentionsDataSourceSections: Observable<[UserMentionsDataSourceModel]> {
        return cellsViewModels
            .map { items in
                let section = UserMentionsDataSourceModel(model: "", items: items)
                return [section]
            }
    }

    init(servicesProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared,
         randomGenerator: OWRandomGeneratorProtocol = OWRandomGenerator()) {
        self.servicesProvider = servicesProvider
        self.randomGenerator = randomGenerator
        self.setupObservers()
    }

    func isUserMentionAt(point: CGPoint) -> Bool {
        return viewFrame.contains(point)
    }
}

fileprivate extension OWUserMentionViewVM {
    // swiftlint:disable function_body_length
    func setupObservers() {
        viewFrameChanged
            .subscribe(onNext: { [weak self] viewFrame in
                self?.viewFrame = viewFrame
            })
            .disposed(by: disposeBag)

        initialMentions
            .unwrap()
            .withLatestFrom(mentionsData) { ($0, $1) }
            .subscribe(onNext: { mentions, mentionsData in
                mentionsData.mentions = mentions
            })
            .disposed(by: disposeBag)

        replaceData
            .withLatestFrom(textViewText) { ($0, $1) }
            .subscribe(onNext: { [weak self] replaceData, text in
                guard let self = self else { return }
                let textData = OWUserMentionHelper.getUserMentionTextData(replaceData: replaceData, text: text)
                self.textData.onNext(textData)
            })
            .disposed(by: disposeBag)

        // Edit cursor range and select full user mention if current selected range is on user mention
        cursorRange
            .filter { [weak self] _ in
                guard let self = self else { return false }
                return !self.tappedMentionInProgress
            }
            .debounce(.microseconds(Metrics.debounceCursorChange), scheduler: MainScheduler.instance)
            .withLatestFrom(textViewText) { ($0, $1) }
            .withLatestFrom(mentionsData) { ($0.0, $0.1, $1) }
            .subscribe(onNext: { [weak self] cursorRange, text, mentionsData in
                guard let self = self else { return }
                if cursorRange.lowerBound != cursorRange.upperBound {
                    self.getUsersForName = ""
                    self._users.onNext([])
                }
                let updatedRange = OWUserMentionHelper.updateCurrentCursorRange(with: cursorRange, mentions: mentionsData.mentions, text: text)
                self.cursorRangeChange.onNext(updatedRange)
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

        tappedMentionIndex
            .withLatestFrom(cellsViewModels) { ($0, $1) }
            .flatMapLatest { index, cellsViewModels -> Observable<(String, String)> in
                guard index < cellsViewModels.count else { return .empty() }
                let selectedCellOption = cellsViewModels[index]
                guard let selectedCellVM = selectedCellOption.viewModel as? OWUserMentionCellViewModeling else { return .empty() }
                let id = selectedCellVM.outputs.id
                let selectedDisplayName = selectedCellVM.outputs.displayName
                return selectedDisplayName.map { ($0, id) }
            }
            .withLatestFrom(textData) { ($0.0, $0.1, $1) }
            .withLatestFrom(mentionsData) { ($0.0, $0.1, $0.2, $1) }
            .asObservable()
            .subscribe(onNext: { [weak self] displayName, id, textData, mentionsData in
                guard let self = self else { return }
                self.tappedMentionInProgress = true
                OWUserMentionHelper.addUserMention(to: mentionsData, textData: textData, id: id, displayName: displayName, randomGenerator: self.randomGenerator)
                self.tappedMentionAction.onNext(mentionsData)
                self.tappedMentionInProgress = false
            })
            .disposed(by: disposeBag)

        tappedMention
            .withLatestFrom(textAfterMention) { ($0, $1) }
            .subscribe(onNext: { [weak self] mentionsData, textAfterMention in
                guard let self = self,
                      let textData = OWUserMentionHelper.getUserMentionTextDataAfterTapped(mentionsData: mentionsData,
                                                                                           textAfterMention: textAfterMention) else { return }
                self.textChange.onNext(textData.text)
                self.cursorRangeChange.onNext(textData.cursorRange)
            })
            .disposed(by: disposeBag)

        let styleChangedObserver = OWSharedServicesProvider.shared.themeStyleService().style

        Observable.combineLatest(styleChangedObserver, mentionsData, currentMentionRange)
            .withLatestFrom(textViewText) { ($0.1, $0.2, $1) }
            .subscribe(onNext: { [weak self] mentionsData, currentMentionRange, textViewText in
                guard let self = self,
                let attributedText = OWUserMentionHelper.getAttributedText(for: textViewText, mentionsData: mentionsData, currentMentionRange: currentMentionRange) else { return }
                attributedTextChange.onNext(attributedText)
            })
            .disposed(by: disposeBag)

        textData
            .debounce(.microseconds(Metrics.debounceTextChange), scheduler: MainScheduler.instance)
            .filter { $0.replacingText == nil } // Adding text
            .withLatestFrom(mentionsData) { ($0, $1) }
            .subscribe(onNext: { [weak self] textData, mentionsData in
                guard let self = self else { return }
                self.getUsersForName = ""
                self._currentMentionRange.onNext(nil)
                self.searchText(textData.textToCursor, fullText: textData.fullText, mentions: mentionsData.mentions)
            })
            .disposed(by: disposeBag)

        textData
            .filter { $0.replacingText != nil } // Replacing text
            .withLatestFrom(mentionsData) { ($0, $1) }
            .subscribe(onNext: { [weak self] textData, mentionsData in
                if let textData = OWUserMentionHelper.updateMentionRanges(with: textData, mentionsData: mentionsData) {
                    guard let self = self else { return }
                    self.textChange.onNext(textData.text)
                    DispatchQueue.main.asyncAfter(deadline: .now()) { [weak self] in
                        self?.cursorRangeChange.onNext(textData.cursorRange)
                    }
                }
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
    }

    func searchText(_ searchText: String, fullText: String, mentions: [OWUserMentionObject]) {
        do {
            let regex = try NSRegularExpression(pattern: "\\@[^\\@]*$", options: [])
            var results = [String]()
            let range = searchText.startIndex..<searchText.endIndex
            guard let nsRange = searchText.nsRange(from: range) else {
                _users.onNext([])
                return
            }

            regex.enumerateMatches(in: searchText, range: nsRange) { [weak self] result, _, _ in
                guard let self = self else { return }
                if let r = result?.range, let range = Range(r, in: searchText) {
                    if !(mentions.contains(where: { mention in
                        let mentionRange = Range(mention.range, in: searchText)
                        return range.lowerBound == mentionRange?.lowerBound
                    })) {
                        let substring = String(searchText[range].dropFirst())
                        self._currentMentionRange.onNext(range)
                        self.textAfterMention.onNext(String(fullText[range.upperBound...]))
                        results.append(substring)
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
