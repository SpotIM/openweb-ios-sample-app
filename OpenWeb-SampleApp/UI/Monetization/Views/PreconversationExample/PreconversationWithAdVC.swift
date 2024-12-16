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
        tableView.register(ArticleImageCell.self, forCellReuseIdentifier: ArticleImageCell.identifier)
        tableView.register(ArticleContentCell.self, forCellReuseIdentifier: ArticleContentCell.identifier)
        tableView.register(PreConversationCell.self, forCellReuseIdentifier: PreConversationCell.identifier)
        tableView.dataSource = self
        return tableView
    }()
    
    private var preConversationView: UIView?
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
        viewModel.inputs.setNavigationController(self.navigationController)
        viewModel.inputs.setPresentationalVC(self)

        viewModel.outputs.articleImageURL
            .subscribe(onNext: { [weak self] url in
                self?.articleImageURL = url
                self?.tableView.reloadData()
            })
            .disposed(by: disposeBag)
        
        viewModel.outputs.showPreConversation
            .subscribe(onNext: { [weak self] preConversation in
                self?.preConversationView = preConversation
                self?.tableView.reloadData()
            })
            .disposed(by: disposeBag)
    }
}

extension PreconversationWithAdVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // 2 cells by default (image + content), 3 if preConversationView exists
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: ArticleImageCell.identifier, for: indexPath) as! ArticleImageCell
            cell.configure(with: articleImageURL)
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: ArticleContentCell.identifier, for: indexPath) as! ArticleContentCell
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: PreConversationCell.identifier, for: indexPath) as! PreConversationCell
            cell.configure(with: preConversationView)
            
            return cell
        default:
            fatalError("Unexpected row index")
        }
    }
}
