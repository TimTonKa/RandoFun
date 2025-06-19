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
    }

        
    func getSpinnerOptions() -> [SpinnerOption]? {
        guard let data = defaults.data(forKey: Keys.spinnerOptions),
              let stored = try? JSONDecoder().decode([SpinnerOptionStorage].self, from: data) else {
            return nil // fallback to default
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
    
    func getSelectedCoinStyle() -> String? {
        guard let style = defaults.string(forKey: Keys.selectedCoinStyle) else {
            return nil
        }
        return style
    }
    
    func saveSelectedCoinStyle(_ style: String) {
        defaults.set(style, forKey: Keys.selectedCoinStyle)
    }
    
    func getMaxWinners() -> Int {
        let maxWinner = defaults.integer(forKey: Keys.maxWinnersKey)
        return maxWinner
    }
    
    func saveMaxWinners(_ max: Int) {
        defaults.set(max, forKey: Keys.maxWinnersKey)
    }
    
    func getOrbitDuration() -> Double {
        let orbitDuration = defaults.double(forKey: Keys.orbitDurationKey)
        return orbitDuration
    }
    
    func saveOrbitDuration(_ orbitDuration: Double) {
        defaults.set(orbitDuration, forKey: Keys.orbitDurationKey)
    }
}
