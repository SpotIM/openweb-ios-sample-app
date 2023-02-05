//
//  ArticlesListViewController.swift
//  Spot-IM.Development
//
//  Created by Itay Dressler on 14/08/2019.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import UIKit
import Foundation
import Alamofire
import SpotImCore
import SnapKit
import RxSwift

let cellIdentifier = "cards"

class ArticlesListViewController: UITableViewController {

    fileprivate struct Metrics {
        static let headerHeight: CGFloat = 50
    }

    fileprivate let disposeBag = DisposeBag()

    let spotId: String
    let authenticationControllerId: String
    var data: Response?
    let addToTableView: Bool
    let shouldReinit: Bool

    let customPostTextField = UITextField()

    init(spotId: String, authenticationControllerId: String, addToTableView: Bool = false, shouldReinint: Bool) {
        self.spotId = spotId

        self.authenticationControllerId = authenticationControllerId
        self.addToTableView = addToTableView
        self.shouldReinit = shouldReinint

        customPostTextField.placeholder = "custom postId"
        customPostTextField.borderStyle = .roundedRect
        customPostTextField.autocapitalizationType = .none
        customPostTextField.returnKeyType = .done

        super.init(style: .plain)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("Not supported")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        SpotIm.reinit = shouldReinit
        SpotIm.enableCustomNavigationItemTitle = true

        SpotIm.initialize(spotId: spotId) { result in
            switch result {
            case .failure(let error):
                DLog("SpotIm.initialize - error: \(error)")
            case .success(_):
                DLog("SpotIm.initialize successfully")
            }
        }

        SpotIm.configureLogger(logLevel: .verbose, logMethods: [.nsLog,
                                                                .file(maxFilesNumber: 50)])

        // Intentionally added this commented out part for easy testing in the future of temporality configurations
        // This will be our infra for adding stuff which is basically "noise", however important for testing stuff for our publishers
//        let additionalConfigurations: [SPAdditionalConfiguration] = [.suppressFinmbFilter]
//        SpotIm.setAdditionalConfigurations(configurations: additionalConfigurations)

        // This is the new implementation for publishers with monetization. The app developer should provide the AdsProvider implementation instance
        // to utilize the ad-network dependecies from the app target instead of the SDK.
        SpotIm.setGoogleAdsProvider(googleAdsProvider: GoogleAdsProvider())

        setup()
        loadData()
        setupObservers()

        title = "Articles"
    }

    override func viewWillDisappear(_ animated: Bool) {
        if self.isMovingFromParent {
            UserDefaultsProvider.shared.remove(key: UserDefaultsProvider.UDKey<Bool>.shouldShowOpenFullConversation)
            UserDefaultsProvider.shared.remove(key: UserDefaultsProvider.UDKey<Bool>.shouldPresentInNewNavStack)
            UserDefaultsProvider.shared.remove(key: UserDefaultsProvider.UDKey<Bool>.shouldOpenComment)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(false, animated: false)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data?.posts?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier,
                                                       for: indexPath) as? ArticleTableViewCell else {
                                                        return UITableViewCell()
        }

        if let item = data?.posts?[indexPath.item] {
            cell.post = item
            cell.delegate = self
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let post = self.data?.posts?[indexPath.item] {
            articleCellTapped(withPost: post)
        }
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: Metrics.headerHeight))
        headerView.backgroundColor = .white

        let headerStackView = UIStackView()
        headerStackView.spacing = 5
        headerStackView.alignment = .fill
        headerStackView.distribution = .equalSpacing

        let button = UIButton()
        button.setTitle("Custom PostId", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(customPostClicked), for: .touchUpInside)

        headerStackView.addArrangedSubview(button)
        headerStackView.addArrangedSubview(customPostTextField)

        headerView.addSubview(headerStackView)
        headerStackView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
        }

        return headerView
    }

    @objc private func customPostClicked() {
        if let postId = customPostTextField.text, let postForCopy = self.data?.posts?[0] {
            let post = Post(spotId: postForCopy.spotId,
                            conversationId: postId,
                            publishedAt: postForCopy.publishedAt,
                            extractData: postForCopy.extractData)
            articleCellTapped(withPost: post)
        }

    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
}

extension ArticlesListViewController: ArticleTableViewCellDelegate {
    func articleCellTapped(withPost post: Post?) {
        guard let post = post, let postId = postId(post: post) else { return }
        let customBIData = [
            "partner_id": "test1",
            "page_type": "test2",
            "product_id": "test3"
        ]
        let readOnlyMode = SpotImReadOnlyMode.parseSampleAppManualConfig()

        let metadata = SpotImArticleMetadata(url: post.extractData.url,
                                             title: post.extractData.title,
                                             subtitle: post.extractData.description,
                                             thumbnailUrl: post.extractData.thumbnailUrl,
                                             customBIData: customBIData, readOnlyMode: readOnlyMode)
        if addToTableView {
            // swiftlint:disable line_length
            let tableViewController = TableViewFooterTesterViewController(spotId: spotId,
                                                                          postId: postId,
                                                                          metadata: metadata,
                                                                          url: post.extractData.url,
                                                                          authenticationControllerId: authenticationControllerId)
            // swiftlint:enable line_length
            self.navigationController?.pushViewController(tableViewController, animated: true)
        } else {
            let articleViewController = ArticleWebViewController(spotId: spotId,
                                                                 postId: postId,
                                                                 metadata: metadata,
                                                                 url: post.extractData.url,
                                                                 authenticationControllerId: authenticationControllerId)
            self.navigationController?.pushViewController(articleViewController, animated: true)
        }
    }
}

