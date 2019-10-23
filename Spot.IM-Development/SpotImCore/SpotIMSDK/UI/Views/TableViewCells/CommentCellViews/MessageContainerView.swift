//
//  MessageContainerView.swift
//  Spot.IM-Core
//
//  Created by Andriy Fedin on 27/09/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import Foundation
import UIKit

final class MessageContainerView: BaseView {

    weak var delegate: MessageContainerViewDelegate?
    private let mainTextLabel: UILabel = .init()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupUI()
        setupGestureRecognizer()
    }

    func setMessage(
        _ message: String,
        attributes: [NSAttributedString.Key: Any],
        clipToLine: Int = 0,
        isCollapsed: Bool) {

        let attributedMessage = NSAttributedString(string: message, attributes: attributes)
        mainTextLabel.attributedText = attributedMessage.clippedToLine(
            index: clipToLine,
            width: frame.width,
            isCollapsed: isCollapsed
        )
    }

    @objc
    private func handleTap(gesture: UITapGestureRecognizer) {
        let readMoreString = NSLocalizedString("Read More", comment: "Collapsed long comments temporary terminator")
        let readLessString = NSLocalizedString("Read Less", comment: "Expanded long comments terminator")
        if isTarget(substring: readMoreString, destinationOf: gesture) {
            handleReadMoreTap()
        } else if isTarget(substring: readLessString, destinationOf: gesture) {
            handleReadLessTap()
        }
    }

    private func isTarget(substring: String, destinationOf gesture: UITapGestureRecognizer) -> Bool {
        guard let string = mainTextLabel.attributedText?.string else { return false }
        guard let range = string.range(of: substring, options: [.backwards, .literal]) else { return false }
        let tapLocation = gesture.location(in: mainTextLabel)
        let index = mainTextLabel.indexOfAttributedTextCharacterAtPoint(point: tapLocation)

        return range.contains(string.index(string.startIndex, offsetBy: index))
    }

    private func handleReadMoreTap() {
        delegate?.readMoreTappedInMessageContainer(view: self)
    }

    private func handleReadLessTap() {
        delegate?.readLessTappedInMessageContainer(view: self)
    }

    private func setupUI() {
        addSubview(mainTextLabel)
        configureTextLabel()
    }

    private func configureTextLabel() {
        mainTextLabel.backgroundColor = .white
        mainTextLabel.numberOfLines = 0
        mainTextLabel.font = .preferred(style: .regular, of: Theme.fontSize)
        mainTextLabel.pinEdges(to: self)
    }

    private func setupGestureRecognizer() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        mainTextLabel.addGestureRecognizer(tap)
        mainTextLabel.isUserInteractionEnabled = true
    }

}

private enum Theme {
    static let fontSize: CGFloat = 16.0
}

internal protocol MessageContainerViewDelegate: class {
    func readMoreTappedInMessageContainer(view: MessageContainerView)
    func readLessTappedInMessageContainer(view: MessageContainerView)
}
