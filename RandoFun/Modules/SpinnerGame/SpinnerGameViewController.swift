//
//  SpinnerView.swift
//  RandoFun
//
//  Created by Tim Tseng on 2025/6/12.
//

import UIKit

struct SpinnerOption {
    var title: String
    var weight: CGFloat // 占轉盤的比例，0.0 ~ 1.0 加總應為 1.0
}

struct SpinnerOptionStorage: Codable {
    var title: String
    var weight: Int? // 1~999，若為 nil 則表示未設定
}

class SpinnerGameViewController: UIViewController {

    private let titleLabel: UITextField = {
        let label = UITextField()
        label.text = "吃什麼好呢？"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.textColor = .white
        label.backgroundColor = .clear
        label.borderStyle = .none
        label.clearButtonMode = .whileEditing
        return label
    }()
    
    private let selectedOptionLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label.textColor = .lightGray
        label.text = "???"
        return label
    }()

    private let spinnerView = SpinnerView()
    private let startButton = UIButton(type: .system)
    private let settingsButton = UIButton(type: .system)
    private let resetButton = UIButton(type: .system)
    
    private var isSpinning = false

    private var options: [SpinnerOption]!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        
        options = UserDefaultsManager.shared.getSpinnerOptions() ?? [ // default fallback
            SpinnerOption(title: "壽司", weight: 0.2),
            SpinnerOption(title: "牛肉麵", weight: 0.2),
            SpinnerOption(title: "火鍋", weight: 0.2),
            SpinnerOption(title: "漢堡", weight: 0.2),
            SpinnerOption(title: "便當", weight: 0.2)
        ]

        layoutUI()
        spinnerView.setOptions(options)
        
        // 接收轉盤即時更新結果的 callback
        spinnerView.onSelectionUpdate = { [weak self] selectedTitle in
            self?.selectedOptionLabel.text = selectedTitle
            UserDefaultsManager.shared.incrementUsage(for: .spinner)
        }
    }

    private func layoutUI() {
        view.addSubview(titleLabel)
        view.addSubview(selectedOptionLabel)
        view.addSubview(spinnerView)
        view.addSubview(startButton)
        view.addSubview(settingsButton)
        view.addSubview(resetButton)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        selectedOptionLabel.translatesAutoresizingMaskIntoConstraints = false
        spinnerView.translatesAutoresizingMaskIntoConstraints = false
        startButton.translatesAutoresizingMaskIntoConstraints = false
        settingsButton.translatesAutoresizingMaskIntoConstraints = false
        resetButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            titleLabel.bottomAnchor.constraint(equalTo: selectedOptionLabel.topAnchor, constant: -8),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            selectedOptionLabel.bottomAnchor.constraint(equalTo: spinnerView.topAnchor, constant: -30),
            selectedOptionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            spinnerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            spinnerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            spinnerView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            spinnerView.heightAnchor.constraint(equalTo: spinnerView.widthAnchor),

            startButton.topAnchor.constraint(equalTo: spinnerView.bottomAnchor, constant: 20),
            startButton.centerXAnchor.constraint(equalTo: spinnerView.centerXAnchor),
            startButton.heightAnchor.constraint(equalToConstant: 44),

            settingsButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            settingsButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            resetButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            resetButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20)
        ])

        startButton.setTitle("開始", for: .normal)
        startButton.setTitleColor(.white, for: .normal)
        startButton.titleLabel?.font = .boldSystemFont(ofSize: 20)
        startButton.addTarget(self, action: #selector(startSpin), for: .touchUpInside)

        let gearImage = UIImage(systemName: "gearshape")?.withRenderingMode(.alwaysTemplate)
        settingsButton.setImage(gearImage, for: .normal)
        settingsButton.tintColor = .white
        settingsButton.imageView?.contentMode = .scaleAspectFit
        settingsButton.addTarget(self, action: #selector(openSettings), for: .touchUpInside)
        
        let resetImage = UIImage(systemName: "arrow.counterclockwise")?.withRenderingMode(.alwaysTemplate)
        resetButton.setImage(resetImage, for: .normal)
        resetButton.tintColor = .white
        resetButton.imageView?.contentMode = .scaleAspectFit
        resetButton.addTarget(self, action: #selector(resetSpinState), for: .touchUpInside)
    }

    @objc private func startSpin() {
        guard !UserDefaultsManager.shared.isLimitReached(for: .spinner) else {
            presentUpgradeViewController()
            return
        }
        
        guard !isSpinning else { return }
        isSpinning = true
        
        spinnerView.spinToRandomOption()
    }

    @objc private func openSettings() {
        let settingsVC = SpinnerSettingsViewController(options: options)
        settingsVC.onSave = { [weak self] updatedOptions in
            self?.options = updatedOptions
            self?.spinnerView.setOptions(updatedOptions)
            UserDefaultsManager.shared.saveSpinnerOptions(updatedOptions)
        }

        let nav = UINavigationController(rootViewController: settingsVC)
        nav.modalPresentationStyle = .formSheet
        present(nav, animated: true)
    }
    
    @objc private func resetSpinState() {
        selectedOptionLabel.text = "???"
        spinnerView.resetHighlight()
    }
}
