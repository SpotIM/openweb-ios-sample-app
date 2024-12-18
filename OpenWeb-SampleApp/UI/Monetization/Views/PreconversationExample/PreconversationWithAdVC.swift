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
        tableView.register(ArticleImageCell.self,
                           forCellReuseIdentifier: ArticleImageCell.identifier)
        tableView.register(ArticleContentCell.self,
                           forCellReuseIdentifier: ArticleContentCell.identifier)
        tableView.register(PreConversationCell.self,
                           forCellReuseIdentifier: PreConversationCell.identifier)
   
        tableView.dataSource = self
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
        viewModel.outputs.preconversationCellViewModel.inputs.setNavigationController(self.navigationController)
        viewModel.outputs.preconversationCellViewModel.inputs.setPresentationalVC(self)

        viewModel.outputs.articleImageURL
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] url in
                self?.articleImageURL = url
            })
            .disposed(by: disposeBag)
    }
}

extension PreconversationWithAdVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ArticleImageCell.identifier, for: indexPath) as? ArticleImageCell else {
                fatalError("\(ArticleImageCell.identifier) must be registered first")
            }
            cell.configure(with: articleImageURL)
            return cell
        case 1:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ArticleContentCell.identifier, for: indexPath) as? ArticleContentCell else {
                fatalError("\(ArticleContentCell.identifier) must be registered first")
            }
            return cell
        case 2:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: PreConversationCell.identifier, for: indexPath) as? PreConversationCell else {
                fatalError("\(PreConversationCell.identifier) must be registered first")
            }
            cell.configure(with: viewModel.outputs.preconversationCellViewModel, tableView: tableView)
            
            return cell
        default:
            fatalError("Unexpected row index")
        }
    }
}
