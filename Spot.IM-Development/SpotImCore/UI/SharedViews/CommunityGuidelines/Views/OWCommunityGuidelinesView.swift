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

class OWCommunityGuidelinesView: UIView {
    fileprivate struct Metrics {
        static let identifier = "community_guidelines_id"
        static let communityGuidelinesTextViewIdentifier = "community_guidelines_text_view_id"
        static let containerCorderRadius: CGFloat = 8.0
        static let containerHeight: CGFloat = 44
        static let horizontalOffset: CGFloat = 16.0
        static let verticalOffset: CGFloat = 14.0
        static let horizontalPadding: CGFloat = 10.0

    }

    fileprivate lazy var titleTextView: UITextView = {
        let textView = UITextView()
            .backgroundColor(.clear)
            .delegate(self)
            .isEditable(false)
            .isSelectable(true)
            .userInteractionEnabled(true)
            .isScrollEnabled(false)
            .wrapContent(axis: .vertical)
            .hugContent(axis: .vertical)
            .dataDetectorTypes([.link])

        textView.linkTextAttributes = [NSAttributedString.Key.foregroundColor: OWColorPalette.shared.color(type: .brandColor, themeStyle: .light),
                                       NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue]
        textView.textContainer.lineFragmentPadding = 0
        textView.textContainerInset = .zero
        textView.sizeToFit()
        return textView
    }()

    fileprivate lazy var guidelinesContainer: UIView = {
        return UIView()
            .backgroundColor(OWColorPalette.shared.color(type: .backgroundColor1, themeStyle: OWSharedServicesProvider.shared.themeStyleService().currentStyle))
            .corner(radius: Metrics.containerCorderRadius)
    }()

    fileprivate lazy var guidelinesIcon: UIImageView = {
        return UIImageView()
            .contentMode(.scaleAspectFit)
            .image(UIImage(spNamed: "guidelinesIcon", supportDarkMode: false)!)
    }()

    fileprivate var heightConstraint: OWConstraint? = nil

    fileprivate var viewModel: OWCommunityGuidelinesViewModeling!
    fileprivate var disposeBag = DisposeBag()

    init(with viewModel: OWCommunityGuidelinesViewModeling) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        self.isUserInteractionEnabled = true
        setupUI()
        setupObservers()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        guard let viewModel = viewModel else { return }

        viewModel.inputs.titleTextViewWidthChanged.onNext(self.titleTextView.textContainer.size.width)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init() {
        super.init(frame: .zero)
    }

    // Only when using community guidelines as a cell
    func configure(with viewModel: OWCommunityGuidelinesViewModeling) {
        self.viewModel = viewModel
        self.disposeBag = DisposeBag()
        self.setupUI()
        self.setupObservers()
        self.applyAccessibility()
    }
}

fileprivate extension OWCommunityGuidelinesView {
    func applyAccessibility() {
        self.accessibilityIdentifier = Metrics.identifier
        titleTextView.accessibilityIdentifier = Metrics.communityGuidelinesTextViewIdentifier
    }

    func setupUI() {
        self.backgroundColor = .clear
        self.isHidden = true

        if viewModel.outputs.showContainer {
            self.addSubview(guidelinesContainer)
            guidelinesContainer.OWSnp.makeConstraints { make in
                make.edges.equalToSuperview()
                make.height.equalTo(Metrics.containerHeight)
            }

            guidelinesContainer.addSubview(guidelinesIcon)
            guidelinesIcon.OWSnp.makeConstraints { make in
                make.top.equalToSuperview().offset(Metrics.verticalOffset)
                make.bottom.equalToSuperview().offset(-Metrics.verticalOffset)
                make.leading.equalToSuperview().offset(Metrics.horizontalOffset)
            }

            guidelinesContainer.addSubview(titleTextView)
            titleTextView.OWSnp.makeConstraints { make in
                make.centerY.equalTo(guidelinesIcon)
                make.leading.equalTo(guidelinesIcon.OWSnp.trailing).offset(Metrics.horizontalPadding)
                make.trailing.equalToSuperview().offset(-Metrics.horizontalOffset)
            }
        } else {
            self.addSubview(titleTextView)
            titleTextView.OWSnp.makeConstraints { make in
                make.top.bottom.equalToSuperview()
                heightConstraint = make.height.equalTo(viewModel.outputs.titleTextViewHeightNoneRX).constraint

                // avoide device notch in landscape
                if #available(iOS 11.0, *) {
                    make.leading.equalTo(safeAreaLayoutGuide).offset(Metrics.horizontalOffset)
                    make.trailing.equalTo(safeAreaLayoutGuide).offset(-Metrics.horizontalOffset)
                } else {
                    make.leading.equalToSuperview().offset(Metrics.horizontalOffset)
                    make.trailing.equalToSuperview().offset(-Metrics.horizontalOffset)
                }
            }
        }
    }

    func setupObservers() {
        viewModel.outputs.shouldShowView
            .map { !$0 }
            .bind(to: self.rx.isHidden)
            .disposed(by: disposeBag)

        if let heightConstraint = heightConstraint {
            Observable.combineLatest(viewModel.outputs.shouldShowView,
                                     viewModel.outputs.titleTextViewHeight)
                .filter { $0.0 }
                .map { $0.1 }
                .subscribe(onNext: { [weak self] titleTextViewHeight in
                    guard let self = self else { return }
                    heightConstraint.update(offset: titleTextViewHeight)
                    self.setNeedsLayout()
                    self.layoutIfNeeded()
                })
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
            .subscribe(onNext: { [weak self] currentStyle in
                 guard let self = self else { return }

                self.guidelinesContainer.backgroundColor = OWColorPalette.shared.color(type: .backgroundColor1, themeStyle: currentStyle)
                self.titleTextView.textColor = OWColorPalette.shared.color(type: .textColor2, themeStyle: currentStyle)

                // TODO: custom UI
            })
            .disposed(by: disposeBag)
    }
}

extension OWCommunityGuidelinesView: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        viewModel.inputs.urlClicked.onNext(URL)
        return false
    }
}
