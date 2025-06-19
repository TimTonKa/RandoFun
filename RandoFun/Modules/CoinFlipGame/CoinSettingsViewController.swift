//
//  CoinSettingsViewController.swift
//  RandoFun
//
//  Created by Tim Tseng on 2025/6/18.
//

import UIKit

class CoinSettingsViewController: UIViewController {

    private let styles = [
        "coin_classic",
        "coin_funny",
        "coin_japanese",
        "coin_futuristic"
    ]

    private var selectedStyle: String
    var onStyleChanged: ((String) -> Void)?

    init(currentStyle: String) {
        self.selectedStyle = currentStyle
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "選擇硬幣樣式"

        let scrollView = UIScrollView()
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])

        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 20
        stack.alignment = .center
        scrollView.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            stack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            stack.widthAnchor.constraint(equalTo: scrollView.widthAnchor) // important for vertical scroll
        ])

        for style in styles {
            let container = createCoinOptionView(for: style)
            stack.addArrangedSubview(container)
        }
    }

    private func createCoinOptionView(for style: String) -> UIView {
        let frontImage = UIImage(named: "\(style)_front")
        let backImage = UIImage(named: "\(style)_back")

        let frontImageView = UIImageView(image: frontImage)
        frontImageView.contentMode = .scaleAspectFit
        frontImageView.clipsToBounds = true
        frontImageView.widthAnchor.constraint(equalToConstant: 80).isActive = true
        frontImageView.heightAnchor.constraint(equalToConstant: 80).isActive = true

        let backImageView = UIImageView(image: backImage)
        backImageView.contentMode = .scaleAspectFit
        backImageView.clipsToBounds = true
        backImageView.widthAnchor.constraint(equalToConstant: 80).isActive = true
        backImageView.heightAnchor.constraint(equalToConstant: 80).isActive = true

        let label = UILabel()
        label.text = style.capitalized
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .center

        let hStack = UIStackView(arrangedSubviews: [frontImageView, backImageView])
        hStack.axis = .horizontal
        hStack.spacing = 12

        let vStack = UIStackView(arrangedSubviews: [hStack, label])
        vStack.axis = .vertical
        vStack.alignment = .center
        vStack.spacing = 8
        vStack.isUserInteractionEnabled = true
        vStack.tag = styles.firstIndex(of: style) ?? 0

        vStack.layer.borderColor = style == selectedStyle ? UIColor.systemBlue.cgColor : UIColor.clear.cgColor
        vStack.layer.borderWidth = 2
        vStack.layer.cornerRadius = 10
        vStack.layoutMargins = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        vStack.isLayoutMarginsRelativeArrangement = true

        let tap = UITapGestureRecognizer(target: self, action: #selector(styleTapped(_:)))
        vStack.addGestureRecognizer(tap)

        return vStack
    }

    @objc private func styleTapped(_ sender: UITapGestureRecognizer) {
        guard let tappedView = sender.view else { return }
        let style = styles[tappedView.tag]
        onStyleChanged?(style)
        dismiss(animated: true)
    }
}
