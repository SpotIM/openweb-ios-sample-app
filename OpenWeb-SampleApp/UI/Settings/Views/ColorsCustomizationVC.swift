//
//  ColorsCustomizationVC.swift
//  OpenWeb-Development
//
//  Created by  Nogah Melamed on 31/12/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import Foundation
import UIKit
import Combine
import CombineExt
import CombineCocoa
import CombineDataSources

@available(iOS 14.0, *)
class ColorsCustomizationVC: UIViewController {
    private struct Metrics {
        static let horizontalOffset: CGFloat = 40
        static let verticalOffset: CGFloat = 24
        static let rowHeight: CGFloat = 50
    }

    private let viewModel: ColorsCustomizationViewModeling
    private var cancellables = Set<AnyCancellable>()

    private lazy var scrollView: UIScrollView = {
        return UIScrollView()
    }()

    private lazy var explainLabel: UILabel = {
        let label = UILabel()
        label.font = FontBook.paragraphBold
        label.text = "Both light and dark colors should be set in order to override OWTheme"
        label.numberOfLines = 0
        return label
    }()

    private lazy var tableView: UITableView = {
        let tblView = UITableView()
            .separatorStyle(.none)
        tblView.allowsSelection = false
        tblView.rowHeight = Metrics.rowHeight
        tblView.register(cellClass: ColorSelectionItemCell.self)
        return tblView
    }()

    private let picker = UIColorPickerViewController()

    init(viewModel: ColorsCustomizationViewModeling) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        setupObservers()
    }
}

@available(iOS 14.0, *)
private extension ColorsCustomizationVC {
    @objc func setupViews() {
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
            .flatMapLatest { cellsVms -> AnyPublisher<(ColorType, ColorSelectionItemCellViewModeling), Never> in
                let openPickerObservable: [AnyPublisher<(ColorType, ColorSelectionItemCellViewModeling), Never>] = cellsVms.map { vm in
                    return vm.outputs.displayPickerObservable
                        .map { ($0, vm) }
                        .eraseToAnyPublisher()
                }
                return Publishers.MergeMany(openPickerObservable)
                    .eraseToAnyPublisher()
            }

        openPickerObservers
            .map { colorType, vm -> CurrentValueSubject<UIColor?, Never> in
                switch colorType {
                case .light:
                    return vm.inputs.lightColor
                case .dark:
                    return vm.inputs.darkColor
                }
            }
            .handleEvents(receiveOutput: { [weak self] _ in
                self?.showPicker()
            })
            .flatMapLatest { [weak self] updateColor -> AnyPublisher<(UIColor?, CurrentValueSubject<UIColor?, Never>)?, Never> in
                guard let self else { return Just(nil).eraseToAnyPublisher() }
                return self.pickerColorPublisher
                    .map { ($0, updateColor) }
                    .eraseToAnyPublisher()
            }
            .unwrap()
            .sink { selectedColor, updateColor in
                updateColor.send(selectedColor)
            }
            .store(in: &cancellables)

        viewModel.outputs.cellsViewModels
            .bind(subscriber: tableView.rowsSubscriber(cellType: ColorSelectionItemCell.self, cellConfig: { cell, indexPath, viewModel in
                cell.configure(with: viewModel)
            }))
            .store(in: &cancellables)
    }

    func showPicker() {
        self.present(self.picker, animated: true)
    }

    var pickerColorPublisher: AnyPublisher<UIColor, Never> {
        return picker.publisher(for: \.selectedColor)
            .eraseToAnyPublisher()
    }
}
