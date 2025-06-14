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
}
