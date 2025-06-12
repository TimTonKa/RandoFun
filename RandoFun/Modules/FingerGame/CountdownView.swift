//
//  CountdownView.swift
//  RandoFun
//
//  Created by Tim Tseng on 2025/6/10.
//

import UIKit

class CountdownView: UILabel {
    private var timer: Timer?
    private var remaining: Int = 0
    private var onFinished: (() -> Void)?

    init() {
        super.init(frame: .zero)
        setupStyle()
        alpha = 0
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupStyle() {
        textAlignment = .center
        textColor = .white
        font = UIFont.systemFont(ofSize: 80, weight: .bold)
        backgroundColor = UIColor.black.withAlphaComponent(0.3)
        layer.cornerRadius = 20
        clipsToBounds = true
    }

    func start(duration: Int = 3, onFinished: @escaping () -> Void) {
        self.remaining = duration
        self.onFinished = onFinished
        self.alpha = 1
        updateText()

        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self,
                                     selector: #selector(tick), userInfo: nil, repeats: true)
    }

    func reset() {
        timer?.invalidate()
        timer = nil
        self.alpha = 0
    }

    @objc private func tick() {
        remaining -= 1
        if remaining <= 0 {
            timer?.invalidate()
            timer = nil
            fadeOutAndFinish()
        } else {
            animateBounce()
            updateText()
        }
    }

    private func updateText() {
        self.text = "\(remaining)"
    }

    private func animateBounce() {
        self.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
        UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseOut]) {
            self.transform = .identity
        }
    }

    private func fadeOutAndFinish() {
        UIView.animate(withDuration: 0.3, animations: {
            self.alpha = 0
        }, completion: { _ in
            self.onFinished?()
        })
    }
}
