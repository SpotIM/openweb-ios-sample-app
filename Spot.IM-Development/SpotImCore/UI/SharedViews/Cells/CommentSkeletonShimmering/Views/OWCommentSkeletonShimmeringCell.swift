//
//  OWCommentSkeletonShimmeringCell.swift
//  SpotImCore
//
//  Created by Alon Haiut on 24/10/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import UIKit

class OWCommentSkeletonShimmeringCell: UITableViewCell, OWSkeletonShimmeringProtocol {
    
    fileprivate struct Metrics {
        static let avatarSize: CGFloat = 50
        static let userNameWidthRatio: CGFloat = 1/6
        static let userNameHeight: CGFloat = 25
        static let timeWidthRatio: CGFloat = 1/5
        static let timeHeight: CGFloat = 20
        static let messageHeight: CGFloat = 25
        static let messageLineNumbers: Int = 3
        static let spaceBetweenMessageLines: CGFloat = 15
        static let verticalOffset: CGFloat = 20
        static let horizontalOffset: CGFloat = 20
    }

    fileprivate lazy var mainView: UIView = {
        let view = UIView()

        view.addSubview(avatarSkeleton)
        avatarSkeleton.OWSnp.makeConstraints { make in
            make.top.leading.equalToSuperview()
            make.size.equalTo(Metrics.avatarSize)
        }
        
        view.addSubview(userNameSkeleton)
        userNameSkeleton.OWSnp.makeConstraints { make in
            make.top.equalTo(avatarSkeleton)
            make.height.equalTo(Metrics.userNameHeight)
            make.width.equalToSuperview().multipliedBy(Metrics.userNameWidthRatio)
        }
        
        view.addSubview(timeSkeleton)
        timeSkeleton.OWSnp.makeConstraints { make in
            make.top.equalTo(userNameSkeleton.OWSnp.bottom)
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
            .backgroundColor(UIColor.skeletonBackgroundColor)
        
        return view
    }()
    
    fileprivate lazy var userNameSkeleton: UIView = {
        let view = UIView()
            .backgroundColor(UIColor.skeletonBackgroundColor)
        
        return view
    }()
    
    fileprivate lazy var timeSkeleton: UIView = {
        let view = UIView()
            .backgroundColor(UIColor.skeletonBackgroundColor)
        
        return view
    }()
    
    fileprivate lazy var messageLinesSkeleton: [UIView] = {
        let numOfLines = Metrics.messageLineNumbers
        let views = Array(repeating: UIView().backgroundColor(UIColor.skeletonBackgroundColor), count: numOfLines)
        
        return views
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

fileprivate extension OWCommentSkeletonShimmeringCell {
    func setupUI() {
        self.addSubview(mainView)
        mainView.OWSnp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(Metrics.horizontalOffset)
            make.top.bottom.equalToSuperview().inset(Metrics.verticalOffset)
        }
    }
    
}
