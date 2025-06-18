//
//  SpinnerView.swift
//  RandoFun
//
//  Created by Tim Tseng on 2025/6/12.
//

import UIKit

class SpinnerView: UIView {
    private var options: [SpinnerOption] = []
    private var segments: [CAShapeLayer] = []
    private var textLayers: [CATextLayer] = []
    private var wheelLayer = CALayer()
    private var arrowLayer = CAShapeLayer()
    private var currentRotation: CGFloat = 0
    
    private var displayLink: CADisplayLink?
    private var animationStartTime: CFTimeInterval = 0
    private var animationDuration: CFTimeInterval = 3.0
    private var startRotation: CGFloat = 0
    private var endRotation: CGFloat = 0

    var onSelectionUpdate: ((String) -> Void)? // <- 新增 callback

    func setOptions(_ options: [SpinnerOption]) {
        self.options = options
        setupWheel()
    }

    private func setupWheel() {
        layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        segments.removeAll()
        textLayers.removeAll()

        wheelLayer = CALayer()
        wheelLayer.frame = bounds
        wheelLayer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        wheelLayer.position = CGPoint(x: bounds.midX, y: bounds.midY)
        layer.addSublayer(wheelLayer)

        let radius = bounds.width / 2
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        var startAngle: CGFloat = -.pi / 2
        let hueStep = 1.0 / CGFloat(options.count)

        for (index, option) in options.enumerated() {
            let endAngle = startAngle + (2 * .pi * option.weight)
            let path = UIBezierPath()
            path.move(to: center)
            path.addArc(withCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)

            let segment = CAShapeLayer()
            let hue = CGFloat(index) * hueStep
            segment.fillColor = UIColor(hue: hue, saturation: 0.8, brightness: 0.9, alpha: 1).cgColor
            segment.path = path.cgPath
            wheelLayer.addSublayer(segment)
            segments.append(segment)

            let textLayer = CATextLayer()
            textLayer.string = option.title
            textLayer.alignmentMode = .center
            textLayer.foregroundColor = UIColor.black.cgColor
            textLayer.fontSize = 16
            textLayer.contentsScale = UIScreen.main.scale
            let midAngle = (startAngle + endAngle) / 2
            let textRadius = radius * 0.65
            let textCenter = CGPoint(x: center.x + cos(midAngle) * textRadius, y: center.y + sin(midAngle) * textRadius)
            textLayer.frame = CGRect(x: textCenter.x - 40, y: textCenter.y - 10, width: 80, height: 20)
            wheelLayer.addSublayer(textLayer)
            textLayers.append(textLayer)

            startAngle = endAngle
        }

        // Arrow
        let arrowHeight: CGFloat = 20
        let arrowWidth: CGFloat = 20
        let arrowCenterX = bounds.midX
        let arrowTipY = bounds.midY - (bounds.width / 2) - 5
        let arrowPath = UIBezierPath()
        arrowPath.move(to: CGPoint(x: 0, y: 0))
        arrowPath.addLine(to: CGPoint(x: arrowWidth, y: 0))
        arrowPath.addLine(to: CGPoint(x: arrowWidth / 2, y: arrowHeight))
        arrowPath.close()

        arrowLayer = CAShapeLayer()
        arrowLayer.path = arrowPath.cgPath
        arrowLayer.fillColor = UIColor.red.cgColor
        arrowLayer.frame = CGRect(x: arrowCenterX - arrowWidth / 2,
                                  y: arrowTipY - arrowHeight,
                                  width: arrowWidth,
                                  height: arrowHeight)
        layer.addSublayer(arrowLayer)
    }

    func spinToRandomOption() {
        resetSegmentAppearance()

        let fullRotations: CGFloat = CGFloat(Int.random(in: 5...8)) * .pi * 2
        let randomOffset = CGFloat.random(in: 0..<1)
        let offsetAngle = 2 * .pi * randomOffset
        let totalRotation = fullRotations + offsetAngle

        startRotation = 0
        endRotation = totalRotation
        animationStartTime = CACurrentMediaTime()
        animationDuration = 3.0

        let animation = CABasicAnimation(keyPath: "transform.rotation.z")
        animation.fromValue = startRotation
        animation.toValue = endRotation
        animation.duration = animationDuration
        animation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        animation.isRemovedOnCompletion = false
        animation.fillMode = .forwards
        wheelLayer.add(animation, forKey: "spin")

        // 開始追蹤動畫進度
        startDisplayLink()
    }

    private func startDisplayLink() {
        stopDisplayLink() // 確保不重複
        displayLink = CADisplayLink(target: self, selector: #selector(updateDisplayLink))
        displayLink?.add(to: .main, forMode: .common)
    }

    private func stopDisplayLink() {
        displayLink?.invalidate()
        displayLink = nil
    }
    
    /// 回傳目前動畫呈現的旋轉角度（從 presentationLayer）
    private func currentAnimatedRotation() -> CGFloat? {
        guard let presentation = wheelLayer.presentation(),
              let angle = presentation.value(forKeyPath: "transform.rotation.z") as? CGFloat else {
            return nil
        }
        return angle
    }

    private func notifyCurrentOption(at angle: CGFloat) {
        let pointerAngle = (2 * .pi - angle).truncatingRemainder(dividingBy: 2 * .pi)
        var start: CGFloat = 0
        for (_, option) in options.enumerated() {
            let end = start + (2 * .pi * option.weight)
            if pointerAngle >= start && pointerAngle < end {
                onSelectionUpdate?(option.title)
                break
            }
            start = end
        }
    }
    
    @objc private func updateDisplayLink() {
        guard let angle = currentAnimatedRotation() else { return }

        notifyCurrentOption(at: angle)

        let now = CACurrentMediaTime()
        let elapsed = now - animationStartTime
        if elapsed >= animationDuration {
            stopDisplayLink()
            currentRotation = endRotation.truncatingRemainder(dividingBy: 2 * .pi)
            highlightOptionForAngle(currentRotation)
        }
    }
    
    private func easeOut(_ t: CGFloat) -> CGFloat {
        return 1 - pow(1 - t, 3)
    }

    private func highlightOptionForAngle(_ angle: CGFloat) {
        let pointerAngle = (2 * .pi - angle).truncatingRemainder(dividingBy: 2 * .pi)
        var start: CGFloat = 0
        for (i, option) in options.enumerated() {
            let end = start + (2 * .pi * option.weight)
            if pointerAngle >= start && pointerAngle < end {
                highlight(index: i)
                onSelectionUpdate?(option.title)
                break
            }
            start = end
        }
    }

    private func highlight(index: Int) {
        for (i, segment) in segments.enumerated() {
            segment.opacity = i == index ? 1.0 : 0.3
        }
        for (i, textLayer) in textLayers.enumerated() {
            textLayer.foregroundColor = i == index ? UIColor.black.cgColor : UIColor.darkGray.cgColor
        }
    }

    private func resetSegmentAppearance() {
        for segment in segments {
            segment.opacity = 1.0
        }
        for text in textLayers {
            text.foregroundColor = UIColor.black.cgColor
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        setupWheel()
    }
    
    func resetHighlight() {
        resetSegmentAppearance()
    }
}
