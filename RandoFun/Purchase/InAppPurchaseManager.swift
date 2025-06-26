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
        loadPurchaseStatusAsyncSafe()
        
        NotificationCenter.default.addObserver(
            forName: UIApplication.willEnterForegroundNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                await self?.loadPurchaseStatus()
            }
        }
    }
    
    // MARK: - 後台監聽 App 期間的購買狀態變化
    private func listenForTransactions() -> Task<Void, Never> {
        Task.detached(priority: .background) { [weak self] in
            guard let self else { return }
            
            for await result in Transaction.updates {
                guard case .verified(let transaction) = result else { continue }
                
                if transaction.productID == self.productID {
                    await transaction.finish()
                    
                    let isValid = self.isValidEntitlement(with: transaction)
                    
                    await MainActor.run {
                        self.isPurchased = isValid
                        self.logger.debug("✅ Transaction updated. isPurchased: \(self.isPurchased)")
                    }
                }
            }
        }
    }
    
    // MARK: - 啟動 App 時讀取已有的購買憑證
    func loadPurchaseStatusAsyncSafe() {
        Task { @MainActor in
            await loadPurchaseStatus()
        }
    }
    
    @MainActor
    private func loadPurchaseStatus() async {
        var hasValidEntitlement = false

        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result, transaction.productID == productID {
                hasValidEntitlement = isValidEntitlement(with: transaction)
                break
            }
        }

        isPurchased = hasValidEntitlement
        logger.debug("🔄 Current entitlement check. isPurchased: \(self.isPurchased)")
    }
    
    nonisolated private func isValidEntitlement(with transaction: Transaction) -> Bool {
        if let expiry = transaction.expirationDate {
            let valid = expiry > Date()
            logger.debug("🔍 Expiration: \(expiry) > now? \(valid)")
            return valid
        } else {
            return true // 一次性購買或無到期日
        }
    }
    
    // MARK: - 還原購買
    func restorePurchase() async {
        do {
            try await AppStore.sync()
            loadPurchaseStatusAsyncSafe()
            logger.debug("🔁 Restore succeeded.")
        } catch {
            logger.error("⚠️ Restore failed: \(error.localizedDescription)")
        }
    }
    
    // MARK: - 購買
    func purchase() async -> Bool {
        do {
            let products = try await Product.products(for: [productID])
            guard let product = products.first else {
                logger.error("⚠️ Product not found.")
                return false
            }
            
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                switch verification {
                case .verified(let transaction):
                    await transaction.finish()
                    isPurchased = isValidEntitlement(with: transaction)
                    logger.debug("✅ Purchase successful.")
                    return true
                case .unverified:
                    logger.error("❌ Transaction unverified.")
                    return false
                }
            case .userCancelled:
                logger.debug("🛑 Purchase cancelled by user.")
                return false
            default:
                logger.debug("❌ Purchase failed:\(String(describing: result))")
                return false
            }
        } catch {
            logger.error("❌ Purchase error: \(error.localizedDescription)")
            return false
        }
    }
}
