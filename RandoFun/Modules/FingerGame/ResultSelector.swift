//
//  ResultSelector.swift
//  RandoFun
//
//  Created by Tim Tseng on 2025/6/6.
//

import Foundation

import UIKit

class ResultSelector {
    /// 從參與者中選出 N 位贏家，更新視覺樣式
    static func pickWinners(from participants: [TouchInfo], winnerCount: Int) {
        guard !participants.isEmpty else { return }

        let winners = Array(participants.shuffled().prefix(winnerCount))

        for info in participants {
            if winners.contains(where: { $0.id == info.id }) {
                info.haloView?.alpha = 1.0
                info.haloView?.startOrbitAnimation(dotCount: 10)
            } else {
                info.haloView?.alpha = 0.3
                info.haloView?.stopOrbitAnimation()
            }
        }
    }
}