extension ArticlesListViewController {

    @objc
    func reloadData() {
        self.data = nil
        self.tableView.reloadData()
        self.loadData()
    }

    private func loadData() {
        if spotId == "sp_ANQXRpqH" {
            refreshControl?.beginRefreshing()
            self.fetchData {[weak self] (response, error) in
                self?.refreshControl?.endRefreshing()
                guard let response = response, error == false else {
                    self?.showFailure()
                    return
                }
                print(response)
                self?.data = response
                if let posts = self?.data?.posts {
                    let indexPaths = posts.enumerated().map({ IndexPath(row: $0.offset, section: 0) })
                    self?.tableView.insertRows(at: indexPaths, with: .fade)
                }
            }
        } else {
            // swiftlint:disable line_length
            let posts = [Post(spotId: spotId,
                              conversationId: spotId + "_sdk1",
                              publishedAt: "2020-08-03T05:46:26Z",
                              extractData: Article(url: "https://pix11.com/2014/08/07/is-steve-jobs-alive-and-secretly-living-in-brazil-reddit-selfie-sparks-conspiracy-theories/", title: "He Doesn't Know How Volatile This Issue Is': Pro-Gun Group Responds To Trump Gun Control", width: 0, height: 0, description: "A gun rights group warned President Donald Trump Monday not to underestimate the volatile effect proposing gun control legislation could have on his base.", thumbnailUrl: "https://images.spot.im/v1/production/vtbnok9nqxxkpnhz7rru")),
                         Post(spotId: spotId, conversationId: spotId + "_sdk2",
                              publishedAt: "2020-08-02T05:46:26Z",
                              extractData: Article(url: "https://pix11.com/2014/08/07/is-steve-jobs-alive-and-secretly-living-in-brazil-reddit-selfie-sparks-conspiracy-theories/", title: "TAKALA: Think Google Controls The News? It's Worse Than You Think, Experts Say", width: 0, height: 0, description: "You're going to have a hard time finding negative information about Google in Axios or the Washington Post", thumbnailUrl: "https://images.spot.im/v1/production/d0aibkn9pyfeza52lz8a"))]
            self.data = Response(posts: posts)
            // swiftlint:enable line_length
        }
    }

    private func fetchData(completion: @escaping (_ data: Response?, _ error: Bool) -> Void) {
        let url = "https://api-2-0.spot.im/v1.0.0/feed/pitc/v1/\(spotId)/default?count=10&offset=0"
        AF.request(url,
                          method: .get,
                          parameters: nil,
                          encoding: JSONEncoding.default,
                          headers: nil)
            .validate()
            .responseData {response in
                guard let data = response.data else {
                    completion(nil, true)
                    return
                }
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let result = try decoder.decode(Response.self, from: data)

                    completion(result, false)
                } catch {
                    completion(nil, true)
                }
        }
    }

    private func showFailure() {
        let alert = UIAlertController(title: "Damn, failed loading these articles",
                                      message: "Try again soon",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {[weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }))
        self.present(alert, animated: true, completion: nil)
    }

    private func postId(post: Post?) -> String? {
        guard let post = post else { return nil }

        return post.conversationId.replacingOccurrences(of: "\(post.spotId)_", with: "")
    }
}

// MARK: Layout

extension ArticlesListViewController {
    func setup() {
        self.setupTableView()
    }

    func setupTableView() {
        tableView.register(ArticleTableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        tableView.separatorStyle = .none
        setupRefresh()
    }

    func setupRefresh() {
        let refresh = UIRefreshControl()
        refresh.addTarget(self, action: #selector(reloadData), for: UIControl.Event.valueChanged)
        tableView.refreshControl = refresh
    }
}

struct Response: Decodable {

    enum CodingKeys: String, CodingKey {
        case posts
    }

    let posts: [Post]?
}

extension ArticlesListViewController: SpotImLoginDelegate {
    func startLoginUIFlow(navigationController: UINavigationController) {
        let authVC: UIViewController
        if (authenticationControllerId == AuthenticationMetrics.defaultAuthenticationPlaygroundId) {
            authVC = AuthenticationPlaygroundVC()
        } else {
            // swiftlint:disable line_length
            authVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: authenticationControllerId)
            // swiftlint:enable line_length
        }
        navigationController.pushViewController(authVC, animated: true)
    }
}

fileprivate extension ArticlesListViewController {
    func setupObservers() {
        customPostTextField.rx.controlEvent([.editingDidEnd, .editingDidEndOnExit])
            .subscribe(onNext: { [weak self] _ in
                self?.customPostTextField.endEditing(true)
            })
            .disposed(by: disposeBag)
    }
}
