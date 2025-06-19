//
//  FingerGameViewController.swift
//  RandoFun
//
//  Created by Tim Tseng on 2025/6/5.
//

import UIKit
import OSLog

class FingerGameViewController: UIViewController {
    private let logger = Logger(subsystem: "", category: String(describing: FingerGameViewController.self))
    private var activeTouches: [ObjectIdentifier: TouchInfo] = [:]
    private let validTouchDelay: TimeInterval = 2.0
    private let colors: [UIColor] = [.systemRed, .systemBlue, .systemGreen, .systemYellow, .systemPurple]

    private let countdownView = CountdownView()
    private var hasTriggeredCountdownResult = false
    
    private var orbitTimer: Timer?
    private var orbitStartTime: Date?
    private var orbitingHalo: HaloView?
    
    private var gameFinished = false
    
    private let settingsButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        view.isMultipleTouchEnabled = true

        addCountdownView()
        addSettingsButton()
    }

    private func addCountdownView() {
        view.addSubview(countdownView)
        countdownView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            countdownView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            countdownView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            countdownView.widthAnchor.constraint(equalToConstant: 120),
            countdownView.heightAnchor.constraint(equalToConstant: 120)
        ])
    }
    
    private func addSettingsButton() {
        let gearImage = UIImage(systemName: "gearshape")?.withRenderingMode(.alwaysTemplate)
        settingsButton.setImage(gearImage, for: .normal)
        settingsButton.tintColor = .white
        settingsButton.imageView?.contentMode = .scaleAspectFit
        settingsButton.addTarget(self, action: #selector(openSettings), for: .touchUpInside)

        view.addSubview(settingsButton)
        settingsButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            settingsButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            settingsButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            settingsButton.widthAnchor.constraint(equalToConstant: 32),
            settingsButton.heightAnchor.constraint(equalToConstant: 32)
        ])
    }
    
    @objc private func openSettings() {
        let settingsVC = FingerGameSettingsViewController()
        let nav = UINavigationController(rootViewController: settingsVC)
        present(nav, animated: true)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if gameFinished {
            logger.debug("🎮 遊戲已完成，等待所有手指離開，忽略新手指加入")
            return
        }
        
        countdownView.reset()

        for touch in touches {
            let id = ObjectIdentifier(touch)
            guard activeTouches[id] == nil else { continue }

            let color = colors[activeTouches.count % colors.count]
            let info = TouchInfo(touch: touch, color: color)
            activeTouches[id] = info

            let point = touch.location(in: view)
            let halo = HaloView(center: point, color: color)
            view.addSubview(halo)
            info.haloView = halo
        }

        if !activeTouches.isEmpty {
            countdownView.start(duration: 3) { [weak self] in
                self?.logger.debug("countdown complete")
                self?.handleCountdownFinished()
            }
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let id = ObjectIdentifier(touch)
            if let info = activeTouches[id], let halo = info.haloView {
                let point = touch.location(in: view)
                halo.center = point
            }
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        removeTouches(touches)
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        removeTouches(touches)
    }

    private func removeTouches(_ touches: Set<UITouch>) {
        for touch in touches {
            let id = ObjectIdentifier(touch)
            if let info = activeTouches.removeValue(forKey: id) {
                info.haloView?.stopOrbitAnimation()
                info.haloView?.removeFromSuperview()

                if info.duration < validTouchDelay {
                    logger.debug("無效參與(不足兩秒)")
                } else {
                    info.isValid = true
                    logger.debug("✅ 有效參與(壓超過兩秒)")
                }
            }
        }

        if activeTouches.isEmpty {
            countdownView.reset()
            hasTriggeredCountdownResult = false
            gameFinished = false
        }
    }

    private func handleCountdownFinished() {
        guard !hasTriggeredCountdownResult else { return }
        hasTriggeredCountdownResult = true

        logger.debug("🚀 倒數結束，開始繞圈動畫")
        let valid = activeTouches.values.filter { $0.duration >= validTouchDelay }
        guard !valid.isEmpty else { return }
        
        let duration = UserDefaultsManager.shared.getOrbitDuration()
        let orbitDuration = duration > 0 ? duration : 4.0
        
        let count = UserDefaultsManager.shared.getMaxWinners()
        let winnerCount = (1...4).contains(count) ? count : 1

        orbitStartTime = Date()

        orbitTimer = Timer.scheduledTimer(withTimeInterval: 0.6, repeats: true) { [weak self] _ in
            guard let self = self,
                  let start = self.orbitStartTime else { return }

            let elapsed = Date().timeIntervalSince(start)
            if elapsed >= orbitDuration {
                self.orbitTimer?.invalidate()
                self.orbitTimer = nil
                
                // 停止上一個 orbitingHalo 的動畫
                self.orbitingHalo?.stopOrbitAnimation()
                self.orbitingHalo = nil

                // 🎉 最後選出勝者
                ResultSelector.pickWinners(from: valid, winnerCount: winnerCount)
                self.gameFinished = true
                return
            }

            // 隨機選一個光圈
            if let target = valid.randomElement(),
               let halo = target.haloView {

                // 停止前一個正在繞圈的
                if self.orbitingHalo !== halo {
                    self.orbitingHalo?.stopOrbitAnimation()
                    self.orbitingHalo = halo
                    halo.startOrbitAnimation(dotCount: 10)
                    halo.alpha = 1.0
                }
            }
        }
    }
}
