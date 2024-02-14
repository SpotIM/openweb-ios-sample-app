//
//  OWCompactCommentView.swift
//  OpenWebSDK
//
//  Created by  Nogah Melamed on 08/03/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class OWPreConversationCompactContentView: UIView {
    fileprivate struct Metrics {
        static let avatarSize: CGFloat = 40
        static let numberOfLines: Int = 2
        static let imageIconSize: CGFloat = 24
        static let imageLeftPadding: CGFloat = 12
        static let textLeftPadding: CGFloat = 2
        static let skelatonLineHeight: CGFloat = 8
        static let skelatonLinesTopPaddig: CGFloat = 5
        static let skelatonSpaceBetweenLines: CGFloat = 8
        static let skelatonLinesLeadingPaddig: CGFloat = 12

        static let identifier = "pre_conversation_compact_content_view_id"
        static let textLabelIdentifier = "pre_conversation_compact_text_label_id"
    }

    fileprivate lazy var avatarImageView: OWAvatarView = {
        let avatar = OWAvatarView().backgroundColor(.clear)
        avatar.configure(with: self.viewModel.outputs.avatarVM)
        return avatar
    }()

    fileprivate lazy var closedImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(spNamed: "time-icon", supportDarkMode: true)
        return imageView
    }()

    fileprivate lazy var emptyConversationImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(spNamed: "emptyConversation-icon", supportDarkMode: true)
        return imageView
    }()

    fileprivate lazy var errorConversationImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(spNamed: "errorStateIcon", supportDarkMode: true)
        return imageView
    }()

    fileprivate lazy var errorRetryView: OWErrorRetryCTAView = {
        let tryAgainView = OWErrorRetryCTAView()
            .backgroundColor(.clear)
        tryAgainView.addGestureRecognizer(errorCtaTapGesture)
        return tryAgainView
    }()

    fileprivate lazy var errorCtaTapGesture: UITapGestureRecognizer = {
        return UITapGestureRecognizer()
    }()

    fileprivate var errorRetryZeroWidthConstraint: OWConstraint? = nil

    fileprivate lazy var leftViewContainer: UIView = {
        return UIView()
    }()

    fileprivate lazy var textLabel: UILabel = {
        return UILabel()
            .font(OWFontBook.shared.font(typography: .footnoteText))
            .numberOfLines(Metrics.numberOfLines)
            .textColor(OWColorPalette.shared.color(type: .textColor3,
                                                   themeStyle: OWSharedServicesProvider.shared.themeStyleService().currentStyle))
            .enforceSemanticAttribute()
    }()

    fileprivate lazy var cameraIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(spNamed: "camera-icon", supportDarkMode: true)
        return imageView
    }()

    fileprivate lazy var skelatonView: OWSkeletonShimmeringView = {
        let view = OWSkeletonShimmeringView()
        view.enforceSemanticAttribute()

        view.addSubview(avatarSkeleton)
        avatarSkeleton.OWSnp.makeConstraints { make in
            make.top.leading.bottom.equalToSuperview()
            make.size.equalTo(Metrics.avatarSize)
        }
        let firstLine = messageLinesSkeleton[0]
        view.addSubview(firstLine)
        firstLine.OWSnp.makeConstraints { make in
            make.top.equalToSuperview().offset(Metrics.skelatonLinesTopPaddig)
            make.trailing.equalToSuperview()
            make.height.equalTo(Metrics.skelatonLineHeight)
            make.leading.equalTo(avatarSkeleton.OWSnp.trailing).offset(Metrics.skelatonLinesLeadingPaddig)
        }
        let secondLine = messageLinesSkeleton[1]
        view.addSubview(secondLine)
        secondLine.OWSnp.makeConstraints { make in
            make.top.equalTo(firstLine.OWSnp.bottom).offset(Metrics.skelatonSpaceBetweenLines)
            make.height.equalTo(Metrics.skelatonLineHeight)
            make.leading.equalTo(avatarSkeleton.OWSnp.trailing).offset(Metrics.skelatonLinesLeadingPaddig)
            make.trailing.equalToSuperview()
        }
        return view
    }()

    fileprivate lazy var avatarSkeleton: UIView = {
        let view = UIView()
            .corner(radius: Metrics.avatarSize / 2)
            .backgroundColor(OWColorPalette.shared.color(type: .skeletonColor,
                                                         themeStyle: OWSharedServicesProvider.shared.themeStyleService().currentStyle))

        return view
    }()

    fileprivate lazy var messageLinesSkeleton: [UIView] = {
        let color = OWColorPalette.shared.color(type: .skeletonColor,
                                                     themeStyle: OWSharedServicesProvider.shared.themeStyleService().currentStyle)

        let numOfLines = Metrics.numberOfLines
        let views = (0 ..< numOfLines).map { _ in
            return UIView().backgroundColor(color)
        }

        return views
    }()

    fileprivate var viewModel: OWPreConversationCompactContentViewModeling!
    fileprivate let disposeBag = DisposeBag()

    init(viewModel: OWPreConversationCompactContentViewModeling) {
        super.init(frame: .zero)
        self.viewModel = viewModel

        setupViews()
        setupObservers()
        applyAccessibility()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

fileprivate extension OWPreConversationCompactContentView {
    func applyAccessibility() {
        self.accessibilityIdentifier = Metrics.identifier
        textLabel.accessibilityIdentifier = Metrics.textLabelIdentifier
    }

    func setupViews() {
        self.enforceSemanticAttribute()

        self.addSubview(skelatonView)
        skelatonView.OWSnp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        skelatonView.addSkeletonShimmering()

        self.addSubview(leftViewContainer)
        leftViewContainer.OWSnp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
            make.size.equalTo(Metrics.avatarSize)
        }
        leftViewContainer.isHidden = true

        self.addSubview(cameraIcon)
        cameraIcon.OWSnp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.size.equalTo(Metrics.imageIconSize)
            make.leading.equalTo(leftViewContainer.OWSnp.trailing).offset(Metrics.imageLeftPadding)
        }
        cameraIcon.isHidden = true

        self.addSubviews(errorRetryView)
        errorRetryView.OWSnp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview()
            errorRetryZeroWidthConstraint = make.width.equalTo(0).constraint
        }
        errorRetryView.isHidden = true

        self.addSubview(textLabel)
        textLabel.OWSnp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.equalTo(cameraIcon.OWSnp.trailing).offset(Metrics.textLeftPadding)
            make.trailing.equalTo(errorRetryView.OWSnp.leading)
        }
        textLabel.isHidden = true
    }

    func setupObservers() {
        viewModel.outputs.isSkelatonHidden
            .bind(to: skelatonView.rx.isHidden)
            .disposed(by: disposeBag)

        viewModel.outputs.text
            .bind(to: textLabel.rx.text)
            .disposed(by: disposeBag)

        viewModel.outputs.isSkelatonHidden
            .map { !$0 }
            .bind(to: textLabel.rx.isHidden)
            .disposed(by: disposeBag)

        viewModel.outputs.isSkelatonHidden
            .map { !$0 }
            .bind(to: leftViewContainer.rx.isHidden)
            .disposed(by: disposeBag)

        viewModel.outputs.shouldShowImagePlaceholder
            .map { !$0 }
            .bind(to: cameraIcon.rx.isHidden)
            .disposed(by: disposeBag)

        errorCtaTapGesture.rx.event
            .voidify()
            .bind(to: viewModel.inputs.tryAgainTap)
            .disposed(by: disposeBag)

        // Show avatar/empty/close icons according to content
        viewModel.outputs.contentType
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] type in
                guard let self = self else { return }

                self.leftViewContainer.subviews.forEach { $0.removeFromSuperview() }
                let view = self.getViewForContent(type: type)
                self.leftViewContainer.addSubview(view)
                view.OWSnp.makeConstraints { make in
                    make.edges.equalToSuperview()
                }
            })
            .disposed(by: disposeBag)

        let isErrorObservable: Observable<Bool> = viewModel.outputs.contentType
            .map {
                if case .error = $0 {
                    return true
                }
                return false
            }

        isErrorObservable
            .map { !$0 }
            .bind(to: errorRetryView.rx.isHidden)
            .disposed(by: disposeBag)

        if let constraint = errorRetryZeroWidthConstraint {
            isErrorObservable
                .map { !$0 }
                .bind(to: constraint.rx.isActive)
                .disposed(by: disposeBag)
        }

        // Set image placeholder if needed
        viewModel.outputs.shouldShowImagePlaceholder
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] showImage in
                guard let self = self else { return }
                self.cameraIcon.OWSnp.updateConstraints { make in
                    make.size.equalTo(showImage ? Metrics.imageIconSize : 0)
                    make.leading.equalTo(self.leftViewContainer.OWSnp.trailing).offset(showImage ? Metrics.imageLeftPadding : 10)
                }
            })
            .disposed(by: disposeBag)

        // Colors for dark/light mode
        OWSharedServicesProvider.shared.themeStyleService()
            .style
            .subscribe(onNext: { [weak self] currentStyle in
                guard let self = self else { return }

                self.textLabel.textColor = OWColorPalette.shared.color(type: .textColor3, themeStyle: currentStyle)
                self.emptyConversationImageView.image = UIImage(spNamed: "emptyConversation-icon", supportDarkMode: true)
                self.closedImageView.image = UIImage(spNamed: "time-icon", supportDarkMode: true)
                self.cameraIcon.image = UIImage(spNamed: "camera-icon", supportDarkMode: true)
                self.errorConversationImageView.image = UIImage(spNamed: "errorStateIcon", supportDarkMode: true)
            })
            .disposed(by: disposeBag)

        OWSharedServicesProvider.shared.appLifeCycle()
            .didChangeContentSizeCategory
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.textLabel.font = OWFontBook.shared.font(typography: .footnoteText)
            })
            .disposed(by: disposeBag)
    }

    func getViewForContent(type: OWCompactContentType) -> UIView {
        switch type {
        case .comment:
            return self.avatarImageView
        case .emptyConversation:
            return self.emptyConversationImageView
        case .closedAndEmpty:
            return self.closedImageView
        case .error:
            return self.errorConversationImageView
        default:
            return UIView()
        }
    }
}
