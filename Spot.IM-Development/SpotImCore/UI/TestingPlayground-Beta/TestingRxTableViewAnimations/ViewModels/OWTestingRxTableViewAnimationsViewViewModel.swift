//
//  OWTestingRxTableViewAnimationsViewViewModel.swift
//  SpotImCore
//
//  Created by Alon Haiut on 25/04/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

#if BETA

import UIKit
import RxSwift

typealias OWTestingRxDataSourceModel = OWAnimatableSectionModel<String, OWTestingRxTableViewCellOption>

protocol OWTestingRxTableViewAnimationsViewViewModelingInputs { }

protocol OWTestingRxTableViewAnimationsViewViewModelingOutputs {
    var redCellsGeneratorVM: OWTestingCellsGeneratorViewModeling { get }
    var blueCellsGeneratorVM: OWTestingCellsGeneratorViewModeling { get }
    var greenCellsGeneratorVM: OWTestingCellsGeneratorViewModeling { get }
    var cellsDataSourceSections: Observable<[OWTestingRxDataSourceModel]> { get }
    var performTableViewAnimation: Observable<Void> { get }
}

protocol OWTestingRxTableViewAnimationsViewViewModeling {
    var inputs: OWTestingRxTableViewAnimationsViewViewModelingInputs { get }
    var outputs: OWTestingRxTableViewAnimationsViewViewModelingOutputs { get }
}

class OWTestingRxTableViewAnimationsViewViewModel: OWTestingRxTableViewAnimationsViewViewModeling,
                                OWTestingRxTableViewAnimationsViewViewModelingInputs,
                                OWTestingRxTableViewAnimationsViewViewModelingOutputs {
    var inputs: OWTestingRxTableViewAnimationsViewViewModelingInputs { return self }
    var outputs: OWTestingRxTableViewAnimationsViewViewModelingOutputs { return self }

    fileprivate struct Metrics {
        static let delayForTableViewAnimation: Int = 50 // In ms
    }

    fileprivate let disposeBag = DisposeBag()

    lazy var redCellsGeneratorVM: OWTestingCellsGeneratorViewModeling = {
        let requiredData = OWTestingCellsGeneratorRequiredData(color: .red, title: "Red")
        return OWTestingCellsGeneratorViewModel(requiredData: requiredData)
    }()

    lazy var blueCellsGeneratorVM: OWTestingCellsGeneratorViewModeling = {
        let requiredData = OWTestingCellsGeneratorRequiredData(color: .blue, title: "Blue")
        return OWTestingCellsGeneratorViewModel(requiredData: requiredData)
    }()

    lazy var greenCellsGeneratorVM: OWTestingCellsGeneratorViewModeling = {
        let requiredData = OWTestingCellsGeneratorRequiredData(color: .green, title: "Green")
        return OWTestingCellsGeneratorViewModel(requiredData: requiredData)
    }()

    fileprivate var cellsIdToIndexMapper = [String: Int]()

    fileprivate var _cellsViewModels = OWObservableArray<OWTestingRxTableViewCellOption>()
    fileprivate var cellsViewModels: Observable<[OWTestingRxTableViewCellOption]> {
        return _cellsViewModels
            .rx_elements()
            .asObservable()
    }

    var cellsDataSourceSections: Observable<[OWTestingRxDataSourceModel]> {
        return cellsViewModels
            .map { items in
                let section = OWTestingRxDataSourceModel(model: "TheOnlySection", items: items)
                return [section]
            }
    }

    fileprivate let _performTableViewAnimation = PublishSubject<Void>()
    var performTableViewAnimation: Observable<Void> {
        return _performTableViewAnimation
            .asObservable()
    }

    init() {
        setupObservers()
    }
}

