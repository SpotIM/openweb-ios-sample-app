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
    
    init(spotId:String, authenticationControllerId: String, addToTableView: Bool = false) {
        self.spotId = spotId
        
        self.authenticationControllerId = authenticationControllerId
        self.addToTableView = addToTableView
        
        super.init(style: .plain)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Not supported")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    
}

extension ArticlesListViewController : ArticleTableViewCellDelegate {
    func articleCellTapped(cell: ArticleTableViewCell, withPost post: Post?) {
        guard let post = post, let postId = postId(post: post) else { return }
        if addToTableView {
            let tableViewController = TableViewFooterTesterViewController(spotId: spotId, postId:postId, url: post.extractData.url, authenticationControllerId: authenticationControllerId)
            self.navigationController?.pushViewController(tableViewController, animated: true)
        } else {
            let articleViewController = ArticleWebViewController(spotId: spotId, postId:postId, url: post.extractData.url, authenticationControllerId: authenticationControllerId)
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
        refreshControl?.beginRefreshing()
        self.fetchData {[weak self] (response, error) in
            self?.refreshControl?.endRefreshing()
            guard let response = response, error == false else {
                self?.showFailure()
                return
            }
            
            self?.data = response
            if let posts = self?.data?.posts {
                let indexPaths = posts.enumerated().map({ IndexPath(row: $0.offset, section: 0) })
                self?.tableView.insertRows(at: indexPaths, with: .fade)
            }
        }
    }
    
    private func fetchData(completion: @escaping (_ data:Response?, _ error:Bool) -> Void) {
        let url = "https://api-gw.spot.im/v1.0.0/feed/spot/\(spotId)/post/default/pitc?count=30&offset=0"
        let headers = ["x-spot-id": spotId,
                       "x-post-id": "default"]
        Alamofire.request(url,
                          method: .get,
                          parameters: nil,
                          encoding: JSONEncoding.default,
                          headers: headers)
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
