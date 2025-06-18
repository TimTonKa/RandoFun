//
//  SpinnerOptionCell.swift
//  RandoFun
//
//  Created by Tim Tseng on 2025/6/13.
//

import UIKit

class SpinnerOptionCell: UITableViewCell {

    var onDeleteTapped: (() -> Void)?
    var onWeightChanged: ((Int?) -> Void)?
    var onTitleChanged: ((String) -> Void)?

    private let titleField = UITextField()
    private let weightField = UITextField()
    private let percentLabel = UILabel()
    private let deleteButton = UIButton(type: .system)

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none

        titleField.font = .systemFont(ofSize: 16, weight: .medium)
        titleField.placeholder = "標題"
        titleField.addTarget(self, action: #selector(titleChanged), for: .editingChanged)

        weightField.keyboardType = .numberPad
        weightField.textAlignment = .right
        weightField.placeholder = "權重"
        weightField.font = .monospacedDigitSystemFont(ofSize: 14, weight: .regular)
        weightField.addTarget(self, action: #selector(weightChanged), for: .editingChanged)

        percentLabel.font = .systemFont(ofSize: 14, weight: .regular)
        percentLabel.textColor = .secondaryLabel
        percentLabel.textAlignment = .right
        percentLabel.setContentHuggingPriority(.required, for: .horizontal)

        deleteButton.setTitle("-", for: .normal)
        deleteButton.setTitleColor(.systemRed, for: .normal)
        deleteButton.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)

        let hStack = UIStackView(arrangedSubviews: [deleteButton, titleField, weightField, percentLabel])
        hStack.spacing = 8
        hStack.axis = .horizontal
        hStack.alignment = .center
        hStack.distribution = .fill
        contentView.addSubview(hStack)
        hStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            hStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            hStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            hStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])

        deleteButton.widthAnchor.constraint(equalToConstant: 30).isActive = true
        weightField.widthAnchor.constraint(equalToConstant: 50).isActive = true
        percentLabel.widthAnchor.constraint(equalToConstant: 50).isActive = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with setting: SpinnerOptionSetting) {
        titleField.text = setting.title
        weightField.text = setting.weight != nil ? "\(setting.weight!)" : ""
        percentLabel.text = setting.percentText
    }

    @objc private func deleteTapped() {
        onDeleteTapped?()
    }

    @objc private func weightChanged() {
        let text = weightField.text ?? ""
        if let number = Int(text), number >= 1, number <= 999 {
            onWeightChanged?(number)
        } else {
            onWeightChanged?(nil)
        }
    }

    @objc private func titleChanged() {
        onTitleChanged?(titleField.text ?? "")
    }
    
    func becomeFirstResponderIfNeeded() {
        titleField.becomeFirstResponder()
    }
}

// MARK: - PaddingLabel（自訂內距）
class PaddingLabel: UILabel {
    var topInset: CGFloat = 4
    var bottomInset: CGFloat = 4
    var leftInset: CGFloat = 8
    var rightInset: CGFloat = 8

    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
        super.drawText(in: rect.inset(by: insets))
    }

    override var intrinsicContentSize: CGSize {
        let base = super.intrinsicContentSize
        return CGSize(width: base.width + leftInset + rightInset, height: base.height + topInset + bottomInset)
    }
}
