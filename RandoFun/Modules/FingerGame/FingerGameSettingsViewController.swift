//
//  FingerGameSettingsViewController.swift
//  RandoFun
//
//  Created by Tim Zheng on 2025/6/18.
//

import UIKit

class FingerGameSettingsViewController: UIViewController {

    private let maxWinnersLabel = UILabel()
    private let maxWinnersStepper = UIStepper()
    private let orbitDurationLabel = UILabel()
    private let orbitDurationSlider = UISlider()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "設定"
        setupUI()
        loadSettings()
    }

    private func setupUI() {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 24
        stack.alignment = .leading
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])

        // Max Winners
        maxWinnersLabel.font = .systemFont(ofSize: 16)
        maxWinnersStepper.minimumValue = 1
        maxWinnersStepper.maximumValue = 4
        maxWinnersStepper.addTarget(self, action: #selector(maxWinnersChanged), for: .valueChanged)

        let maxWinnersStack = UIStackView(arrangedSubviews: [maxWinnersLabel, maxWinnersStepper])
        maxWinnersStack.axis = .horizontal
        maxWinnersStack.spacing = 16

        // Orbit Duration
        orbitDurationLabel.font = .systemFont(ofSize: 16)
        orbitDurationSlider.minimumValue = 1.0
        orbitDurationSlider.maximumValue = 10.0
        orbitDurationSlider.addTarget(self, action: #selector(orbitDurationChanged), for: .valueChanged)

        let orbitStack = UIStackView(arrangedSubviews: [orbitDurationLabel, orbitDurationSlider])
        orbitStack.axis = .vertical
        orbitStack.spacing = 8

        stack.addArrangedSubview(maxWinnersStack)
        stack.addArrangedSubview(orbitStack)
    }

    private func loadSettings() {
        let savedWinners = UserDefaultsManager.shared.getMaxWinners()
        let winners = savedWinners > 0 ? savedWinners : 1
        maxWinnersStepper.value = Double(winners)
        maxWinnersLabel.text = "贏家人數：\(winners)"

        let savedDuration = UserDefaultsManager.shared.getOrbitDuration()
        let duration = savedDuration > 0 ? savedDuration : 4.0
        orbitDurationSlider.value = Float(duration)
        orbitDurationLabel.text = "動畫秒數：\(String(format: "%.1f", duration)) 秒"
    }

    @objc private func maxWinnersChanged() {
        let value = Int(maxWinnersStepper.value)
        maxWinnersLabel.text = "贏家人數：\(value)"
        UserDefaultsManager.shared.saveMaxWinners(value)
    }

    @objc private func orbitDurationChanged() {
        let value = Double(orbitDurationSlider.value)
        orbitDurationLabel.text = "動畫秒數：\(String(format: "%.1f", value)) 秒"
        UserDefaultsManager.shared.saveOrbitDuration(value)
    }
}
