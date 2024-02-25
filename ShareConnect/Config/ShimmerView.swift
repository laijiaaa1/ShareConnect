//
//  ShimmerView.swift
//  ShareConnect
//
//  Created by laijiaaa1 on 2023/12/16.
//

import Foundation
import UIKit
class ShimmerImageView: UIImageView {
    private let gradientLayer = CAGradientLayer()
    // Adjusted wave height for a better shimmer effect
    private var waveHeight: CGFloat {
        return bounds.height / 2.5
    }
    private var wavePath: UIBezierPath {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: bounds.height / 2))
        //使用 for 循環迭代 x 軸上的每個點（從 0 開始，以步長 0.1 遞增，直到達到 bounds 的寬度)
        for angle in stride(from: 0.0, to: Double(bounds.width), by: 0.1) {
            let x = angle
            let y = sin(angle * 2 * Double.pi / 100) * waveHeight + Double(bounds.height / 2)
            path.addLine(to: CGPoint(x: x, y: y))
        }
        return path
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    private func commonInit() {
        contentMode = .scaleAspectFit
        clipsToBounds = true
        gradientLayer.colors = [UIColor.clear.cgColor, UIColor.white.cgColor, UIColor.clear.cgColor]
        gradientLayer.locations = [0, 0.5, 1]
        gradientLayer.frame = bounds
        layer.mask = gradientLayer
        startShimmerAnimation()
    }
    func startShimmerAnimation() {
        let animation = CABasicAnimation(keyPath: "opacity")
        animation.fromValue = 0.3
        animation.toValue = 1.0
        animation.duration = 1.5
        animation.autoreverses = true
        animation.repeatCount = Float.infinity
        gradientLayer.add(animation, forKey: "opacityAnimation")
    }
}

class Class_Space: ShimmerImageView {
    private var animationTimer: Timer?
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    private func commonInit() {
        image = UIImage(named: "Class_Space")
        contentMode = .scaleAspectFit
        clipsToBounds = true
        startCloudAnimation()
    }
    private func startCloudAnimation() {
        guard animationTimer == nil else { return }
        animationTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { [weak self] _ in
            // 動畫最終位置
            UIView.animate(withDuration: 1.5, delay: 0.0, options: [.curveEaseInOut], animations: {
                self?.transform = CGAffineTransform(translationX: 20, y: 0)
                self?.alpha = 0.7 // Adjust the alpha value for a subtle shimmer effect
            }) { _ in
                UIView.animate(withDuration: 1.5, delay: 0.0, options: [.curveEaseInOut], animations: {
                    self?.transform = .identity
                    self?.alpha = 1.0
                })
            }
        }
    }
    deinit {
        // Invalidate the timer to prevent memory leaks
        animationTimer?.invalidate()
        animationTimer = nil
    }
}
