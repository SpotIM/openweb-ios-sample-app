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

        static let titleLabelSpacing: CGFloat = 10.0

        static let labelsContainerStackViewSpacing: CGFloat = 10.0
        static let commentLabelViewHeight: CGFloat = 28.0
    }

    fileprivate lazy var titleLabel: UILabel = {
        return UILabel()
            .numberOfLines(1)
            .font(OWFontBook.shared.font(typography: .footnoteContext))
            .textColor(OWColorPalette.shared.color(type: .textColor2,
                                                   themeStyle: OWSharedServicesProvider.shared.themeStyleService().currentStyle))
            .enforceSemanticAttribute()
    }()

    fileprivate lazy var labelsContainerStackView: UIStackView = {
        return UIStackView()
            .axis(.horizontal)
            .spacing(Metrics.labelsContainerStackViewSpacing)
            .distribution(.equalSpacing)
    }()

    fileprivate var titleZeroHeightConstraint: OWConstraint?
    fileprivate var labelsHeightConstraint: OWConstraint?
    fileprivate var labelsTopConstraint: OWConstraint?

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
        self.labelsContainerStackView.subviews.forEach { $0.removeFromSuperview() }
        self.labelsHeightConstraint?.update(offset: 0)
    }
}

fileprivate extension OWCommentLabelsContainerView {
    func setupUI() {
        self.enforceSemanticAttribute()

        addSubview(titleLabel)
        titleLabel.OWSnp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
            titleZeroHeightConstraint = make.height.equalTo(0).constraint
        }

        addSubview(labelsContainerStackView)
        labelsContainerStackView.OWSnp.makeConstraints { make in
            labelsTopConstraint = make.top.equalTo(titleLabel.OWSnp.bottom).constraint
            make.leading.trailing.bottom.equalToSuperview()
            labelsHeightConstraint = make.height.equalTo(0).constraint
        }
    }

    func setupObservers() {
        OWSharedServicesProvider.shared.themeStyleService()
            .style
            .subscribe(onNext: { [weak self] currentStyle in
                guard let self = self else { return }
                self.titleLabel.textColor = OWColorPalette.shared.color(type: .textColor2, themeStyle: currentStyle)
            }).disposed(by: disposeBag)

        viewModel.outputs.commentLabelsTitle
            .subscribe(onNext: { [weak self] title in
                OWScheduler.runOnMainThreadIfNeeded {
                    guard let self = self else { return }
                    self.titleLabel.text = title
                    self.titleZeroHeightConstraint?.isActive = title == nil
                    self.labelsTopConstraint?.update(offset: title == nil ? 0 : Metrics.titleLabelSpacing)
                }
            }).disposed(by: disposeBag)

        viewModel.outputs.commentLabelsViewModels
            .subscribe(onNext: { [weak self] viewModels in
                OWScheduler.runOnMainThreadIfNeeded {
                    guard let self = self else { return }
                    // clean stackview if needed
                    self.labelsContainerStackView.subviews.forEach { $0.removeFromSuperview() }
                    
                    self.labelsHeightConstraint?.update(offset: viewModels.isEmpty ? 0 : Metrics.commentLabelViewHeight)
                    
                    let commentLabelsViews: [OWCommentLabelView] = viewModels.map { vm in
                        let commentLabel = OWCommentLabelView()
                        commentLabel.configure(viewModel: vm)
                        return commentLabel
                    }
                    commentLabelsViews.forEach { self.labelsContainerStackView.addArrangedSubview($0) }
                }
            })
            .disposed(by: disposeBag)

        OWSharedServicesProvider.shared.appLifeCycle()
            .didChangeContentSizeCategory
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.titleLabel.font = OWFontBook.shared.font(typography: .footnoteContext)
            })
            .disposed(by: disposeBag)

        OWSharedServicesProvider.shared.orientationService()
            .orientation
            .subscribe(onNext: { [weak self] currentOrientation in
                guard let self = self else { return }

                let isLandscape = currentOrientation == .landscape
                self.titleLabel.isHidden = isLandscape
                self.titleZeroHeightConstraint?.isActive = isLandscape

                let titleLabelSpacing = self.titleLabel.text == nil ? 0 : Metrics.titleLabelSpacing
                self.labelsTopConstraint?.update(offset: isLandscape ? 0 : titleLabelSpacing)
            })
            .disposed(by: disposeBag)
    }
}

