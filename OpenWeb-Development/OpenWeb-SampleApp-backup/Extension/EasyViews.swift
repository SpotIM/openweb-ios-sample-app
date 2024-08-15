//
//  EasyViews.swift
//  OpenWeb-Development
//
//  Created by Alon Haiut on 10/05/2022.
//  Copyright © 2022 OpenWeb. All rights reserved.
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

    var barButtonItem: UIBarButtonItem {
        return UIBarButtonItem(customView: self)
    }
}

extension UITextField {
    @discardableResult func borderStyle(_ borderStyle: BorderStyle) -> Self {
        self.borderStyle = borderStyle
        return self
    }

    @discardableResult func autocapitalizationType(_ autocapitalizationType: UITextAutocapitalizationType) -> Self {
        self.autocapitalizationType = autocapitalizationType
        return self
    }

    @discardableResult func placeholder(_ placeholder: String) -> Self {
        self.placeholder = placeholder
        return self
    }
}

extension UILabel {
    @discardableResult func font(_ font: UIFont) -> UILabel {
        self.font = font
        return self
    }

    @discardableResult func minimumFontSize(_ size: CGFloat) -> UILabel {
        self.minimumScaleFactor = size / self.font.pointSize
        return self
    }

    @discardableResult func adjustsFontSizeToFitWidth(_ adjust: Bool) -> UILabel {
        self.adjustsFontSizeToFitWidth = adjust
        return self
    }

    @discardableResult func textColor(_ color: UIColor) -> UILabel {
        self.textColor = color
        return self
    }

    @discardableResult func numberOfLines(_ number: Int) -> UILabel {
        self.numberOfLines = number
        return self
    }

    @discardableResult func textAlignment(_ textAlignment: NSTextAlignment) -> UILabel {
        self.textAlignment = textAlignment
        return self
    }

    @discardableResult func lineBreakMode(_ mode: NSLineBreakMode) -> UILabel {
        self.lineBreakMode = mode
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

        text.addAttributes([NSAttributedString.Key.paragraphStyle: paragraph],
                           range: NSRange(location: 0, length: text.length))
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

        text.addAttribute(NSAttributedString.Key.kern,
                          value: spacing,
                          range: NSRange(location: 0, length: text.length - 1))
        self.attributedText = text

        return self
    }

    @discardableResult func isHidden(_ hidden: Bool) -> UILabel {
        self.isHidden = hidden
        return self
    }
}

extension UIButton {
    @discardableResult func font(_ font: UIFont) -> Self {
        self.titleLabel?.font = font
        return self
    }

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

    @discardableResult func withHorizontalPadding(_ padding: CGFloat) -> Self {
        self.contentEdgeInsets = UIEdgeInsets(top: 0, left: padding, bottom: 0, right: padding)
        return self
    }

    @discardableResult func horizontalAlignment(_ align: UIControl.ContentHorizontalAlignment) -> Self {
        self.contentHorizontalAlignment = align
        return self
    }

    var adjustsFontSizeToFitWidth: UIButton {
        self.titleLabel?.adjustsFontSizeToFitWidth = true
        return self
    }
}

extension UIImageView {
    @discardableResult func contentMode(_ contentMode: UIView.ContentMode) -> Self {
        self.contentMode = contentMode
        return self
    }

    @discardableResult func image(_ image: UIImage) -> Self {
        self.image = image
        return self
    }
}

extension UITableView {
    @discardableResult func separatorStyle(_ separatorStyle: UITableViewCell.SeparatorStyle) -> Self {
        self.separatorStyle = separatorStyle
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

    @discardableResult func font(_ font: UIFont) -> Self {
        self.font = font
        return self
    }

    @discardableResult func textColor(_ textColor: UIColor) -> Self {
        self.textColor = textColor
        return self
    }

    @discardableResult func indicatorStyle(_ indicatorStyle: UIScrollView.IndicatorStyle) -> Self {
        self.indicatorStyle = indicatorStyle
        return self
    }
}
