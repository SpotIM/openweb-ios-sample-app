//
//  TableViewFooterTesterViewController.swift
//  Spot-IM.Development
//
//  Created by Rotem Itzhak on 21/11/2019.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import Foundation
import UIKit
import SpotImCore

class TableViewFooterTesterViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return data.count
        }

        return 0
    }

    // swiftlint:disable line_length
    let data: [String] = ["First", "Second", "Third", "Forth", "First", "Second", "Third", "Forth", "First", "Second", "Third", "Forth", "First", "Second", "Third", "Forth", "First", "Second", "Third", "Forth", "First", "Second", "Third", "Forth", "First", "Second", "Third", "Forth"]
    // swiftlint:enable line_length

    var spotIMCoordinator: SpotImSDKFlowCoordinator?
    let spotIMContainerView = UIView()
    var setupSpotIM = false
    let tableView: UITableView = UITableView()
    let spotId: String
    let postId: String
    let url: String
    let authVCId: String
    var commentViewHeight: CGFloat = 0
    let metadata: SpotImArticleMetadata

    init(spotId: String, postId: String, metadata: SpotImArticleMetadata, url: String, authenticationControllerId: String) {
        self.spotId = spotId
        self.postId = postId
        self.url = url
        self.authVCId = authenticationControllerId
        self.metadata = metadata
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        SpotIm.initialize(spotId: spotId)
        setupTableView()
        SpotIm.createSpotImFlowCoordinator(loginDelegate: self) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let coordinator):
                self.spotIMCoordinator = coordinator
                coordinator.setLayoutDelegate(delegate: self)

                self.setupSpotView()
            case .failure(let error):
                print(error)
            }
        }

        navigationController?.setNavigationBarHidden(false, animated: false)
        tableView.delegate = self
        tableView.dataSource = self

        self.setupContainerView()
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell") else {
            return UITableViewCell(style: .default, reuseIdentifier: "cell")
            }
            return cell
        }()

        cell.textLabel?.text = data[indexPath.row]

        return cell
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 1 {
            return self.spotIMContainerView
        }

        return nil
    }

    private func setupContainerView() {
        spotIMContainerView.frame = CGRect(x: 0, y: 0, width: self.tableView.frame.size.width, height: 0)
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 1 {
            return commentViewHeight
        }

        return 0
    }

    private func setupSpotView() {
        guard self.setupSpotIM == false else {
            return
        }

        self.setupSpotIM = true
        spotIMCoordinator?.preConversationController(withPostId: self.postId,
                                                     articleMetadata: self.metadata,
                                                     navigationController: navigationController!) { preConversationVC in
            preConversationVC.view.translatesAutoresizingMaskIntoConstraints = false
            self.addChild(preConversationVC)
            self.spotIMContainerView.addSubview(preConversationVC.view)

            preConversationVC.view.topAnchor.constraint(equalTo: self.spotIMContainerView.topAnchor).isActive = true
            preConversationVC.view.leadingAnchor.constraint(equalTo: self.spotIMContainerView.leadingAnchor).isActive = true
            preConversationVC.view.bottomAnchor.constraint(equalTo: self.spotIMContainerView.bottomAnchor).isActive = true
            preConversationVC.view.trailingAnchor.constraint(equalTo: self.spotIMContainerView.trailingAnchor).isActive = true

            preConversationVC.didMove(toParent: self)
        }
    }

    private func setupTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
    }
}

extension TableViewFooterTesterViewController: SpotImLoginDelegate {
    func startLoginUIFlow(navigationController: UINavigationController) {
        let authenticationPlaygroundVC = AuthenticationPlaygroundVC()
        navigationController.pushViewController(authenticationPlaygroundVC, animated: true)
    }
}

extension TableViewFooterTesterViewController: SpotImLayoutDelegate {
    func viewHeightDidChange(to newValue: CGFloat) {
        commentViewHeight = newValue
        tableView.reloadSections(IndexSet(integer: 1), with: .none)
    }
}
