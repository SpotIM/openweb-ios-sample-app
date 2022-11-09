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
class OWCommunityGuidelinesView: UIView {
    fileprivate struct Metrics {
        static let identifier = "community_guidelines_id"
        static let titleHorizontalOffset: CGFloat = 16.0
    }
    
    fileprivate lazy var titleTextView: UITextView = {
        let textView = UITextView()
        textView.delegate = self
        textView.isEditable = false
        textView.isSelectable = true
        textView.isScrollEnabled = false
        textView.dataDetectorTypes = [.link]
        textView.backgroundColor = .clear
        return textView
    }()
    
    fileprivate let viewModel: OWCommunityGuidelinesViewModeling
    fileprivate let disposeBag = DisposeBag()
    
    init(with viewModel: OWCommunityGuidelinesViewModeling) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        self.accessibilityIdentifier = Metrics.identifier
        setupViews()
        setupObservers()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension OWCommunityGuidelinesView {
    fileprivate func setupViews() {
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
        }
    }
    
    fileprivate func setupObservers() {
        viewModel.outputs.communityGuidelinesHtmlAttributedString
            .bind(onNext: { [weak self] attString in
                guard let self = self else { return }
                self.titleTextView.attributedText = attString
            })
            .disposed(by: disposeBag)
        
        OWSharedServicesProvider.shared.themeStyleService()
            .style
            .subscribe(onNext: { [weak self] currentStyle in
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
    
    // disable selecting text - we need it to allow click on links
    func textViewDidChangeSelection(_ textView: UITextView) {
        textView.selectedTextRange = nil
    }
}
