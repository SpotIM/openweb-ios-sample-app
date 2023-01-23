//
//  TextFieldSetting.swift
//  Spot-IM.Development
//
//  Created by Refael Sommer on 19/01/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class TextFieldSetting: UIView {
    fileprivate struct Metrics {
        static let horizontalOffset: CGFloat = 10
        static let textFieldCorners: CGFloat = 12
        static let keyboardPadding: CGFloat = 5
        static let titleWidthProportion: CGFloat = 0.33
        static let titleNumberOfLines: Int = 2
    }
    
    fileprivate let title: String
    fileprivate let text = BehaviorSubject<String?>(value: nil)
    fileprivate let disposeBag = DisposeBag()
    
    fileprivate lazy var textFieldTitleLbl: UILabel = {
        return title
            .label
            .font(FontBook.mainHeading)
            .numberOfLines(2)
            .lineBreakMode(.byWordWrapping)
    }()
    
    fileprivate lazy var textFieldControl = {
        let textField = UITextField()
            .corner(radius: Metrics.textFieldCorners)
            .border(width: 1.0, color: ColorPalette.shared.color(type: .blackish))
            .borderStyle(.roundedRect)
            .autocapitalizationType(.none)
        return textField
    }()
    
    init(title: String, text: String? = nil) {
        self.title = title
        if let text = text {
            self.text.onNext(text)
        }
        super.init(frame: .zero)
        
        setupViews()
        setupObservers()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

fileprivate extension TextFieldSetting {
    func setupViews() {
        let stackView = UIStackView()
        self.addSubview(stackView)
        stackView.distribution = .fillProportionally
        stackView.addArrangedSubview(textFieldTitleLbl)
        stackView.addArrangedSubview(textFieldControl)
        
        stackView.spacing = Metrics.horizontalOffset
        
        stackView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(Metrics.horizontalOffset)
            make.trailing.equalToSuperview().offset(-Metrics.horizontalOffset)
            make.top.bottom.equalToSuperview()
        }
        
        textFieldTitleLbl.snp.makeConstraints { make in
            make.width.equalTo(self.snp.width).multipliedBy(Metrics.titleWidthProportion)
        }
        
        textFieldControl.snp.makeConstraints { make in
            make.width.equalTo(self.snp.width).multipliedBy(1-Metrics.titleWidthProportion)
        }
    }
    
    func setupObservers() {
        text
            .skip(1) // Skip initialize BehaviorSubject value
            .take(1) // Take first value after initialize
            .bind(to: textFieldControl.rx.value)
            .disposed(by: disposeBag)
        
        textFieldControl.rx.controlEvent([.editingDidEnd, .editingDidEndOnExit])
            .subscribe(onNext: { [weak self] _ in
                self?.textFieldControl.endEditing(true)
            })
            .disposed(by: disposeBag)
        
        let keyboardShowHeight = NotificationCenter.default.rx
            .notification(UIResponder.keyboardWillShowNotification)
            .map { notification -> CGFloat in
                let height = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.height
                return height ?? 0
            }
        
        let keyboardHideHeight = NotificationCenter.default.rx
            .notification(UIResponder.keyboardWillHideNotification)
            .map { _ -> CGFloat in
                0
            }
        
        let keyboardHeight = Observable.from([keyboardShowHeight, keyboardHideHeight])
            .merge()
            
        keyboardHeight
            .subscribe(onNext: { [weak self] keyboardHeight in
                guard let self = self else { return }
                if self.textFieldControl.isFirstResponder,
                   let scrollView = self.superview as? UIScrollView {
                    let insets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight + Metrics.keyboardPadding, right: 0)
                    scrollView.contentInset = insets
                    scrollView.scrollIndicatorInsets = insets
                    
                    if scrollView.frame.height - keyboardHeight + scrollView.contentOffset.y < self.frame.origin.y + Metrics.keyboardPadding + self.frame.size.height {
                        let moveTo = self.frame.origin.y - keyboardHeight + self.frame.size.height + Metrics.keyboardPadding
                        let scrollPoint = CGPoint(x: 0, y: moveTo)
                        scrollView.setContentOffset(scrollPoint, animated: true)
                    }
                } else if let scrollView = self.superview as? UIScrollView {
                        let insets = UIEdgeInsets.zero
                        scrollView.contentInset = insets
                        scrollView.scrollIndicatorInsets = insets
                }
            })
            .disposed(by: disposeBag)
    }
}

extension Reactive where Base: TextFieldSetting {
    var titleText: Binder<String?> {
        return Binder(self.base.textFieldTitleLbl) { textField, value in
            textField.text = value
        }
    }
    
    var textFieldText: ControlProperty<String?> {
        return base.textFieldControl.rx.controlProperty(editingEvents: .editingChanged) { textField in
            textField.text
        } setter: { textField, value in
            textField.text = value
        }
    }
}
