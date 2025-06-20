//
//  InAppPurchaseManager.swift
//  RandoFun
//
//  Created by Tim Tseng on 2025/6/19.
//

import StoreKit
import OSLog

@MainActor
class InAppPurchaseManager: ObservableObject {
    static let shared = InAppPurchaseManager()

    private let productID = "com.tim.TimFramework.RandoFun"
    
    private let logger = Logger(subsystem: "", category: String(describing: InAppPurchaseManager.self))
    
    @Published var isPurchased = false
    private var updateListenerTask: Task<Void, Never>? = nil
    
    private init() {
        updateListenerTask = listenForTransactions()
        loadPurchaseStatus()
    }
    
    // MARK: - 後台監聽 App 期間的購買狀態變化
    private func listenForTransactions() -> Task<Void, Never> {
        return Task.detached {
            for await result in Transaction.updates {
                guard case .verified(let transaction) = result else { continue }
                if transaction.productID == self.productID {
                    await MainActor.run {
                        self.isPurchased = true
                    }
                }
            }
        }
    }

    // MARK: - 啟動 App 時讀取已有的購買憑證
    func loadPurchaseStatus() {
        Task {
            for await result in Transaction.currentEntitlements {
                switch result {
                case .verified(let transaction):
                    if transaction.productID == productID {
                        isPurchased = true
                        return
                    }
                default: continue
                }
            }
            isPurchased = false
        }
    }
    
    // MARK: - 還原購買
    func restorePurchase() async {
        do {
            try await AppStore.sync()
            loadPurchaseStatus() // 再次確認購買狀態
        } catch {
            logger.debug("⚠️ Restore failed: \(error)")
        }
    }

    // MARK: - 購買流程
    func purchase() async -> Bool {
        do {
            let products = try await Product.products(for: [productID])
            guard let product = products.first else { return false }

            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                switch verification {
                case .verified:
                    isPurchased = true
                    return true
                default: return false
                }
            default: return false
            }
        } catch {
            logger.debug("Purchase failed: \(error)")
            return false
        }
    }
}
