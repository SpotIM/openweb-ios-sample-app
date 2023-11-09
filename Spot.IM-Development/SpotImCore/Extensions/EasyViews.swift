//
//  EasyViews.swift
//  SpotImCore
//
//  Created by Alon Haiut on 31/01/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import UIKit

extension UIView {
    @discardableResult func backgroundColor(_ color: UIColor) -> Self {
        self.backgroundColor = color
        return self
    }

    @discardableResult func wrapContent(axis: NSLayoutConstraint.Axis? = nil) -> Self {
        let both = axis == nil
        if axis == .horizontal || both {
            self.setContentCompressionResistancePriority(UILayoutPriority.required, for: .horizontal)
        }
        if axis == .vertical || both {
            self.setContentCompressionResistancePriority(UILayoutPriority.required, for: .vertical)
        }
        return self
    }

    @discardableResult func hugContent(axis: NSLayoutConstraint.Axis? = nil) -> Self {
        let both = axis == nil
        if axis == .horizontal || both {
            self.setContentHuggingPriority(UILayoutPriority.required, for: .horizontal)
        }
        if axis == .vertical || both {
            self.setContentHuggingPriority(UILayoutPriority.required, for: .vertical)
        }
        return self
    }

    @discardableResult func corner(radius: CGFloat) -> Self {
        self.layer.cornerRadius = radius
        self.layer.masksToBounds = radius != 0

        return self
    }

    @discardableResult func border(width: CGFloat, color: UIColor) -> Self {
        self.layer.borderWidth = width
        self.layer.borderColor = color.cgColor
        return self
    }

    @discardableResult func tintColor(_ color: UIColor) -> Self {
        self.tintColor = color
        return self
    }

    @discardableResult func userInteractionEnabled(_ isEnabled: Bool) -> Self {
        self.isUserInteractionEnabled = isEnabled
        return self
    }

    @discardableResult func isHidden(_ hidden: Bool) -> Self {
        self.isHidden = hidden
        return self
    }

    @discardableResult func tintAdjustmentMode(_ tintAdjustmentMode: TintAdjustmentMode) -> Self {
        self.tintAdjustmentMode = tintAdjustmentMode
        return self
    }

    @discardableResult func clipsToBounds(_ clipsToBounds: Bool) -> Self {
        self.clipsToBounds = clipsToBounds
        return self
    }

    @discardableResult func alpha(_ alpha: CGFloat) -> Self {
        self.alpha = alpha
        return self
    }
}

extension UILabel {

    @discardableResult func minimumFontSize(_ size: CGFloat) -> UILabel {
        self.minimumScaleFactor = size / self.font.pointSize
        return self
    }

    @discardableResult func adjustsFontSizeToFitWidth(_ adjust: Bool) -> UILabel {
        self.adjustsFontSizeToFitWidth = adjust
        return self
    }

    @discardableResult func textColor(_ color: UIColor) -> Self {
        self.textColor = color
        return self
    }

    @discardableResult func text(_ text: String?) -> UILabel {
        self.text = text
        return self
    }

    @discardableResult func numberOfLines(_ number: Int) -> Self {
        self.numberOfLines = number
        return self
    }

    @discardableResult func textAlignment(_ textAlignment: NSTextAlignment) -> UILabel {
        self.textAlignment = textAlignment
        return self
    }

    @discardableResult func lineBreakMode(_ lineBreakMode: NSLineBreakMode) -> UILabel {
        self.lineBreakMode = lineBreakMode
        return self
    }

    @discardableResult func lineSpacing(_ spacing: CGFloat) -> UILabel {
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineSpacing = spacing
        paragraph.alignment = textAlignment

        let text: NSMutableAttributedString
        if let attributedText = attributedText {
            text = NSMutableAttributedString(attributedString: attributedText)
        } else {
            text = NSMutableAttributedString(string: self.text ?? "")
        }

        text.addAttributes([NSAttributedString.Key.paragraphStyle: paragraph], range: NSRange(location: 0, length: text.length))
        self.attributedText = text

        return self
    }

    @discardableResult func letterSpacing(_ spacing: CGFloat) -> UILabel {
        let text: NSMutableAttributedString
        if let attributedText = attributedText {
            text = NSMutableAttributedString(attributedString: attributedText)
        } else {
            text = NSMutableAttributedString(string: self.text ?? "")
        }

        text.addAttribute(NSAttributedString.Key.kern, value: spacing, range: NSRange(location: 0, length: text.length - 1))
        self.attributedText = text

        return self
    }

