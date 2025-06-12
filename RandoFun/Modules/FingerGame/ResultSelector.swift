//
//  ResultSelector.swift
//  RandoFun
//
//  Created by Tim Zheng on 2025/6/6.
//

import Foundation

import UIKit

class ResultSelector {
    static func pickWinner(from participants: [TouchInfo]) -> TouchInfo? {
        guard !participants.isEmpty else { return nil }

        let winner = participants.randomElement()

        for info in participants {
            if info === winner {
                info.haloView?.alpha = 1.0
            } else {
                info.haloView?.alpha = 0.2
            }
        }

        return winner
    }
}
