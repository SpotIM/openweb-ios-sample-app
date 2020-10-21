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

let cellIdentifier = "cards"

class ArticlesListViewController: UITableViewController {
    
    let spotId : String
    let authenticationControllerId: String
    var data : Response?
    let addToTableView: Bool
    let useLoginDelegate: Bool
    let shouldReinit: Bool
    
    init(spotId:String, authenticationControllerId: String, addToTableView: Bool = false, useLoginDelegate: Bool, shouldReinint: Bool) {
        self.spotId = spotId
        
        self.authenticationControllerId = authenticationControllerId
        self.addToTableView = addToTableView
        self.useLoginDelegate = useLoginDelegate
        self.shouldReinit = shouldReinint
        
        super.init(style: .plain)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Not supported")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SpotIm.reinit = shouldReinit
        SpotIm.initialize(spotId: spotId)
        
        setup()
        loadData()

        title = "Articles"
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
}

extension ArticlesListViewController : ArticleTableViewCellDelegate {
    func articleCellTapped(withPost post: Post?) {
        guard let post = post, let postId = postId(post: post) else { return }
        let metadata = SpotImArticleMetadata(url: post.extractData.url, title: post.extractData.title, subtitle: post.extractData.description, thumbnailUrl: post.extractData.thumbnailUrl)
        if addToTableView {
            let tableViewController = TableViewFooterTesterViewController(spotId: spotId, postId:postId, metadata: metadata, url: post.extractData.url, authenticationControllerId: authenticationControllerId)
            self.navigationController?.pushViewController(tableViewController, animated: true)
        } else {
            let articleViewController = ArticleWebViewController(spotId: spotId, postId:postId, metadata: metadata, url: post.extractData.url, authenticationControllerId: authenticationControllerId, useLoginDelegate: useLoginDelegate)
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
            let posts = [Post(spotId: spotId, conversationId: spotId + "_sdk1", publishedAt: "2020-08-03T05:46:26Z", extractData: Article(url: "https://pix11.com/2014/08/07/is-steve-jobs-alive-and-secretly-living-in-brazil-reddit-selfie-sparks-conspiracy-theories/", title: "He Doesn't Know How Volatile This Issue Is': Pro-Gun Group Responds To Trump Gun Control", width: 0, height: 0, description: "A gun rights group warned President Donald Trump Monday not to underestimate the volatile effect proposing gun control legislation could have on his base.", thumbnailUrl: "https://images.spot.im/v1/production/vtbnok9nqxxkpnhz7rru")),
                         Post(spotId: spotId, conversationId: spotId + "_sdk2", publishedAt: "2020-08-02T05:46:26Z", extractData: Article(url: "https://pix11.com/2014/08/07/is-steve-jobs-alive-and-secretly-living-in-brazil-reddit-selfie-sparks-conspiracy-theories/", title: "TAKALA: Think Google Controls The News? It's Worse Than You Think, Experts Say", width: 0, height: 0, description: "You're going to have a hard time finding negative information about Google in Axios or the Washington Post", thumbnailUrl: "https://images.spot.im/v1/production/d0aibkn9pyfeza52lz8a"))]
            self.data = Response(posts: posts)
        }
    }
    
    private func fetchData(completion: @escaping (_ data:Response?, _ error:Bool) -> Void) {
        let url = "https://api-gw.spot.im/v1.0.0/feed/spot/\(spotId)/post/default/pitc?count=30&offset=0"
        
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
                }
                catch {
                    completion(nil, true)
                }
        }
    }
    
    private func showFailure() {
        let alert = UIAlertController(title: "Damn, failed loading these articles", message: "Try again soon", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {[weak self] action in
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

extension ArticlesListViewController: SpotImSDKNavigationDelegate {
    func controllerForSSOFlow() -> UIViewController {
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: authenticationControllerId)
        
        return controller
    }
}