    @discardableResult func attributedText(_ attributedText: NSAttributedString) -> UILabel {
        self.attributedText = attributedText
        return self
    }
}

extension UIButton {

    @discardableResult func textColor(_ color: UIColor, forState state: UIControl.State = .normal) -> Self {
        self.setTitleColor(color, for: state)
        return self
    }

    @discardableResult func tap(target: Any?, action: Selector) -> Self {
        addTarget(target, action: action, for: .touchUpInside)
        return self
    }

    @discardableResult func contentEdgeInsets(_ inset: UIEdgeInsets) -> Self {
        self.contentEdgeInsets = inset
        return self
    }

    @discardableResult func withPadding(_ padding: CGFloat) -> Self {
        self.contentEdgeInsets = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
        return self
    }

    @discardableResult func withPadding(_ padding: UIEdgeInsets) -> Self {
        self.contentEdgeInsets = padding
        return self
    }

    @discardableResult func horizontalAlignment(_ align: UIControl.ContentHorizontalAlignment) -> Self {
        self.contentHorizontalAlignment = align
        return self
    }

    @discardableResult func image(_ image: UIImage?, state: UIControl.State) -> Self {
        self.setImage(image, for: state)
        return self
    }

    @discardableResult func imageEdgeInsets(_ imageEdgeInsets: UIEdgeInsets) -> Self {
        self.imageEdgeInsets = imageEdgeInsets
        return self
    }

    @discardableResult func titleEdgeInsets(_ titleEdgeInsets: UIEdgeInsets) -> Self {
        self.titleEdgeInsets = titleEdgeInsets
        return self
    }

    @discardableResult func setTitle(_ title: String?, state: UIControl.State) -> Self {
        self.setTitle(title, for: state)
        return self
    }

    @discardableResult func isEnabled(_ isEnabled: Bool) -> Self {
        self.isEnabled = isEnabled
        return self
    }

    @discardableResult func contentMode(_ mode: UIView.ContentMode) -> Self {
        self.contentMode = mode
        return self
    }

    @discardableResult func adjustTextAndImageAlignment(_ spacing: CGFloat) -> Self {
        var inset = spacing / 2

        if OWLocalizationManager.shared.semanticAttribute == .forceRightToLeft {
            inset = -inset
        }

        imageEdgeInsets = UIEdgeInsets(top: 0.0, left: -inset, bottom: 0.0, right: inset)
        titleEdgeInsets = UIEdgeInsets(top: 0.0, left: inset, bottom: 0.0, right: -inset)
        contentEdgeInsets = UIEdgeInsets(top: 0.0, left: inset, bottom: 0.0, right: inset)

        return self
    }

    @discardableResult func reverseTransform() -> Self {
        let currentTransform = transform
        let currentScaleX = currentTransform.a

        transform = CGAffineTransform(scaleX: -currentScaleX, y: currentScaleX)
        titleLabel?.transform = CGAffineTransform(scaleX: -currentScaleX, y: currentScaleX)
        transform = CGAffineTransform(scaleX: -currentScaleX, y: currentScaleX)

        return self
    }

    @discardableResult func setAlpha(_ alpha: CGFloat) -> Self {
        self.alpha = alpha
        return self
    }

    @discardableResult func backgroundColor(_ color: UIColor, state: UIControl.State) -> Self {
        self.setBackgroundColor(color: color, forState: state)
        return self
    }
}

extension UIImageView {
    @discardableResult func contentMode(_ contentMode: UIView.ContentMode) -> Self {
        self.contentMode = contentMode
        return self
    }

    @discardableResult func image(_ image: UIImage?) -> Self {
        self.image = image
        return self
    }

    @discardableResult func cornerRadius(_ radius: CGFloat) -> Self {
        self.layer.cornerRadius = radius
        self.layer.masksToBounds = radius != 0

        return self
    }
}

extension UITableView {
    @discardableResult func separatorStyle(_ separatorStyle: UITableViewCell.SeparatorStyle) -> Self {
        self.separatorStyle = separatorStyle
        return self
    }