fileprivate extension OWTestingRxTableViewAnimationsViewViewModel {
    // swiftlint:disable function_body_length
    func setupObservers() {
        // Update cells id to index mapper
        cellsViewModels
            .subscribe(onNext: { [weak self] cellOptions in
                guard let self = self else { return }
                self.cellsIdToIndexMapper.removeAll()
                for index in 0..<cellOptions.count {
                    let cellOption = cellOptions[index]
                    self.cellsIdToIndexMapper[cellOption.identifier] = index
                }
            })
            .disposed(by: disposeBag)

        // Adding cells subscribtion
        let addRedObservable = redCellsGeneratorVM.outputs.addCells
            .map { num -> [OWTestingRxTableViewCellOption] in
                var cellOptions = [OWTestingRxTableViewCellOption]()
                for _ in 1...num {
                    let vm = OWTestingRedCellViewModel()
                    let cellOption = OWTestingRxTableViewCellOption.red(viewModel: vm)
                    cellOptions.append(cellOption)
                }
                return cellOptions
            }

        let addBlueObservable = blueCellsGeneratorVM.outputs.addCells
            .map { num -> [OWTestingRxTableViewCellOption] in
                var cellOptions = [OWTestingRxTableViewCellOption]()
                for _ in 1...num {
                    let vm = OWTestingBlueCellViewModel()
                    let cellOption = OWTestingRxTableViewCellOption.blue(viewModel: vm)
                    cellOptions.append(cellOption)
                }
                return cellOptions
            }

        let addGreenObservable = greenCellsGeneratorVM.outputs.addCells
            .map { num -> [OWTestingRxTableViewCellOption] in
                var cellOptions = [OWTestingRxTableViewCellOption]()
                for _ in 1...num {
                    let vm = OWTestingGreenCellViewModel()
                    let cellOption = OWTestingRxTableViewCellOption.green(viewModel: vm)
                    cellOptions.append(cellOption)
                }
                return cellOptions
            }

        Observable.merge(addRedObservable, addBlueObservable, addGreenObservable)
            .subscribe(onNext: { [weak self] cellOptions in
                guard let self = self else { return }
                self._cellsViewModels.append(contentsOf: cellOptions)
            })
            .disposed(by: disposeBag)

        // Cells by colors observable
        let redCellsObservable = cellsViewModels
            .flatMapLatest { viewModels -> Observable<[OWTestingRedCellViewModeling]> in
                let redCellsVms: [OWTestingRedCellViewModeling] = viewModels.map { vm in
                    if case.red(let redCellViewModel) = vm {
                        return redCellViewModel
                    } else {
                        return nil
                    }
                }
                .unwrap()

                return Observable.just(redCellsVms)
            }
            .share(replay: 1)

        let blueCellsObservable = cellsViewModels
            .flatMapLatest { viewModels -> Observable<[OWTestingBlueCellViewModeling]> in
                let blueCellsVms: [OWTestingBlueCellViewModeling] = viewModels.map { vm in
                    if case.blue(let blueCellViewModel) = vm {
                        return blueCellViewModel
                    } else {
                        return nil
                    }
                }
                .unwrap()

                return Observable.just(blueCellsVms)
            }
            .share(replay: 1)

        let greenCellsObservable = cellsViewModels
            .flatMapLatest { viewModels -> Observable<[OWTestingGreenCellViewModeling]> in
                let greenCellsVms: [OWTestingGreenCellViewModeling] = viewModels.map { vm in
                    if case.green(let greenCellViewModel) = vm {
                        return greenCellViewModel
                    } else {
                        return nil
                    }
                }
                .unwrap()

                return Observable.just(greenCellsVms)
            }
            .share(replay: 1)

        // Removing individual cells subscribtion
        let removeRedIndexObservable = redCellsObservable
            .flatMapLatest { redCellsVms -> Observable<Int> in
                let reomveOutputObservable: [Observable<Int>] = redCellsVms.map { redCellVm in
                    return redCellVm.outputs.firstLevelVM
                        .outputs.secondLevelVM
                        .outputs.removeTapped
                        .map { redCellVm.outputs.id }
                        .map { [weak self] cellId -> Int? in
                            guard let self = self,
                                  let cellIndex = self.cellsIdToIndexMapper[cellId] else { return nil }
                            return cellIndex
                        }
                        .unwrap()
                }
                return Observable.merge(reomveOutputObservable)
            }

        let removeBlueIndexObservable = blueCellsObservable
            .flatMapLatest { blueCellsVms -> Observable<Int> in
                let reomveOutputObservable: [Observable<Int>] = blueCellsVms.map { blueCellVm in
                    return blueCellVm.outputs.firstLevelVM
                        .outputs.removeTapped
                        .map { blueCellVm.outputs.id }
                        .map { [weak self] cellId -> Int? in
                            guard let self = self,
                                  let cellIndex = self.cellsIdToIndexMapper[cellId] else { return nil }
                            return cellIndex
                        }
                        .unwrap()
                }
                return Observable.merge(reomveOutputObservable)
            }

        let removeGreenIndexObservable = greenCellsObservable
            .flatMapLatest { greenCellsVms -> Observable<Int> in
                let reomveOutputObservable: [Observable<Int>] = greenCellsVms.map { greenCellVm in
                    return greenCellVm.outputs.removeTapped
                        .map { greenCellVm.outputs.id }
                        .map { [weak self] cellId -> Int? in
                            guard let self = self,
                                  let cellIndex = self.cellsIdToIndexMapper[cellId] else { return nil }
                            return cellIndex
                        }
                        .unwrap()
                }
                return Observable.merge(reomveOutputObservable)
            }

        Observable.merge(removeRedIndexObservable, removeBlueIndexObservable, removeGreenIndexObservable)
            .subscribe(onNext: { [weak self] index in
                guard let self = self else { return }
                self._cellsViewModels.remove(at: index)
            })
            .disposed(by: disposeBag)

        // Removing entire cells type subscribtion
        let removeAllRedsObservable = redCellsGeneratorVM.outputs.removeAll
            .flatMapLatest { _ -> Observable<[OWTestingRedCellViewModeling]> in
                return redCellsObservable
                    .take(1)
            }
            .map { cellsVm -> [Int] in
                let indices: [Int] = cellsVm.map { [weak self] individualCellVm in
                    let cellId = individualCellVm.outputs.id
                    guard let self = self,
                          let cellIndex = self.cellsIdToIndexMapper[cellId] else { return nil }
                    return cellIndex
                }
                .unwrap()

                return indices
            }

        let removeAllBluesObservable = blueCellsGeneratorVM.outputs.removeAll
            .flatMapLatest { _ -> Observable<[OWTestingBlueCellViewModeling]> in
                return blueCellsObservable
                    .take(1)
            }
            .map { cellsVm -> [Int] in
                let indices: [Int] = cellsVm.map { [weak self] individualCellVm in
                    let cellId = individualCellVm.outputs.id
                    guard let self = self,
                          let cellIndex = self.cellsIdToIndexMapper[cellId] else { return nil }
                    return cellIndex
                }
                .unwrap()

                return indices
            }

        let removeAllGreensObservable = greenCellsGeneratorVM.outputs.removeAll
            .flatMapLatest { _ -> Observable<[OWTestingGreenCellViewModeling]> in
                return greenCellsObservable
                    .take(1)
            }
            .map { cellsVm -> [Int] in
                let indices: [Int] = cellsVm.map { [weak self] individualCellVm in
                    let cellId = individualCellVm.outputs.id
                    guard let self = self,
                          let cellIndex = self.cellsIdToIndexMapper[cellId] else { return nil }
                    return cellIndex
                }
                .unwrap()

                return indices
            }

        Observable.merge(removeAllRedsObservable, removeAllBluesObservable, removeAllGreensObservable)
            .filter { !$0.isEmpty }
            .subscribe(onNext: { [weak self] indices in
                guard let self = self else { return }
                self._cellsViewModels.remove(at: indices)
            })
            .disposed(by: disposeBag)

        // Updating table view about required animation
        let blueCellsChangedState = blueCellsObservable
            .flatMapLatest { blueCellsVms -> Observable<Void> in
                let changeStateObservable: [Observable<Void>] = blueCellsVms.map { blueCellVm in
                    return blueCellVm.outputs.firstLevelVM
                        .outputs.changeCellState
                        .skip(1)
                        .voidify()
                }
                return Observable.merge(changeStateObservable)
            }
        
        let greenCellsChangedState = greenCellsObservable
            .flatMapLatest { greenCellsVms -> Observable<Void> in
                let changeStateObservable: [Observable<Void>] = greenCellsVms.map { greenCellVm in
                    return greenCellVm.outputs.changeCellState
                        .skip(1)
                        .voidify()
                }
                return Observable.merge(changeStateObservable)
            }

        Observable.merge(blueCellsChangedState, greenCellsChangedState)
            // Minor delay, just to ensure the table view animation will be performed after constraints updated
            .delay(.milliseconds(Metrics.delayForTableViewAnimation), scheduler: MainScheduler.asyncInstance)
            .bind(to: _performTableViewAnimation)
            .disposed(by: disposeBag)
    }
}

#endif
