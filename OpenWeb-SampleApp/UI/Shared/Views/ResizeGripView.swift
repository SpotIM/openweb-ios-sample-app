//
//  DragHandleView.swift
//  OpenWeb-SampleApp
//

import UIKit
import SnapKit

class ResizeGripView: UIView {

    private struct Metrics {
        static let handleWidth: CGFloat = 40
        static let handleHeight: CGFloat = 4
        static let handlePadding: CGFloat = 8
        // swiftlint:disable:next no_magic_numbers
        static let handleColor: UIColor = .white.withAlphaComponent(0.6)
        static let defaultHeight: CGFloat = 50
    }

    private let maxHeight: CGFloat
    private weak var targetView: UIView?
    private var heightConstraint: Constraint?
    private var currentHeight: CGFloat = 0

    private lazy var handleView: UIView = {
        let view = UIView()
        view.backgroundColor = Metrics.handleColor
        view.layer.cornerRadius = Metrics.handleHeight / 2
        return view
    }()

    init(maxHeight: CGFloat = 400) {
        self.maxHeight = maxHeight
        super.init(frame: .zero)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func attach(to targetView: UIView, heightConstraint: Constraint) {
        self.targetView = targetView
        self.heightConstraint = heightConstraint
        self.currentHeight = targetView.frame.height > 0 ? targetView.frame.height : (heightConstraint.layoutConstraints.first?.constant ?? Metrics.defaultHeight)
        targetView.addSubview(self)
        snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }
    }
}

private extension ResizeGripView {
    func setupViews() {
        addSubview(handleView)
        handleView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Metrics.handlePadding)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
            make.width.equalTo(Metrics.handleWidth)
            make.height.equalTo(Metrics.handleHeight)
        }

        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        addGestureRecognizer(panGesture)
    }

    @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .changed:
            let translation = gesture.translation(in: superview)
            let newHeight = currentHeight - translation.y
            let clampedHeight = min(max(newHeight, 0), maxHeight)
            heightConstraint?.update(offset: clampedHeight)
        case .ended, .cancelled:
            currentHeight = targetView?.frame.height ?? currentHeight
        default:
            break
        }
    }
}
