//
//  UserDefaultsManager.swift
//  RandoFun
//
//  Created by Tim Tseng on 2025/6/13.
//

import Foundation

final class UserDefaultsManager {
    static let shared = UserDefaultsManager()
    private let defaults = UserDefaults.standard

    private init() {}

    private enum Keys {
        static let spinnerOptions = "SpinnerOptions"
        static let selectedCoinStyle = "SelectedCoinStyle"
        static let maxWinnersKey = "fingerGame_maxWinners"
        static let orbitDurationKey = "fingerGame_orbitDuration"

        static let coinUsage = "coinFlipUsageCount"
        static let fingerUsage = "fingerGameUsageCount"
        static let spinnerUsage = "spinnerGameUsageCount"
    }

    // MARK: - Spinner
    func getSpinnerOptions() -> [SpinnerOption]? {
        guard let data = defaults.data(forKey: Keys.spinnerOptions),
              let stored = try? JSONDecoder().decode([SpinnerOptionStorage].self, from: data) else {
            return nil
        }

        let valid = stored.filter { !$0.title.trimmingCharacters(in: .whitespaces).isEmpty }
        let total = valid.compactMap { $0.weight }.reduce(0, +)

        return valid.map { item in
            let w = CGFloat(item.weight ?? 0)
            let ratio = (total > 0 && item.weight != nil) ? (w / CGFloat(total)) : (1.0 / CGFloat(valid.count))
            return SpinnerOption(title: item.title, weight: ratio)
        }
    }

    func saveSpinnerOptions(_ options: [SpinnerOption]) {
        let totalWeight = options.map { Int($0.weight * 1000) }
        let storage = zip(options, totalWeight).map { SpinnerOptionStorage(title: $0.0.title, weight: $0.1) }
        if let data = try? JSONEncoder().encode(storage) {
            defaults.set(data, forKey: Keys.spinnerOptions)
        }
    }

    // MARK: - Coin
    func getSelectedCoinStyle() -> String? {
        return defaults.string(forKey: Keys.selectedCoinStyle)
    }

    func saveSelectedCoinStyle(_ style: String) {
        defaults.set(style, forKey: Keys.selectedCoinStyle)
    }

    // MARK: - Finger
    func getMaxWinners() -> Int {
        return defaults.integer(forKey: Keys.maxWinnersKey)
    }

    func saveMaxWinners(_ max: Int) {
        defaults.set(max, forKey: Keys.maxWinnersKey)
    }

    func getOrbitDuration() -> Double {
        return defaults.double(forKey: Keys.orbitDurationKey)
    }

    func saveOrbitDuration(_ orbitDuration: Double) {
        defaults.set(orbitDuration, forKey: Keys.orbitDurationKey)
    }

    // MARK: - Usage Limit Control
    enum GameType {
        case coin, finger, spinner

        var key: String {
            switch self {
            case .coin: return Keys.coinUsage
            case .finger: return Keys.fingerUsage
            case .spinner: return Keys.spinnerUsage
            }
        }
    }

    func getUsageCount(for type: GameType) -> Int {
        return defaults.integer(forKey: type.key)
    }

    func incrementUsage(for type: GameType) {
        let count = getUsageCount(for: type)
        defaults.set(count + 1, forKey: type.key)
    }

    func resetUsage(for type: GameType) {
        defaults.set(0, forKey: type.key)
    }

    @MainActor func isLimitReached(for type: GameType, limit: Int = 10) -> Bool {
        guard !InAppPurchaseManager.shared.isPurchased else { return false }
        return getUsageCount(for: type) >= limit
    }
}
