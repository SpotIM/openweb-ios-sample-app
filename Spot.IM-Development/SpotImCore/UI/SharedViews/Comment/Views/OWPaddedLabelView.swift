//
//  OWPaddedLabelView.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 21/12/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import UIKit
import RxSwift

class OWPaddedLabelView: UIView {    
    fileprivate lazy var label: UILabel = {
        return UILabel()
    }()
    
    fileprivate let insets: UIEdgeInsets
    
    init(insets: UIEdgeInsets = .zero) {
        self.insets = insets
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setupUI() {
        self.addSubviews(label)
        
        label.OWSnp.makeConstraints { make in
            make.top.equalToSuperview().offset(insets.top)
            make.bottom.equalToSuperview().offset(-insets.bottom)
            make.left.equalToSuperview().offset(insets.left)
            make.right.equalToSuperview().offset(-insets.right)
        }
    }
    
}

extension OWPaddedLabelView {
    @discardableResult func font(_ font: UIFont) -> Self {
        self.label.font = font
        return self
    }
    
    @discardableResult func textColor(_ color: UIColor) -> Self {
        self.label.textColor = color
        return self
    }
    
    func setText(_ text: String?) {
        self.label.text = text
    }
}
