//
//  OWCommunityGuidelinesView.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 05/09/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import UIKit
import RxSwift

// TODO: complete
internal final class OWCommunityGuidelinesView: OWBaseView {
    fileprivate struct Metrics {
        static let identifier = "community_guidelines_id"
        static let titleHorizontalOffset: CGFloat = 16.0
        static let separatorHeight: CGFloat = 1.0
        static let separatorHorizontalOffset: CGFloat = 16.0
        static let separatorTopPadding: CGFloat = 8.0
    }
    
    fileprivate lazy var titleTextView: OWBaseTextView = {
        let textView = OWBaseTextView()
        textView.delegate = self
        textView.isEditable = false
        textView.isSelectable = true
        textView.isScrollEnabled = false
        textView.dataDetectorTypes = [.link]
        textView.backgroundColor = .clear
        return textView
    }()
    
    private lazy var separatorView: OWBaseView = .init()
    
    fileprivate let viewModel: OWCommunityGuidelinesViewModeling
    fileprivate let disposeBag = DisposeBag()
    
    init(with viewModel: OWCommunityGuidelinesViewModeling) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        self.accessibilityIdentifier = Metrics.identifier
        setupViews()
        setupObservers()
    }

}

extension OWCommunityGuidelinesView {
    fileprivate func setupViews() {
        self.backgroundColor = .clear
        self.addSubviews(titleTextView, separatorView)
        titleTextView.OWSnp.makeConstraints { make in
            make.top.equalToSuperview()
            // avoide device notch in landscape
            if #available(iOS 11.0, *) {
                make.leading.equalTo(safeAreaLayoutGuide).offset(Metrics.titleHorizontalOffset)
                make.trailing.equalTo(safeAreaLayoutGuide).offset(-Metrics.titleHorizontalOffset)
            } else {
                make.leading.equalToSuperview().offset(Metrics.titleHorizontalOffset)
                make.trailing.equalToSuperview().offset(-Metrics.titleHorizontalOffset)
            }
        }
        
        separatorView.OWSnp.makeConstraints { make in
            make.bottom.equalToSuperview()
            if (viewModel.inputs.paddedStyle) {
                make.top.equalTo(titleTextView.OWSnp.bottom).offset(Metrics.separatorTopPadding)
                make.leading.equalToSuperview().offset(Metrics.separatorHorizontalOffset)
                make.trailing.equalToSuperview().offset(-Metrics.separatorHorizontalOffset)
            } else {
                make.top.equalTo(titleTextView.OWSnp.bottom)
                make.leading.trailing.equalToSuperview()
            }
            make.height.equalTo(Metrics.separatorHeight)
        }
    }
    
    fileprivate func setupObservers() {
        viewModel.outputs.communityGuidelinesHtmlAttributedString
            .bind(onNext: { [weak self] attString in
                guard let self = self else { return }
                self.titleTextView.attributedText = attString
            })
            .disposed(by: disposeBag)
        
        viewModel.outputs.showSeparator
            .bind(onNext: { [weak self] isVisible in
                guard let self = self else { return }
                self.separatorView.isHidden = !isVisible
            })
            .disposed(by: disposeBag)
    }
}

extension OWCommunityGuidelinesView: UITextViewDelegate {
    // TODO: !!
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
//        delegate?.clickOnUrl(url: URL)
//        SPAnalyticsHolder.default.log(event: .communityGuidelinesLinkClicked(targetUrl: URL.absoluteString), source: .conversation)
        viewModel.inputs.urlClicked.onNext(URL)
        return false
    }
    
    // disable selecting text - we need it to allow click on links
    func textViewDidChangeSelection(_ textView: UITextView) {
        textView.selectedTextRange = nil
    }
}
