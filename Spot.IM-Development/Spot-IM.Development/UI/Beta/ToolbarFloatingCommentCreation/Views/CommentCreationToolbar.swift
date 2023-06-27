//
//  CommentCreationToolbar.swift
//  Spot-IM.Development
//
//  Created by Alon Haiut on 27/06/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import UIKit
import RxSwift
import SnapKit

class CommentCreationToolbar: UIView {

    fileprivate lazy var toolbarCollection: UICollectionView = {
        let collection = UICollectionView()
        return collection
    }()

    fileprivate let viewModel: CommentCreationToolbarViewModeling
    fileprivate let disposeBag = DisposeBag()

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(viewModel: CommentCreationToolbarViewModeling) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupUI()
        setupObservers()
    }

}

fileprivate extension CommentCreationToolbar {
    func setupUI() {
        self.addSubview(toolbarCollection)
        toolbarCollection.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    func setupObservers() {

    }
}
