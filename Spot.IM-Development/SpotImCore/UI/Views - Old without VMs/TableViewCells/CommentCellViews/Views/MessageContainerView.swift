//
//  MessageContainerView.swift
//  Spot.IM-Core
//
//  Created by Andriy Fedin on 27/09/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import UIKit

final class MessageContainerView: OWBaseView {
    fileprivate struct Metrics {
        static let identifier = "message_container_id"
        static let mainTextLabelIdentifier = "message_container_main_text_label_id"
    }
    
    weak var delegate: MessageContainerViewDelegate?
    private let mainTextLabel: OWBaseLabel = .init()
    private var activeURLs: [NSRange: URL] = [:]
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupGestureRecognizer()
        applyAccessibility()
    }
    
    private func applyAccessibility() {
        self.accessibilityIdentifier = Metrics.identifier
        mainTextLabel.accessibilityIdentifier = Metrics.mainTextLabelIdentifier
    }
    
    func setMessage(
        _ message: String,
        attributes: [NSAttributedString.Key: Any],
        clipToLine: Int = 0,
        width: CGFloat = 0.0,
        clippedTextSettings: SPClippedTextSettings) {
        
        var settings = clippedTextSettings
        settings.fontPointSize = mainTextLabel.font.pointSize
            
        mainTextLabel.attributedText = NSAttributedString(string: "")
        activeURLs.removeAll()
        let attributedMessage = NSAttributedString(string: message, attributes: attributes)
        var clippedText = NSMutableAttributedString(
            attributedString: attributedMessage.clippedToLine(
                index: clipToLine,
                width: width,
                clippedTextSettings: settings
            )
        )
        locateURLsInText(text: &clippedText)
        mainTextLabel.attributedText = clippedText
    }
    
    func updateColorsAccordingToStyle() {
        mainTextLabel.backgroundColor = .spBackground0
    }
    
    @objc
    private func handleTap(gesture: UITapGestureRecognizer) {
        let readMoreString = LocalizationManager.localizedString(key: "Read More")
        let readLessString = LocalizationManager.localizedString(key: "Read Less")
        
        if isTarget(substring: readMoreString, destinationOf: gesture) {
            handleReadMoreTap()
        } else if isTarget(substring: readLessString, destinationOf: gesture) {
            handleReadLessTap()
        } else {
            checkURLTap(in: gesture.location(in: mainTextLabel))
        }
    }
    
    private func isTarget(substring: String, destinationOf gesture: UIGestureRecognizer) -> Bool {
        guard let string = mainTextLabel.attributedText?.string else { return false }
        
        guard let range = string.range(of: substring, options: [.backwards, .literal]) else { return false }
        let tapLocation = gesture.location(in: mainTextLabel)
        let index = mainTextLabel.indexOfAttributedTextCharacterAtPoint(point: tapLocation)
        
        return range.contains(string.utf16.index(string.utf16.startIndex, offsetBy: index))
    }

    private func checkURLTap(in point: CGPoint) {
        let index = mainTextLabel.indexOfAttributedTextCharacterAtPoint(point: point)
        let url = activeURLs.first { $0.key.contains(index) }?.value

        guard let activeUrl = url else { return }

        handleURLTap(url: activeUrl)
    }
    
    private func isURLTap(in point: CGPoint) -> Bool {
        let index = mainTextLabel.indexOfAttributedTextCharacterAtPoint(point: point)
        return (activeURLs.first { $0.key.contains(index) }?.value != nil)
    }
    
    private func handleURLTap(url: URL) {
        delegate?.urlTappedInMessageContainer(view: self, url: url)
    }
    
    private func handleReadMoreTap() {
        delegate?.readMoreTappedInMessageContainer(view: self)
    }
    
    private func handleReadLessTap() {
        delegate?.readLessTappedInMessageContainer(view: self)
    }

    private func didHitCustomTarget(with recognizer: UIGestureRecognizer) -> Bool {
        let readMoreString = LocalizationManager.localizedString(key: "Read More")
        let readLessString = LocalizationManager.localizedString(key: "Read Less")

        if isTarget(substring: readMoreString, destinationOf: recognizer) ||
            isTarget(substring: readLessString, destinationOf: recognizer) ||
            isURLTap(in: recognizer.location(in: mainTextLabel)) {
            return true
        }
        return false
    }
    
    private func setupUI() {
        addSubview(mainTextLabel)
        configureTextLabel()
    }
    
    private func configureTextLabel() {
        mainTextLabel.backgroundColor = .spBackground0
        mainTextLabel.numberOfLines = 0
        mainTextLabel.font = .preferred(style: .regular, of: Theme.fontSize)
        mainTextLabel.OWSnp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func setupGestureRecognizer() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        tap.delegate = self
        mainTextLabel.addGestureRecognizer(tap)
        mainTextLabel.isUserInteractionEnabled = true
    }
    
    private func locateURLsInText(text: inout NSMutableAttributedString) {
        let linkType: NSTextCheckingResult.CheckingType = [.link]
        if let detector = try? NSDataDetector(types: linkType.rawValue) {
            let rawText = text.string
            let matches = detector.matches(
                in: rawText,
                options: [],
                range: NSRange(location: 0, length: rawText.count)
            )
            
            for match in matches {
                if let urlMatch = match.url, isUrlSchemeValid(for: urlMatch) {
                        text.addAttributes([.foregroundColor: UIColor.darkSkyBlue], range: match.range)
                        activeURLs[match.range] = urlMatch
                    }
                }
            }
    }
    
    private func isUrlSchemeValid(for url: URL) -> Bool {
        return url.scheme?.lowercased() != "mailto"
    }
}

private enum Theme {
    static let fontSize: CGFloat = 16.0
}

internal protocol MessageContainerViewDelegate: class {
    func urlTappedInMessageContainer(view: MessageContainerView, url: URL)
    func readMoreTappedInMessageContainer(view: MessageContainerView)
    func readLessTappedInMessageContainer(view: MessageContainerView)
}

extension String {

  var length: Int {
    return count
  }

  subscript (i: Int) -> String {
    return self[i ..< i + 1]
  }

  func substring(fromIndex: Int) -> String {
    return self[min(fromIndex, length) ..< length]
  }

  func substring(toIndex: Int) -> String {
    return self[0 ..< max(0, toIndex)]
  }

  subscript (r: Range<Int>) -> String {
    let range = Range(uncheckedBounds: (lower: max(0, min(length, r.lowerBound)),
                                        upper: min(length, max(0, r.upperBound))))
    let start = index(startIndex, offsetBy: range.lowerBound)
    let end = index(start, offsetBy: range.upperBound - range.lowerBound)
    return String(self[start ..< end])
  }

}

extension MessageContainerView: UIGestureRecognizerDelegate {
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return didHitCustomTarget(with: gestureRecognizer)
    }
}
