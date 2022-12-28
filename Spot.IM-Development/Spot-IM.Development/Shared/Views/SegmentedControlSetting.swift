//
//  SegmentedControlSetting.swift
//  Spot-IM.Development
//
//  Created by Revital Pisman on 19/12/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class SegmentedControlSetting: UIView {
    
    fileprivate struct Metrics {
        static let titleFontSize: CGFloat = 20
        static let verticalOffset: CGFloat = 10
        static let horizontalOffset: CGFloat = 10
        static let segmentMinWidth: CGFloat = 220
    }
    
    fileprivate let title: String
    fileprivate let items: [String]
    
    fileprivate lazy var segmentTitleLbl: UILabel = {
        return title
            .label
            .font(FontBook.paragraph)
            .numberOfLines(2)
            .lineBreakMode(.byWordWrapping)
    }()
    
    fileprivate lazy var segmentedControl: UISegmentedControl = {
        let segment = UISegmentedControl(items: self.items)
            .wrapContent(axis: .horizontal)
        
        return segment
    }()
    
    init(title: String, items: [String]) {
        self.title = title
        self.items = items
        super.init(frame: .zero)
        
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

fileprivate extension SegmentedControlSetting {
    func setupViews() {
        self.addSubview(segmentTitleLbl)
        segmentTitleLbl.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.equalToSuperview().offset(Metrics.horizontalOffset)
        }
        
        self.addSubview(segmentedControl)
        segmentedControl.snp.makeConstraints { make in
            make.centerY.equalTo(segmentTitleLbl)
            make.leading.greaterThanOrEqualTo(segmentTitleLbl.snp.trailing).offset(Metrics.verticalOffset)
            make.trailing.equalToSuperview().offset(-Metrics.horizontalOffset)
            make.width.greaterThanOrEqualTo(Metrics.segmentMinWidth)
        }
    }
}

extension Reactive where Base: SegmentedControlSetting {
    
    var text: Binder<String?> {
        return Binder(self.base.segmentTitleLbl) { label, text in
            label.text = text
        }
    }
    
    var selectedSegmentIndex: ControlProperty<Int> {
        value
    }

    var value: ControlProperty<Int> {
        return base.segmentedControl.rx.controlProperty(editingEvents: .valueChanged) { segmentedControl in
            segmentedControl.selectedSegmentIndex
        } setter: { segmentedControl, value in
            segmentedControl.selectedSegmentIndex = value
        }
    }

    func titleForSegment(at index: Int) -> Binder<String?> {
        return Binder(self.base.segmentedControl) { segmentedControl, title -> Void in
            segmentedControl.setTitle(title, forSegmentAt: index)
        }
    }
}
