import UIKit

class UpgradeViewController: UIViewController {
    private let titleLabel = UILabel()
    private let featuresStackView = UIStackView()
    private let upgradeButton = UIButton(type: .system)
    private let restoreButton = UIButton(type: .system)
    private let activityIndicator = UIActivityIndicatorView(style: .medium)

    private let iapManager = InAppPurchaseManager.shared

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateUpgradeButtonTitle()
    }

    private func setupUI() {
        view.backgroundColor = .black

        // 標題
        titleLabel.text = "升級解鎖所有功能"
        titleLabel.textColor = .white
        titleLabel.font = UIFont.boldSystemFont(ofSize: 28)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        // 功能清單
        featuresStackView.axis = .vertical
        featuresStackView.spacing = 12
        featuresStackView.translatesAutoresizingMaskIntoConstraints = false

        let features = [
            "解除 Finger Game 使用次數限制",
            "解除 Spinner Game 使用次數限制",
            "解除 Flip Coin Game 使用次數限制"
        ]
        for feature in features {
            let label = UILabel()
            label.text = "• \(feature)"
            label.textColor = .white
            label.font = UIFont.systemFont(ofSize: 17)
            featuresStackView.addArrangedSubview(label)
        }

        // 升級按鈕
        upgradeButton.setTitleColor(.white, for: .normal)
        upgradeButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        upgradeButton.backgroundColor = .systemBlue
        upgradeButton.layer.cornerRadius = 12
        upgradeButton.translatesAutoresizingMaskIntoConstraints = false
        upgradeButton.addTarget(self, action: #selector(handleUpgrade), for: .touchUpInside)

        // 活動指示器
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true
        upgradeButton.addSubview(activityIndicator)

        // 恢復購買按鈕
        restoreButton.setTitle("恢復購買", for: .normal)
        restoreButton.setTitleColor(.lightGray, for: .normal)
        restoreButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        restoreButton.translatesAutoresizingMaskIntoConstraints = false
        restoreButton.addTarget(self, action: #selector(handleRestore), for: .touchUpInside)

        // 加入 subviews
        view.addSubview(titleLabel)
        view.addSubview(featuresStackView)
        view.addSubview(upgradeButton)
        view.addSubview(restoreButton)

        // Layout constraints
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            featuresStackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30),
            featuresStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            featuresStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),

            upgradeButton.bottomAnchor.constraint(equalTo: restoreButton.topAnchor, constant: -20),
            upgradeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            upgradeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            upgradeButton.heightAnchor.constraint(equalToConstant: 50),

            activityIndicator.centerYAnchor.constraint(equalTo: upgradeButton.centerYAnchor),
            activityIndicator.trailingAnchor.constraint(equalTo: upgradeButton.trailingAnchor, constant: -20),

            restoreButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            restoreButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
    }

    @objc private func handleUpgrade() {
        guard !iapManager.isPurchased else { return }

        upgradeButton.isEnabled = false
        activityIndicator.startAnimating()

        Task {
            let success = await iapManager.purchase()
            activityIndicator.stopAnimating()
            upgradeButton.isEnabled = true
            updateUpgradeButtonTitle()

            let alert = UIAlertController(
                title: success ? "購買成功" : "購買失敗",
                message: success ? "感謝您的支持！" : "請稍後再試。",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "確定", style: .default))
            self.present(alert, animated: true)
        }
    }

    @objc private func handleRestore() {
        upgradeButton.isEnabled = false
        activityIndicator.startAnimating()

        Task {
            await iapManager.restorePurchase()
            activityIndicator.stopAnimating()
            upgradeButton.isEnabled = true
            updateUpgradeButtonTitle()

            let alert = UIAlertController(
                title: iapManager.isPurchased ? "已恢復購買" : "尚未購買",
                message: iapManager.isPurchased ? "您已恢復購買內容。" : "找不到可恢復的項目。",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "確定", style: .default))
            self.present(alert, animated: true)
        }
    }

    private func updateUpgradeButtonTitle() {
        if iapManager.isPurchased {
            upgradeButton.setTitle("已購買", for: .normal)
            upgradeButton.backgroundColor = .gray
            upgradeButton.isEnabled = false
        } else {
            upgradeButton.setTitle("立即升級 NT$60", for: .normal)
            upgradeButton.backgroundColor = .systemBlue
            upgradeButton.isEnabled = true
        }
    }
}
