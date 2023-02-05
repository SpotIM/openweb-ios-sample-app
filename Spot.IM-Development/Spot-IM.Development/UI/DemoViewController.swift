//
//  File.swift
//  YentSpot
//
//  Created by Rotem Itzhak on 26/11/2019.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import Foundation
import SpotImCore
import UIKit

class DemoArticlesList: UITableViewController {
    let spotId: String = DemoConfiguration.shared.spotId
    var data: [Post] = []
    var spotIMCoordinator: SpotImSDKFlowCoordinator?

    init() {
        super.init(style: .plain)

        data = DemoConfiguration.shared.articles
    }

    private func setupNavigationBar() {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .done, target: nil, action: nil)

        navigationController?.navigationBar.backgroundColor = DemoConfiguration.shared.spotColor
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.barTintColor = DemoConfiguration.shared.spotColor
        navigationController?.navigationBar.isTranslucent = false
        let fontName = DemoConfiguration.shared.spotFontName + "-Bold"
        navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.font: UIFont(name: fontName, size: 20.0) ?? UIFont.systemFont(ofSize: 20.0),
            NSAttributedString.Key.foregroundColor: UIColor.white
        ]
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        data = DemoConfiguration.shared.articles
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        SpotIm.initialize(spotId: spotId)

        SpotIm.configureLogger(logLevel: .verbose, logMethods: [.nsLog,
                                                                .file(maxFilesNumber: 50)])

        SpotIm.createSpotImFlowCoordinator(loginDelegate: self) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let coordinator):
                self.spotIMCoordinator = coordinator
            case .failure(let error):
                print(error)
            }
        }

        setup()
        setupNavigationBar()

        title = "Articles"
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(false, animated: false)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier,
                                                       for: indexPath) as? ArticleTableViewCell else {
                                                        return UITableViewCell()
        }

        let item = data[indexPath.item]

        cell.post = item
        cell.delegate = self

        return cell
    }
}

extension DemoArticlesList: ArticleTableViewCellDelegate {
    func articleCellTapped(cell: ArticleTableViewCell, withPost post: Post?) {
        guard let post = post, let postId = postId(post: post) else { return }

        let metadata = SpotImArticleMetadata(url: post.extractData.url,
                                             title: post.extractData.title,
                                             subtitle: post.extractData.description,
                                             thumbnailUrl: post.extractData.description)
        let articleViewController = ArticleWebViewController(spotId: spotId,
                                                             postId: postId,
                                                             metadata: metadata,
                                                             url: post.extractData.url,
                                                             authenticationControllerId: "")
        articleViewController.spotIMCoordinator = self.spotIMCoordinator
        self.spotIMCoordinator?.setLayoutDelegate(delegate: articleViewController)
        self.navigationController?.pushViewController(articleViewController, animated: true)
    }
}

extension DemoArticlesList {

    @objc
    func reloadData() {
        self.tableView.reloadData()
    }

    private func postId(post: Post?) -> String? {
        guard let post = post else { return nil }

        return post.conversationId.replacingOccurrences(of: "\(post.spotId)_", with: "")
    }
}

extension DemoArticlesList {
    func setup() {
        self.setupTableView()
    }

    func setupTableView() {
        tableView.register(ArticleTableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        tableView.separatorStyle = .none
    }
}

extension DemoArticlesList: SpotImLoginDelegate {
    func startLoginUIFlow(navigationController: UINavigationController) {
        let storyboard = UIStoryboard(name: "Demo", bundle: nil)
        let authVC = storyboard.instantiateViewController(withIdentifier: "DemoAuthVC")
        navigationController.pushViewController(authVC, animated: true)
    }
}
