//
//  CoinFlipGameViewController.swift
//  RandoFun
//
//  Created by Tim Tseng on 2025/6/5.
//

import UIKit

class CoinFlipGameViewController: UIViewController {
    private let coinImageView = UIImageView()
    private let flipButton = UIButton(type: .system)
    private let settingsButton = UIButton(type: .system)
    
    private var isHeads = true // true: heads, false: tails
    private var coinStyle = UserDefaultsManager.shared.getSelectedCoinStyle() ?? "coin_classic" // coin asset prefix, like "default", "gold", etc.
    private var displayLink: CADisplayLink?
    private var animationStartTime: CFTimeInterval = 0
    private var animationDuration: CFTimeInterval = 1.0
    private var rotationCount = 6 // 翻轉 3 圈（6 次 180 度）
    
    //Count view
    private let headsImageView = UIImageView()
    private let headsCountLabel = UILabel()
    private let tailsImageView = UIImageView()
    private let tailsCountLabel = UILabel()
    private var frontCount = 0
    private var backCount = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        
        // 建立 perspective 效果（不要設在 coinImageView 本身）
        var perspective = CATransform3DIdentity
        perspective.m34 = -1.0 / 500
        view.layer.sublayerTransform = perspective

        setupUI()
        updateCoinImage(showHeads: true)
    }

    private func setupUI() {
        // 新增上方計數列 StackView
        let countStack = UIStackView(arrangedSubviews: [headsImageView, headsCountLabel, tailsImageView, tailsCountLabel])
        countStack.axis = .horizontal
        countStack.spacing = 16
        countStack.alignment = .center
        countStack.distribution = .equalSpacing
        view.addSubview(countStack)
        countStack.translatesAutoresizingMaskIntoConstraints = false

        headsImageView.contentMode = .scaleAspectFit
        tailsImageView.contentMode = .scaleAspectFit
        headsImageView.widthAnchor.constraint(equalToConstant: 48).isActive = true
        headsImageView.heightAnchor.constraint(equalToConstant: 48).isActive = true
        tailsImageView.widthAnchor.constraint(equalToConstant: 48).isActive = true
        tailsImageView.heightAnchor.constraint(equalToConstant: 48).isActive = true

        headsCountLabel.textColor = .white
        headsCountLabel.font = .monospacedDigitSystemFont(ofSize: 26, weight: .regular)
        tailsCountLabel.textColor = .white
        tailsCountLabel.font = .monospacedDigitSystemFont(ofSize: 26, weight: .regular)

        NSLayoutConstraint.activate([
            countStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            countStack.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])

        // 初始化正反圖片
        updateCountIcons()
        
        // 翻轉的硬幣
        coinImageView.contentMode = .scaleAspectFit
        view.addSubview(coinImageView)
        coinImageView.translatesAutoresizingMaskIntoConstraints = false

        flipButton.setTitle("Flip Coin", for: .normal)
        flipButton.setTitleColor(.white, for: .normal)
        flipButton.titleLabel?.font = .boldSystemFont(ofSize: 18)
        view.addSubview(flipButton)
        flipButton.translatesAutoresizingMaskIntoConstraints = false

        // 設定按鈕
        let gearImage = UIImage(systemName: "gearshape")?.withRenderingMode(.alwaysTemplate)
        settingsButton.setImage(gearImage, for: .normal)
        settingsButton.tintColor = .white
        settingsButton.imageView?.contentMode = .scaleAspectFit
        view.addSubview(settingsButton)
        settingsButton.translatesAutoresizingMaskIntoConstraints = false
        
        
        let resetButton = UIButton(type: .system)
        let resetImage = UIImage(systemName: "arrow.counterclockwise")?.withRenderingMode(.alwaysTemplate)
        resetButton.setImage(resetImage, for: .normal)
        resetButton.tintColor = .white
        resetButton.imageView?.contentMode = .scaleAspectFit
        view.addSubview(resetButton)
        resetButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            coinImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            coinImageView.bottomAnchor.constraint(equalTo: flipButton.topAnchor, constant: -20),
            coinImageView.widthAnchor.constraint(equalToConstant: 250),
            coinImageView.heightAnchor.constraint(equalToConstant: 250),

            flipButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            flipButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40),
            flipButton.heightAnchor.constraint(equalToConstant: 44),

            settingsButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            settingsButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            resetButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            resetButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20)
        ])

        // 全畫面觸控事件
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(flipCoin))
        view.addGestureRecognizer(tapGesture)

        flipButton.addTarget(self, action: #selector(flipCoin), for: .touchUpInside)
        settingsButton.addTarget(self, action: #selector(openSettings), for: .touchUpInside)
        resetButton.addTarget(self, action: #selector(resetCount), for: .touchUpInside)
    }
    
    private func updateCountIcons() {
        headsImageView.image = UIImage(named: "\(coinStyle)_front")
        tailsImageView.image = UIImage(named: "\(coinStyle)_back")
        headsCountLabel.text = "\(frontCount)"
        tailsCountLabel.text = "\(backCount)"
    }

    private func updateCoinImage(showHeads: Bool) {
        let imageName = "\(coinStyle)_\(showHeads ? "front" : "back")"
        coinImageView.image = UIImage(named: imageName)
    }

    //MARK: - Button actions
    @objc private func flipCoin() {
        let totalRotation = Double.pi * Double(rotationCount)
        animationStartTime = CACurrentMediaTime()

        // 建立 perspective 效果
        var transform = CATransform3DIdentity
        transform.m34 = -1.0 / 500
        coinImageView.superview?.layer.sublayerTransform = transform

        let animation = CABasicAnimation(keyPath: "transform.rotation.x")
        animation.fromValue = 0
        animation.toValue = totalRotation
        animation.duration = animationDuration
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        animation.isRemovedOnCompletion = false
        animation.fillMode = .forwards

        coinImageView.layer.add(animation, forKey: "flip")
        
        // 決定最終面
        isHeads = Bool.random()

        startDisplayLink()
    }

    
    private func startDisplayLink() {
        stopDisplayLink()
        displayLink = CADisplayLink(target: self, selector: #selector(updateCoinFrame))
        displayLink?.add(to: .main, forMode: .common)
    }

    private func stopDisplayLink() {
        displayLink?.invalidate()
        displayLink = nil
    }

    @objc private func updateCoinFrame() {
        let elapsed = CACurrentMediaTime() - animationStartTime
        if elapsed >= animationDuration {
            stopDisplayLink()
            updateCoinImage(showHeads: isHeads)
            coinImageView.layer.transform = CATransform3DIdentity
            
            if isHeads {
                frontCount += 1
            } else {
                backCount += 1
            }
            updateCountIcons()
            return
        }

        let progress = elapsed / animationDuration
        let angle = Double.pi * Double(rotationCount) * progress
        let flipped = Int((angle / .pi).rounded(.down)) % 2 == 1
        updateCoinImage(showHeads: !flipped)

        let screenHeight = UIScreen.main.bounds.height
        let maxYOffset = screenHeight * 0.5
        let normalized = CGFloat(progress)
        let verticalOffset = -maxYOffset * (-4 * pow(normalized - 0.5, 2) + 1)

        // 👉 不加 m34，只加位移與旋轉
        var transform = CATransform3DIdentity
        transform = CATransform3DTranslate(transform, 0, verticalOffset, 0)
        transform = CATransform3DRotate(transform, CGFloat(angle), 1, 0, 0)

        coinImageView.layer.transform = transform
    }

    @objc private func openSettings() {
        let settingsVC = CoinSettingsViewController(currentStyle: coinStyle)
        settingsVC.onStyleChanged = { [weak self] newStyle in
            UserDefaultsManager.shared.saveSelectedCoinStyle(newStyle)
            self?.coinStyle = newStyle
            self?.updateCoinImage(showHeads: true)
            self?.isHeads = true
            self?.frontCount = 0
            self?.backCount = 0
            self?.updateCountIcons()
        }
        let nav = UINavigationController(rootViewController: settingsVC)
        present(nav, animated: true)
    }
    
    @objc private func resetCount() {
        frontCount = 0
        backCount = 0
        updateCountIcons()
    }
}
