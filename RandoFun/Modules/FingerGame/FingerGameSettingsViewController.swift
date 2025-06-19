//
//  FingerGameSettingsViewController.swift
//  RandoFun
//
//  Created by Tim Tseng on 2025/6/18.
//

import UIKit

class FingerGameSettingsViewController: UIViewController {

    private let maxWinnersTitleLabel = UILabel()
    private let maxWinnersValueLabel = UILabel()
    private let maxWinnersStepper = UIStepper()

    private let orbitDurationTitleLabel = UILabel()
    private let orbitDurationValueLabel = UILabel()
    private let orbitDurationSlider = UISlider()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        title = "遊戲設定"
        setupUI()
        loadSettings()
    }

    private func setupUI() {
        let scrollView = UIScrollView()
        let contentView = UIView()

        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])

        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 24
        stack.alignment = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])

        // 贏家人數區塊
        let winnersCard = makeCardView()
        let winnersStack = UIStackView()
        winnersStack.axis = .vertical
        winnersStack.spacing = 12

        maxWinnersTitleLabel.text = "贏家人數"
        maxWinnersTitleLabel.font = .systemFont(ofSize: 17, weight: .medium)

        let winnersStepperRow = UIStackView(arrangedSubviews: [maxWinnersStepper, maxWinnersValueLabel])
        winnersStepperRow.axis = .horizontal
        winnersStepperRow.distribution = .equalSpacing

        maxWinnersStepper.minimumValue = 1
        maxWinnersStepper.maximumValue = 4
        maxWinnersStepper.addTarget(self, action: #selector(maxWinnersChanged), for: .valueChanged)

        maxWinnersValueLabel.font = .monospacedDigitSystemFont(ofSize: 16, weight: .regular)
        maxWinnersValueLabel.textColor = .secondaryLabel

        winnersStack.addArrangedSubview(maxWinnersTitleLabel)
        winnersStack.addArrangedSubview(winnersStepperRow)
        winnersCard.addSubview(winnersStack)
        winnersStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            winnersStack.topAnchor.constraint(equalTo: winnersCard.topAnchor, constant: 16),
            winnersStack.leadingAnchor.constraint(equalTo: winnersCard.leadingAnchor, constant: 16),
            winnersStack.trailingAnchor.constraint(equalTo: winnersCard.trailingAnchor, constant: -16),
            winnersStack.bottomAnchor.constraint(equalTo: winnersCard.bottomAnchor, constant: -16)
        ])
        stack.addArrangedSubview(winnersCard)

        // 動畫秒數區塊
        let orbitCard = makeCardView()
        let orbitStack = UIStackView()
        orbitStack.axis = .vertical
        orbitStack.spacing = 12

        orbitDurationTitleLabel.text = "動畫時長"
        orbitDurationTitleLabel.font = .systemFont(ofSize: 17, weight: .medium)

        orbitDurationSlider.minimumValue = 1.0
        orbitDurationSlider.maximumValue = 10.0
        orbitDurationSlider.addTarget(self, action: #selector(orbitDurationChanged), for: .valueChanged)

        orbitDurationValueLabel.font = .monospacedDigitSystemFont(ofSize: 16, weight: .regular)
        orbitDurationValueLabel.textColor = .secondaryLabel
        orbitDurationValueLabel.textAlignment = .right

        orbitStack.addArrangedSubview(orbitDurationTitleLabel)
        orbitStack.addArrangedSubview(orbitDurationSlider)
        orbitStack.addArrangedSubview(orbitDurationValueLabel)

        orbitCard.addSubview(orbitStack)
        orbitStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            orbitStack.topAnchor.constraint(equalTo: orbitCard.topAnchor, constant: 16),
            orbitStack.leadingAnchor.constraint(equalTo: orbitCard.leadingAnchor, constant: 16),
            orbitStack.trailingAnchor.constraint(equalTo: orbitCard.trailingAnchor, constant: -16),
            orbitStack.bottomAnchor.constraint(equalTo: orbitCard.bottomAnchor, constant: -16)
        ])
        stack.addArrangedSubview(orbitCard)
    }

    private func makeCardView() -> UIView {
        let card = UIView()
        card.backgroundColor = .secondarySystemBackground
        card.layer.cornerRadius = 12
        card.layer.shadowOffset = CGSize(width: 0, height: 2)
        card.layer.shadowRadius = 4
        card.layer.shadowOpacity = 0.05
        
        if traitCollection.userInterfaceStyle == .dark {
            card.layer.shadowColor = UIColor.white.cgColor
        } else {
            card.layer.shadowColor = UIColor.black.cgColor
        }

        return card
    }


    private func loadSettings() {
        let savedWinners = UserDefaultsManager.shared.getMaxWinners()
        let winners = savedWinners > 0 ? savedWinners : 1
        maxWinnersStepper.value = Double(winners)
        maxWinnersValueLabel.text = "\(winners) 人"

        let savedDuration = UserDefaultsManager.shared.getOrbitDuration()
        let duration = savedDuration > 0 ? savedDuration : 4.0
        orbitDurationSlider.value = Float(duration)
        orbitDurationValueLabel.text = "\(String(format: "%.1f", duration)) 秒"
    }

    @objc private func maxWinnersChanged() {
        let value = Int(maxWinnersStepper.value)
        maxWinnersValueLabel.text = "\(value) 人"
        UserDefaultsManager.shared.saveMaxWinners(value)
    }

    @objc private func orbitDurationChanged() {
        let value = Double(orbitDurationSlider.value)
        orbitDurationValueLabel.text = "\(String(format: "%.1f", value)) 秒"
        UserDefaultsManager.shared.saveOrbitDuration(value)
    }
}
