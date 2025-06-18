//
//  SpinnerSettingsViewController.swift
//  RandoFun
//
//  Created by Tim Tseng on 2025/6/12.
//

import UIKit

struct SpinnerOptionSetting {
    var title: String
    var weight: Int? // 1~999，可為 nil 代表未設定
    var percentText: String = "<1%" // 由 SpinnerOption.weight 計算後設定
}

class SpinnerSettingsViewController: UIViewController {
    private var settings: [SpinnerOptionSetting]
    var onSave: (([SpinnerOption]) -> Void)?

    private let tableView = UITableView(frame: .zero, style: .insetGrouped)

    init(options: [SpinnerOption]) {
        // 預設百分比使用 SpinnerOption.weight，預設 weight 為 nil
        self.settings = options.map {
            SpinnerOptionSetting(
                title: $0.title,
                weight: nil,
                percentText: Self.formatPercent($0.weight)
            )
        }
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "選項"
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)

        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "取消", style: .plain, target: self, action: #selector(cancelTapped))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "儲存", style: .done, target: self, action: #selector(saveTapped))

        tableView.register(SpinnerOptionCell.self, forCellReuseIdentifier: "OptionCell")
        tableView.dataSource = self
        tableView.delegate = self

        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }

        let bottomInset = keyboardFrame.height - view.safeAreaInsets.bottom
        tableView.contentInset.bottom = bottomInset
        tableView.verticalScrollIndicatorInsets.bottom = bottomInset
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        tableView.contentInset.bottom = 0
        tableView.verticalScrollIndicatorInsets.bottom = 0
    }

    @objc private func cancelTapped() {
        dismiss(animated: true)
    }

    @objc private func saveTapped() {
        let hasCustom = settings.contains { $0.weight != nil }

        let totalWeight = settings.compactMap { $0.weight }.reduce(0, +)
        let finalWeights: [CGFloat] = settings.map { setting in
            guard hasCustom, let w = setting.weight, totalWeight > 0 else {
                return 1.0 / CGFloat(settings.count)
            }
            return CGFloat(w) / CGFloat(totalWeight)
        }

        let finalOptions = zip(settings, finalWeights).map { setting, weight in
            SpinnerOption(title: setting.title, weight: weight)
        }

        onSave?(finalOptions)
        dismiss(animated: true)
    }

    private static func formatPercent(_ weight: CGFloat) -> String {
        if weight >= 0.99 {
            return ">99%"
        } else if weight < 0.01 {
            return "<1%"
        } else {
            return "\(Int(round(weight * 100)))%"
        }
    }

    private func updatePercentages() {
        let weights = settings.map { $0.weight }
        let customWeights = weights.compactMap { $0 }
        
        if customWeights.isEmpty {
            // 所有都沒輸入 → 平均分配
            let even = 1.0 / Double(settings.count)
            for i in 0..<settings.count {
                settings[i].percentText = Self.formatPercent(CGFloat(even))
            }
        } else {
            let total = customWeights.reduce(0, +)
            for i in 0..<settings.count {
                if let w = settings[i].weight {
                    let percent = Double(w) / Double(total)
                    settings[i].percentText = Self.formatPercent(CGFloat(percent))
                } else {
                    settings[i].percentText = "<1%"
                }
            }
        }
    }
}

extension SpinnerSettingsViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settings.count + 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == settings.count {
            let cell = UITableViewCell()
            cell.textLabel?.text = "+ 添加新選項"
            cell.textLabel?.textColor = .systemBlue
            cell.textLabel?.textAlignment = .center
            return cell
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: "OptionCell", for: indexPath) as! SpinnerOptionCell
        let setting = settings[indexPath.row]
        cell.configure(with: setting)

        cell.onDeleteTapped = { [weak self] in
            self?.settings.remove(at: indexPath.row)
            self?.updatePercentages()
            tableView.reloadData()
        }

        cell.onWeightChanged = { [weak self] newWeight in
            self?.settings[indexPath.row].weight = newWeight
            self?.updatePercentages()
            tableView.reloadData()
        }

        cell.onTitleChanged = { [weak self] newTitle in
            self?.settings[indexPath.row].title = newTitle
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == settings.count {
            settings.append(SpinnerOptionSetting(title: "", weight: nil, percentText: "<1%"))
            let newIndexPath = IndexPath(row: settings.count - 1, section: 0)
            tableView.insertRows(at: [newIndexPath], with: .automatic)

            // 自動捲到新的一行並讓該欄位成為第一回應者（需要配合 SpinnerOptionCell 支援）
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                if let cell = self.tableView.cellForRow(at: newIndexPath) as? SpinnerOptionCell {
                    cell.becomeFirstResponderIfNeeded()
                }
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
