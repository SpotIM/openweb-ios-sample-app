//
//  PreconversationWithAdVC.swift
//  OpenWeb-SampleApp
//
//  Created by Anael on 11/12/2024.
//

import RxSwift
import UIKit

class PreconversationWithAdVC: UIViewController {
    private let viewModel: PreconversationWithAdViewModeling
    private let disposeBag = DisposeBag()

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 500
        for option in PreconversationWithAdCellOption.allCases {
            tableView.register(cellClass: option.cellClass)
        }

        return tableView
    }()

    private var articleImageURL: URL?

    init(viewModel: PreconversationWithAdViewModeling) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ColorPalette.shared.color(type: .background)
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }

        setupObservers()
    }

    private func setupObservers() {
        title = viewModel.outputs.title

        viewModel.outputs.preconversationCellViewModel.inputs.setNavigationController(self.navigationController)
        viewModel.outputs.preconversationCellViewModel.inputs.setPresentationalVC(self)

        viewModel.outputs.cells
            .bind(to: tableView.rx.items) { [weak self] tableView, _, option in
                guard let self else { return UITableViewCell() }
                    switch option {
                    case .image:
                        guard let cell = tableView.dequeueReusableCell(withIdentifier: ArticleImageCell.identifier) as? ArticleImageCell else {
                            fatalError("\(ArticleImageCell.identifier) must be registered first")
                        }
                        cell.configure(with: self.articleImageURL)
                        return cell

                    case .content:
                        guard let cell = tableView.dequeueReusableCell(withIdentifier: ArticleContentCell.identifier) as? ArticleContentCell else {
                            fatalError("\(ArticleContentCell.identifier) must be registered first")
                        }
                        return cell

                    case .independentAd:
                        guard let cell = tableView.dequeueReusableCell(withIdentifier: IndependentAdCell.identifier) as? IndependentAdCell else {
                            fatalError("\(IndependentAdCell.identifier) must be registered first")
                        }
                        cell.configure(with: self.viewModel.outputs.independentAdCellViewModel, tableView: tableView)
                        return cell

                    case .preconversation:
                        guard let cell = tableView.dequeueReusableCell(withIdentifier: PreConversationCell.identifier) as? PreConversationCell else {
                            fatalError("\(PreConversationCell.identifier) must be registered first")
                        }
                        cell.configure(with: self.viewModel.outputs.preconversationCellViewModel, tableView: tableView)
                        return cell
                    }
            }
            .disposed(by: disposeBag)

        viewModel.outputs.articleImageURL
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] url in
                self?.articleImageURL = url
            })
            .disposed(by: disposeBag)
    }
}
