//
//  TouchInfo.swift
//  RandoFun
//
//  Created by Tim Zheng on 2025/6/5.
//

import UIKit

class TouchInfo {
    let id: ObjectIdentifier
    let touch: UITouch
    let startTime: Date
    let color: UIColor
    var haloView: HaloView?
    var isValid: Bool = false

    init(touch: UITouch, color: UIColor) {
        self.id = ObjectIdentifier(touch)
        self.touch = touch
        self.color = color
        self.startTime = Date()
    }

    var duration: TimeInterval {
        return Date().timeIntervalSince(startTime)
    }
}
