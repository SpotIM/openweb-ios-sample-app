//
//  OWFloatingView.swift
//  OpenWeb-SampleApp
//
//  Created by Refael Sommer on 06/11/2024.
//

import UIKit
import Combine
import CombineCocoa
import SnapKit

class OWFloatingView: UIView {
    private var panGesture: UIPanGestureRecognizer!
    private var cancellables = Set<AnyCancellable>()
    private let viewModel: OWFloatingViewModeling
    private var targetCenter: CGPoint = .zero
    private var isDraggging = false

    private struct Metrics {
        static let identifier = "floating_view_id"
        static let animationDuration: TimeInterval = 0.3
        static let cornerRadius: CGFloat = 16
        static let pullOutFromEdgeWidth: CGFloat = 12
        static let topInitialPadding: CGFloat = 100
    }

    // MARK: - Initializer
    init(viewModel: OWFloatingViewModeling = OWFloatingViewModel()) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupView()
        applyAccessibility()
        setupObservers()
        isHidden = true
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup
    private func setupView() {
        layer.cornerRadius = Metrics.cornerRadius
        clipsToBounds = true
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        addGestureRecognizer(panGesture)
    }

    private func setContentView(_ view: UIView) {
        subviews.forEach { $0.removeFromSuperview() }
        addSubview(view)
        view.snp.makeConstraints { make in
            make.edges.leading.trailing.equalToSuperview()
            make.edges.top.bottom.equalToSuperview()
        }

        DispatchQueue.main.async { [weak self] in
            guard let self,
                  let superview else { return }
            targetCenter.x = superview.bounds.width + frame.width / 2 - Metrics.pullOutFromEdgeWidth
            targetCenter.y = frame.height / 2 + Metrics.topInitialPadding
            center = targetCenter
            isHidden = false
        }
    }

    // MARK: - Gesture Handling
    @objc private func handlePan(gesture: UIPanGestureRecognizer) {
        guard let superview else { return }
        let translation = gesture.translation(in: superview)

        if gesture.state == .changed {
            isDraggging = true
            center = CGPoint(x: center.x + translation.x, y: center.y + translation.y)
            gesture.setTranslation(.zero, in: superview)
        } else if gesture.state == .ended {
            snapToEdge()
        }
    }

    private func snapToEdge() {
        guard let superview else { return }

        let pullOutFromEdgeWidth = Metrics.pullOutFromEdgeWidth
        let animationDuration = Metrics.animationDuration

        // Calculate midpoints of superview
        let midX = superview.bounds.midX

        targetCenter = center

        // Determine if the view is closer to the left or right edge
        let isCloserToLeft = center.x < midX
        // swiftlint:disable:next no_magic_numbers
        let isCloserToCenterX = abs(center.x - midX) < (superview.bounds.width / 4)

        // Horizontal snapping
        if isCloserToCenterX {
            // Snap to the center of the superview on the X axis
            targetCenter.x = midX
        } else if isCloserToLeft {
            // Snap to the left edge, leaving only pullOutFromEdgeWidth visible
            targetCenter.x = -frame.width / 2 + pullOutFromEdgeWidth
        } else {
            // Snap to the right edge, leaving only pullOutFromEdgeWidth visible
            targetCenter.x = superview.bounds.width + frame.width / 2 - pullOutFromEdgeWidth
        }

        // Vertical snapping: prevent the view from going out of bounds
        if frame.minY < 0 {
            // Snap to top edge, leaving only pullOutFromEdgeWidth visible
            targetCenter.y = frame.height / 2 - pullOutFromEdgeWidth
        } else if frame.maxY > superview.bounds.height {
            // Snap to bottom edge, leaving only pullOutFromEdgeWidth visible
            targetCenter.y = superview.bounds.height - frame.height / 2 + pullOutFromEdgeWidth
        }

        center = targetCenter

        // Animate to the calculated position
        UIView.animate(withDuration: animationDuration) {
            self.layoutIfNeeded()
        } completion: { _ in
            self.isDraggging = false
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        // Fix the jump to top of the floating view when scrolling a table view -
        // in the navigation view.
        if !isDraggging, targetCenter != .zero {
            // Notify about the frame change
            center = targetCenter
        }
    }
}

private extension OWFloatingView {
    func applyAccessibility() {
        accessibilityIdentifier = Metrics.identifier
    }

    func setupObservers() {
        viewModel.inputs.setContentView
            .sink(receiveValue: { [weak self] view in
                guard let self else { return }
                setContentView(view)
            })
            .store(in: &cancellables)
    }
}