    @discardableResult func separatorColor(_ color: UIColor) -> Self {
        self.separatorColor = color
        return self
    }

    @discardableResult func dataSource(_ dataSource: UITableViewDataSource) -> Self {
        self.dataSource = dataSource
        return self
    }

    @discardableResult func delegate(_ delegate: UITableViewDelegate) -> Self {
        self.delegate = delegate
        return self
    }

    @discardableResult func registerCell<T: UITableViewCell>(cellClass: T.Type = T.self) -> Self {
        self.register(cellClass: cellClass)
        return self
    }
}

extension String {
    var label: UILabel {
        let label = UILabel()
        label.text = self
        return label
    }

    var button: UIButton {
        return button(withType: .system)
    }

    func button(withType type: UIButton.ButtonType) -> UIButton {
        let button = UIButton(type: type)
        button.setTitle(self, for: .normal)
        return button
    }

    var image: UIImage? {
        return UIImage(named: self)
    }

    var url: URL? {
        return URL(string: self)
    }

    var stringWithoutURL: String? {
        guard let data = self.data(using: .utf8) else { return nil }

        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]

        guard let attributedString = try? NSAttributedString(data: data, options: options, documentAttributes: nil) else { return nil }

        var resultString = attributedString.string

        // Remove newline character at the end if it exists, sometimes when converting string to attributed string it adds a newline at the end
        if resultString.hasSuffix("\n") {
            resultString = String(resultString.dropLast())
        }

        return resultString
    }

    var linkedText: String? {
        guard let data = self.data(using: .utf8) else { return nil }

        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]

        guard let attributedString = try? NSMutableAttributedString(data: data, options: options, documentAttributes: nil) else { return nil }

        var linkedString: String? = nil
        attributedString.enumerateAttribute(.link, in: NSRange(location: 0, length: attributedString.length), options: []) { (value, range, _) in
            if let _ = value as? URL {
                linkedString = attributedString.attributedSubstring(from: range).string
            }
        }

        return linkedString
    }
}

extension UITextView {
    @discardableResult func delegate(_ delegate: UITextViewDelegate) -> Self {
        self.delegate = delegate
        return self
    }

    @discardableResult func isEditable(_ editable: Bool) -> Self {
        self.isEditable = editable
        return self
    }

    @discardableResult func text(_ text: String) -> Self {
        self.text = text
        return self
    }

    @discardableResult func isSelectable(_ selectable: Bool) -> Self {
        self.isSelectable = selectable
        return self
    }

    @discardableResult func isScrollEnabled(_ scrollEnabled: Bool) -> Self {
        self.isScrollEnabled = scrollEnabled
        return self
    }

    @discardableResult func dataDetectorTypes(_ dataDetectorTypes: UIDataDetectorTypes) -> Self {
        self.dataDetectorTypes = dataDetectorTypes
        return self
    }

    @discardableResult func textColor(_ textColor: UIColor) -> Self {
        self.textColor = textColor
        return self
    }

    @discardableResult func textContainerInset(_ textContainerInset: UIEdgeInsets) -> Self {
        self.textContainerInset = textContainerInset
        return self
    }

    @discardableResult func maxNumberOfLines(_ maxNumberOfLines: Int) -> Self {
        self.textContainer.maximumNumberOfLines = maxNumberOfLines
        return self
    }

    @discardableResult func textAlignment(_ textAlignment: NSTextAlignment) -> Self {
        self.textAlignment = textAlignment
        return self
    }

    @discardableResult func autocorrectionType(_ autocorrectionType: UITextAutocorrectionType) -> Self {
        self.autocorrectionType = autocorrectionType
        return self
    }

    @discardableResult func spellCheckingType(_ spellCheckingType: UITextSpellCheckingType) -> Self {
        self.spellCheckingType = spellCheckingType
        return self
    }
}

extension UIStackView {
    @discardableResult func axis(_ axis: NSLayoutConstraint.Axis) -> Self {
        self.axis = axis
        return self
    }

    @discardableResult func alignment(_ alignment: UIStackView.Alignment) -> Self {
        self.alignment = alignment
        return self
    }

    @discardableResult func distribution(_ distribution: UIStackView.Distribution) -> Self {
        self.distribution = distribution
        return self
    }

    @discardableResult func spacing(_ spacing: CGFloat) -> Self {
        self.spacing = spacing
        return self
    }
}
