//
//  ColorsCustomizationVC.swift
//  Spot-IM.Development
//
//  Created by  Nogah Melamed on 31/12/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

@available(iOS 14.0, *)
class ColorsCustomizationVC: UIViewController {
    fileprivate struct Metrics {
        static let horizontalOffset: CGFloat = 40
        static let verticalOffset: CGFloat = 24
        static let rowHeight: CGFloat = 50
    }

    fileprivate let viewModel: ColorsCustomizationViewModeling
    fileprivate let disposeBag = DisposeBag()

    fileprivate lazy var scrollView: UIScrollView = {
        return UIScrollView()
    }()

    fileprivate lazy var explainLabel: UILabel = {
        let label = UILabel()
        label.font = FontBook.paragraphBold
        label.text = "Both light and dark colors should be set in order to override OWTheme"
        label.numberOfLines = 0
        return label
    }()

    fileprivate lazy var tableView: UITableView = {
        let tblView = UITableView()
            .separatorStyle(.none)
        tblView.allowsSelection = false
        tblView.rowHeight = Metrics.rowHeight
        tblView.register(cellClass: ColorSelectionItemCell.self)
        return tblView
    }()

    fileprivate let picker = UIColorPickerViewController()

    init(viewModel: ColorsCustomizationViewModeling) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        super.loadView()
        setupViews()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupObservers()
    }
}

@available(iOS 14.0, *)
fileprivate extension ColorsCustomizationVC {
    func setupViews() {
        view.backgroundColor = ColorPalette.shared.color(type: .background)
        applyLargeTitlesIfNeeded()

        title = viewModel.outputs.title

        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide)
        }

        scrollView.addSubview(explainLabel)
        explainLabel.snp.makeConstraints { make in
            make.top.equalTo(scrollView.contentLayoutGuide).offset(Metrics.horizontalOffset)
            make.leading.equalTo(scrollView).inset(Metrics.verticalOffset)
            make.trailing.equalTo(view.safeAreaLayoutGuide).inset(Metrics.verticalOffset)
        }

        scrollView.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(explainLabel.snp.bottom).offset(Metrics.horizontalOffset)
            make.bottom.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide)
        }
    }

    func setupObservers() {
        let openPickerObservers = viewModel.outputs.cellsViewModels
            .flatMapLatest { cellsVms -> Observable<(ColorType, ColorSelectionItemCellViewModeling)> in
                let openPickerObservable: [Observable<(ColorType, ColorSelectionItemCellViewModeling)>] = cellsVms.map { vm in
                    return vm.outputs.displayPickerObservable
                        .map { ($0, vm) }
                }
                return Observable.merge(openPickerObservable)
            }

        openPickerObservers
            .map { colorType, vm -> BehaviorSubject<UIColor?> in
                switch colorType {
                case .light:
                    return vm.inputs.lightColor
                case .dark:
                    return vm.inputs.darkColor
                }
            }
            .do(onNext: { [weak self] _ in
                self?.showPicker()
            })
            .flatMapLatest { [weak self] updateColor -> Observable<(UIColor?, BehaviorSubject<UIColor?>)?> in
                guard let self = self else { return .empty() }
                return self.picker.rx.didSelectColor
                    .map { ($0, updateColor) }
            }
            .unwrap()
            .subscribe(onNext: { selectedColor, updateColor in
                updateColor.onNext(selectedColor)
            })
            .disposed(by: disposeBag)

        viewModel.outputs.cellsViewModels
            .bind(to: tableView.rx.items(cellIdentifier: ColorSelectionItemCell.identifierName,
                                         cellType: ColorSelectionItemCell.self)) { _, viewModel, cell in
                cell.configure(with: viewModel)
            }
            .disposed(by: disposeBag)
    }

    func showPicker() {
        self.present(self.picker, animated: true)
    }
}

@available(iOS 14.0, *)
fileprivate extension Reactive where Base: UIColorPickerViewController {
    var didSelectColor: Observable<UIColor?> {
        return Observable.create { observer in
            let token = self.base.observe(\.selectedColor) { _, _ in
                observer.onNext(self.base.selectedColor)
            }

            return Disposables.create {
                token.invalidate()
            }
        }
    }
}
