//
//  DragHandleView.swift
//  OpenWeb-SampleApp
//

import UIKit
import SnapKit

class ResizeGripView: UIView {

    struct Metrics {
        var handleWidth: CGFloat = 40
        var handleHeight: CGFloat = 4
        var topPadding: CGFloat = 8
        // swiftlint:disable:next no_magic_numbers
        var handleColor: UIColor = .white.withAlphaComponent(0.6)
        var minHeight: CGFloat = 50
        var maxHeight: CGFloat = 400
    }

    private let metrics: Metrics
    private weak var targetView: UIView?
    private var heightConstraint: Constraint?
    private var currentHeight: CGFloat = 0

    private lazy var handleView: UIView = {
        let view = UIView()
        view.backgroundColor = metrics.handleColor
        view.layer.cornerRadius = metrics.handleHeight / 2
        return view
    }()

    init(metrics: Metrics = Metrics()) {
        self.metrics = metrics
        super.init(frame: .zero)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func attach(to targetView: UIView, heightConstraint: Constraint) {
        self.targetView = targetView
        self.heightConstraint = heightConstraint
        self.currentHeight = targetView.frame.height > 0 ? targetView.frame.height : (heightConstraint.layoutConstraints.first?.constant ?? metrics.minHeight)
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
            make.top.equalToSuperview().offset(metrics.topPadding)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
            make.width.equalTo(metrics.handleWidth)
            make.height.equalTo(metrics.handleHeight)
        }

        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        addGestureRecognizer(panGesture)
    }

    @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .changed:
            let translation = gesture.translation(in: superview)
            let newHeight = currentHeight - translation.y
            let clampedHeight = min(max(newHeight, metrics.minHeight), metrics.maxHeight)
            heightConstraint?.update(offset: clampedHeight)
        case .ended, .cancelled:
            currentHeight = targetView?.frame.height ?? currentHeight
        default:
            break
        }
    }
}
