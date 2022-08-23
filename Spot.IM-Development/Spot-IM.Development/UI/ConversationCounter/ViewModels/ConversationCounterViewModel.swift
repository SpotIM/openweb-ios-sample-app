//
//  ConversationCounterViewModel.swift
//  Spot-IM.Development
//
//  Created by Alon Haiut on 22/08/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import RxSwift
import Alamofire
import SpotImCore

protocol ConversationCounterViewModelingInputs {
    var loadConversationCounter: PublishSubject<[String]> { get }
}

protocol ConversationCounterViewModelingOutputs {
    var title: String { get }
    var cellsViewModels: Observable<[ConversationCounterCellViewModeling]> { get }
    var showError: Observable<String> { get }
    var showLoader: Observable<Bool> { get }
}

protocol ConversationCounterViewModeling {
    var inputs: ConversationCounterViewModelingInputs { get }
    var outputs: ConversationCounterViewModelingOutputs { get }
}

class ConversationCounterViewModel: ConversationCounterViewModeling, ConversationCounterViewModelingInputs, ConversationCounterViewModelingOutputs {
    var inputs: ConversationCounterViewModelingInputs { return self }
    var outputs: ConversationCounterViewModelingOutputs { return self }
    
    let dataModel: ConversationCounterRequiredData
    
    lazy var title: String = {
        return NSLocalizedString("ConversationCounterTitle", comment: "")
    }()
    
    let loadConversationCounter = PublishSubject<[String]>()
    
    fileprivate let _shouldShowError = BehaviorSubject<Bool>(value: false)
    fileprivate let _showError = PublishSubject<String>()
    var showError: Observable<String> {
        return _showError
            .asObservable()
    }
    
    fileprivate let _showLoader = BehaviorSubject<Bool?>(value: nil)
    var showLoader: Observable<Bool> {
        return _showLoader
            .unwrap()
            .asObservable()
    }
    
    fileprivate let _cellsViewModels = BehaviorSubject<[ConversationCounterCellViewModeling]?>(value: nil)
    var cellsViewModels: Observable<[ConversationCounterCellViewModeling]> {
        return Observable.combineLatest(_cellsViewModels, _shouldShowError, showLoader) { viewModels, shouldShowError, shouldShowLoader in
            guard !shouldShowLoader, !shouldShowError, let cellVMs = viewModels else { return [] }
            return cellVMs
        }
    }
    
    fileprivate let disposeBag = DisposeBag()
    
    init(dataModel: ConversationCounterRequiredData) {
        self.dataModel = dataModel
        initSDK()
        setupObservers()
    }
}

fileprivate extension ConversationCounterViewModel {
    func initSDK() {
        SpotIm.reinit = dataModel.shouldReinit
        SpotIm.initialize(spotId: dataModel.spotId) { result in
            switch result {
            case .failure(let error):
                DLog("SpotIm.initialize - error: \(error)")
                self._shouldShowError.onNext(true)
                self._showError.onNext("Failed SDK initialization - error: \(error)")
            case .success(_):
                DLog("SpotIm.initialize successfully")
            }
        }
    }
    
    func setupObservers() {
        loadConversationCounter
            .do(onNext: { [weak self] _ in
                self?._showLoader.onNext(true)
                self?._shouldShowError.onNext(false)
            })
            .subscribe(onNext: { [weak self] postIds in
                guard let self = self else { return }
                SpotIm.getConversationCounters(conversationIds: postIds) { [weak self] result in
                    guard let self = self else { return }
                    self._showLoader.onNext(true)
                    
                    switch result {
                    case .success(let commentDic):
                        let postIdsKeys = commentDic.keys
                        var cellViewModels = [ConversationCounterCellViewModeling]()
                        
                        for id in postIdsKeys {
                            guard let counter = commentDic[id] else { continue }
                            let cellViewModel = (ConversationCounterCellViewModel(counter: counter, postId: id))
                            cellViewModels.append(cellViewModel)
                        }
                        
                        self._cellsViewModels.onNext(cellViewModels)
                    case .failure(let error):
                        DLog(error)
                        self._shouldShowError.onNext(true)
                        self._showError.onNext(error.localizedDescription)
                    }
                }
            })
            .disposed(by: disposeBag)
    }
}
