//
//  OWCommentLabelsContainerView.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 10/01/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import UIKit
import RxSwift

class OWCommentLabelsContainerView: UIView {
    fileprivate struct Metrics {
        static let identifier = "comment_labels_container_id"

        static let labelsContainerStackViewSpacing: CGFloat = 10.0
        static let commentLabelViewHeight: CGFloat = 28.0
    }

    fileprivate lazy var labelsContainerStackView: UIStackView = {
        return UIStackView()
            .spacing(Metrics.labelsContainerStackViewSpacing)
    }()
    fileprivate var heightConstraint: OWConstraint?
    
    fileprivate var viewModel: OWCommentLabelsContainerViewModeling!
    fileprivate var disposeBag: DisposeBag!

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.accessibilityIdentifier = Metrics.identifier
        setupUI()
    }

    func configure(viewModel: OWCommentLabelsContainerViewModeling) {
        self.viewModel = viewModel
        disposeBag = DisposeBag()
        setupObservers()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func prepareForReuse() {
        // clean stackview if needed
        self.labelsContainerStackView.subviews.forEach { view in
            view.removeFromSuperview()
        }
        self.heightConstraint?.update(offset: 0)
    }
}

fileprivate extension OWCommentLabelsContainerView {
    func setupUI() {
        addSubview(labelsContainerStackView)
        labelsContainerStackView.OWSnp.makeConstraints { make in
            make.edges.equalToSuperview()
            heightConstraint = make.height.equalTo(0).constraint
        }
    }

    func setupObservers() {
        viewModel.outputs.commentLabelsViewModels
            .subscribe(onNext: { [weak self] viewModels in
                guard let self = self else { return }
                // clean stackview if needed
                self.labelsContainerStackView.subviews.forEach { $0.removeFromSuperview() }
                
                if viewModels.count > 0 {
                    self.heightConstraint?.update(offset: Metrics.commentLabelViewHeight)
                }

                let commentLabelsViews: [OWCommentLabelView] = viewModels.map { vm in
                    let commentLabel = OWCommentLabelView()
                    commentLabel.configure(viewModel: vm)
                    return commentLabel
                }
                commentLabelsViews.forEach { self.labelsContainerStackView.addArrangedSubview($0) }
            })
            .disposed(by: disposeBag)
    }
}

