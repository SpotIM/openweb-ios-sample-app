//
//  PreconversationViewsWithAdVC.swift
//  OpenWeb-SampleApp
//
//  Created by Anael on 15/01/2025.
//

import RxSwift
import UIKit

class PreconversationViewsWithAdVC: UIViewController {
    private let viewModel: PreconversationViewsWithAdViewModeling
    private let disposeBag = DisposeBag()

    private struct Metrics {
        static let loggerViewWidth: CGFloat = 300
        static let loggerViewHeight: CGFloat = 250
        static let loggerInitialTopPadding: CGFloat = 50
    }

    private lazy var floatingLoggerView: OWFloatingView = {
        return OWFloatingView(viewModel: viewModel.outputs.floatingViewViewModel)
    }()

    private lazy var loggerView: UILoggerView = {
        return UILoggerView(viewModel: viewModel.outputs.loggerViewModel)
    }()

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

    init(viewModel: PreconversationViewsWithAdViewModeling) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        floatingLoggerView.removeFromSuperview()
    }

    override func loadView() {
        super.loadView()
        setupViews()
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

    private func setupViews() {
        if #available(iOS 13.0, *) {
            #if !PUBLIC_DEMO_APP
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow }) {
                // Add it to the window
                floatingLoggerView.isHidden = true
                keyWindow.addSubview(floatingLoggerView)
                floatingLoggerView.snp.makeConstraints { make in
                    make.width.equalTo(Metrics.loggerViewWidth)
                    make.height.equalTo(Metrics.loggerViewHeight)
                    make.top.equalToSuperview().offset(Metrics.loggerInitialTopPadding)
                    make.centerX.equalToSuperview()
                }
            }
            #endif
        }
    }

    private func setupObservers() {
        title = viewModel.outputs.title

        viewModel.inputs.setNavigationController(self.navigationController)
        viewModel.inputs.setPresentationalVC(self)

        viewModel.outputs.floatingViewViewModel.inputs.setContentView.onNext(loggerView)

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

        viewModel.outputs.loggerEnabled
            .delay(.milliseconds(10), scheduler: MainScheduler.instance)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] loggerEnabled in
                guard let self else { return }
                self.floatingLoggerView.isHidden = !loggerEnabled
            })
            .disposed(by: disposeBag)
    }
}
