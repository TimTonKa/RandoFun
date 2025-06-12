//
//  HaloView.swift
//  RandoFun
//
//  Created by Tim Zheng on 2025/6/5.
//

import UIKit

class HaloView: UIView {
    private var orbitDots: [UIView] = []
    private let orbitRadius: CGFloat = 60
    private let dotSize: CGFloat = 12
    private var orbitTimer: Timer?
    private var orbitContainer = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    convenience init(center: CGPoint, color: UIColor) {
        let size: CGFloat = 100
        self.init(frame: CGRect(x: 0, y: 0, width: size, height: size))
        self.center = center
        self.layer.cornerRadius = size / 2
        self.backgroundColor = color.withAlphaComponent(0.5)
        self.layer.borderWidth = 2
        self.layer.borderColor = UIColor.white.cgColor
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func startOrbitAnimation(dotCount: Int = 10) {
        stopOrbitAnimation()

        orbitContainer.removeFromSuperview()
        orbitContainer = UIView(frame: bounds)
        orbitContainer.center = CGPoint(x: bounds.midX, y: bounds.midY)
        addSubview(orbitContainer)

        for i in 0..<dotCount {
            let angle = CGFloat(i) / CGFloat(dotCount) * 2 * .pi
            let dot = UIView(frame: CGRect(x: 0, y: 0, width: dotSize, height: dotSize))
            dot.layer.cornerRadius = dotSize / 2
            dot.backgroundColor = self.backgroundColor ?? .white

            let x = orbitRadius * cos(angle)
            let y = orbitRadius * sin(angle)
            dot.center = CGPoint(x: orbitContainer.bounds.midX + x, y: orbitContainer.bounds.midY + y)

            orbitContainer.addSubview(dot)
            orbitDots.append(dot)
        }

        // 開始小圓圈的動畫
        orbitTimer = Timer.scheduledTimer(withTimeInterval: 1.0 / 60.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.orbitContainer.transform = self.orbitContainer.transform.rotated(by: 0.02)
        }
    }

    func stopOrbitAnimation() {
        orbitTimer?.invalidate()
        orbitTimer = nil
        orbitDots.forEach { $0.removeFromSuperview() }
        orbitDots.removeAll()
        orbitContainer.removeFromSuperview()
    }
}

