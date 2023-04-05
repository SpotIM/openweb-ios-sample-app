//
//  OWCommentSkeletonShimmeringCell.swift
//  SpotImCore
//
//  Created by Alon Haiut on 24/10/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import UIKit

class OWCommentSkeletonShimmeringCell: UITableViewCell {

    fileprivate struct Metrics {
        static let avatarSize: CGFloat = 60
        static let userNameWidthRatio: CGFloat = 1/6
        static let userNameHeight: CGFloat = 15
        static let timeWidthRatio: CGFloat = 1/4
        static let timeHeight: CGFloat = 10
        static let spaceBetweenUserNameAndTime: CGFloat = 10
        static let messageHeight: CGFloat = 10
        static let messageLineNumbers: Int = 3
        static let spaceBetweenMessageLines: CGFloat = 5
        static let verticalOffset: CGFloat = 20
        static let horizontalOffset: CGFloat = 20
    }

    fileprivate var viewModel: OWCommentSkeletonShimmeringCellViewModeling!

    fileprivate lazy var mainSkeletonShimmeringView: OWSkeletonShimmeringView = {
        let view = OWSkeletonShimmeringView()
        view.enforceSemanticAttribute()
        
        view.addSubview(avatarSkeleton)
        avatarSkeleton.OWSnp.makeConstraints { make in
            make.top.leading.equalToSuperview()
            make.size.equalTo(Metrics.avatarSize)
        }

        view.addSubview(userNameSkeleton)
        userNameSkeleton.OWSnp.makeConstraints { make in
            make.top.equalTo(avatarSkeleton)
            make.leading.equalTo(avatarSkeleton.OWSnp.trailing).offset(Metrics.horizontalOffset)
            make.height.equalTo(Metrics.userNameHeight)
            make.width.equalToSuperview().multipliedBy(Metrics.userNameWidthRatio)
        }

        view.addSubview(timeSkeleton)
        timeSkeleton.OWSnp.makeConstraints { make in
            make.leading.equalTo(userNameSkeleton)
            make.top.equalTo(userNameSkeleton.OWSnp.bottom).offset(Metrics.spaceBetweenUserNameAndTime)
            make.height.equalTo(Metrics.timeHeight)
            make.width.equalToSuperview().multipliedBy(Metrics.timeWidthRatio)
        }

        // Adding message lines
        guard messageLinesSkeleton.count > 2  else { return view }

        // Adding first message line
        let firstLine = messageLinesSkeleton.first!
        view.addSubview(firstLine)
        firstLine.OWSnp.makeConstraints { make in
            make.top.equalTo(avatarSkeleton.OWSnp.bottom).offset(Metrics.verticalOffset)
            make.height.equalTo(Metrics.messageHeight)
            make.leading.trailing.equalToSuperview()
        }

        // Adding "between"" message lines
        for i in 1...(messageLinesSkeleton.count-2) {
            let currentLine = messageLinesSkeleton[i]
            let lineBefore = messageLinesSkeleton[i-1]
            view.addSubview(currentLine)
            currentLine.OWSnp.makeConstraints { make in
                make.top.equalTo(lineBefore.OWSnp.bottom).offset(Metrics.spaceBetweenMessageLines)
                make.height.equalTo(Metrics.messageHeight)
                make.leading.trailing.equalToSuperview()
            }
        }

        // Adding last message line
        let lastLine = messageLinesSkeleton.last!
        let lineBeforeTheLastOne = messageLinesSkeleton[messageLinesSkeleton.count - 2]
        view.addSubview(lastLine)
        lastLine.OWSnp.makeConstraints { make in
            make.top.equalTo(lineBeforeTheLastOne.OWSnp.bottom).offset(Metrics.spaceBetweenMessageLines)
            make.height.equalTo(Metrics.messageHeight)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().offset(-Metrics.verticalOffset)
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

    fileprivate lazy var userNameSkeleton: UIView = {
        let view = UIView()
            .backgroundColor(OWColorPalette.shared.color(type: .skeletonColor,
                                                         themeStyle: OWSharedServicesProvider.shared.themeStyleService().currentStyle))

        return view
    }()

    fileprivate lazy var timeSkeleton: UIView = {
        let view = UIView()
            .backgroundColor(OWColorPalette.shared.color(type: .skeletonColor,
                                                         themeStyle: OWSharedServicesProvider.shared.themeStyleService().currentStyle))

        return view
    }()

    fileprivate lazy var messageLinesSkeleton: [UIView] = {
        let color = OWColorPalette.shared.color(type: .skeletonColor,
                                                     themeStyle: OWSharedServicesProvider.shared.themeStyleService().currentStyle)

        let numOfLines = Metrics.messageLineNumbers
        let views = (0 ..< numOfLines).map { _ in
            return UIView().backgroundColor(color)
        }

        return views
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func configure(with viewModel: OWCellViewModel) {
        guard let vm = viewModel as? OWCommentSkeletonShimmeringCellViewModeling else { return }
        // In this skeleton shimmering cell we will probably won't do anything with view model, but still let's save it
        self.viewModel = vm

        // Start shimmering effect
        mainSkeletonShimmeringView.addSkeletonShimmering()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        // Stop shimmering effect
        mainSkeletonShimmeringView.removeSkeletonShimmering()
    }
}

fileprivate extension OWCommentSkeletonShimmeringCell {
    func setupUI() {
        self.selectionStyle = .none

        self.addSubview(mainSkeletonShimmeringView)
        mainSkeletonShimmeringView.OWSnp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(Metrics.horizontalOffset)
            make.top.bottom.equalToSuperview().inset(Metrics.verticalOffset)
        }
    }

}
