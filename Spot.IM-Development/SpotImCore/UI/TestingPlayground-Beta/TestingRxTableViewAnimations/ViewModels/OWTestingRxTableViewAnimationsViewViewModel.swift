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

    init() {
        setupObservers()
    }
}

fileprivate extension OWTestingRxTableViewAnimationsViewViewModel {
    func setupObservers() {
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
    }
}

#endif
