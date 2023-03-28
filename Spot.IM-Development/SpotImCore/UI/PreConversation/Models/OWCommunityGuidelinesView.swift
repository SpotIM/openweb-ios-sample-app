//
//  OWCommunityGuidelinesView.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 05/09/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

// TODO: complete
class OWCommunityGuidelinesView: UIView {
    fileprivate struct Metrics {
        static let identifier = "community_guidelines_id"
        static let titleHorizontalOffset: CGFloat = 16.0
    }

    fileprivate lazy var titleTextView: UITextView = {
        let textView = UITextView()
            .backgroundColor(.clear)
            .delegate(self)
            .isEditable(false)
            .isSelectable(true)
            .isScrollEnabled(false)
            .dataDetectorTypes([.link])

        return textView
    }()

    fileprivate let viewModel: OWCommunityGuidelinesViewModeling
    fileprivate let disposeBag = DisposeBag()
    fileprivate var heightConstraint: OWConstraint? = nil

    init(with viewModel: OWCommunityGuidelinesViewModeling) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupViews()
        setupObservers()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

extension OWCommunityGuidelinesView {
    fileprivate func setupViews() {
        self.accessibilityIdentifier = Metrics.identifier
        self.backgroundColor = .clear
        self.addSubviews(titleTextView)
        titleTextView.OWSnp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            // avoide device notch in landscape
            if #available(iOS 11.0, *) {
                make.leading.equalTo(safeAreaLayoutGuide).offset(Metrics.titleHorizontalOffset)
                make.trailing.equalTo(safeAreaLayoutGuide).offset(-Metrics.titleHorizontalOffset)
            } else {
                make.leading.equalToSuperview().offset(Metrics.titleHorizontalOffset)
                make.trailing.equalToSuperview().offset(-Metrics.titleHorizontalOffset)
            }
            heightConstraint = make.height.equalTo(0).constraint
        }
    }

    fileprivate func setupObservers() {
        viewModel.outputs.shouldBeHidden
            .bind(to: self.rx.isHidden)
            .disposed(by: disposeBag)

        if let heightConstraint = heightConstraint {
            viewModel.outputs.shouldBeHidden
                .bind(to: heightConstraint.rx.isActive)
                .disposed(by: disposeBag)
        }

        viewModel.outputs.communityGuidelinesHtmlAttributedString
            .bind(to: titleTextView.rx.attributedText)
            .disposed(by: disposeBag)

        // disable selecting text - we need it to allow click on links
        titleTextView.rx.didChangeSelection
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.titleTextView.selectedTextRange = nil
            })
            .disposed(by: disposeBag)

        OWSharedServicesProvider.shared.themeStyleService()
            .style
            .subscribe(onNext: { [weak self] _ in
                // guard let self = self else { return }

                // TODO: custon UI
            }).disposed(by: disposeBag)
    }
}

extension OWCommunityGuidelinesView: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        viewModel.inputs.urlClicked.onNext(URL)
        return false
    }
}
