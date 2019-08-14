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
import Spot_IM_Core

let cellIdentifier = "cards"

class ArticlesListViewController: UITableViewController {
    
    let spotId : String
    var data : Response?
    var spotIMCoordinator: SpotImSDKFlowCoordinator?
    
    init(spotId:String) {
        self.spotId = spotId
        super.init(style: .plain)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Not supported")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Articles List"
        loadData()
        tableView.register(ArticleTableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        tableView.separatorStyle = .none
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
        if let item = data?.posts?[indexPath.item], let postId = self.postId(post: item) {
            
            spotIMCoordinator = SpotImSDKFlowCoordinator(spotId: spotId,
                                                                 postId: postId,
                                                                 container: navigationController)
            spotIMCoordinator?.startFlow()
        }
    }
}

extension ArticlesListViewController : ArticleTableViewCellDelegate {
    func articleCellTapped(cell: ArticleTableViewCell, withPost post: Post?) {
        guard let post = post else { return }
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let articleViewController = storyboard.instantiateViewController(withIdentifier: "articleViewController") as! ArticleViewController
        articleViewController.spotId = spotId
        articleViewController.postId = postId(post: post)
        cell.shouldPresent(articleViewController, from: self, fullscreen: true)
    }
}

extension ArticlesListViewController {
    private func loadData() {
        let url = "https://api-gw.spot.im/v1.0.0/feed/spot/sp_ANQXRpqH/post/default/pitc?count=30&offset=0"
        Alamofire.request(url,
                          method: .get,
                          parameters: nil,
                          encoding: JSONEncoding.default,
                          headers: nil)
            .validate()
            .responseData {[weak self] response in
                guard let data = response.data else {
                    self?.showFailure()
                    return
                }
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let result = try decoder.decode(Response.self, from: data)
                    self?.data = result
                    if let posts = self?.data?.posts {
                        let indexPaths = posts.enumerated().map({ IndexPath(row: $0.offset, section: 0) })
                        self?.tableView.insertRows(at: indexPaths, with: .fade)
                    }
                }
                catch {
                    self?.showFailure()
                }
        }
    }
    
    private func showFailure() {
        let alert = UIAlertController(title: "Damn, failed loading these articles", message: "I'll try to make it work next time", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {[weak self] action in
            self?.navigationController?.popViewController(animated: true)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    private func postId(post:Post?) -> String? {
        guard let post = post else { return nil }
        return post.conversationId.replacingOccurrences(of: "\(post.spotId)_", with: "")
    }
}


struct Response: Decodable {
    
    enum CodingKeys: String, CodingKey {
        case posts
    }
    
    let posts: [Post]?
}


