import Foundation
import StoreKit

@Observable
final class PurchaseManager {
    var products: [Product] = []
    var purchasedProductIDs: Set<String> = []
    var isProUser = false
    var isLoading = true

    private var transactionListener: Task<Void, Never>?
    private let monthlyID = "com.zzoutuo.TripForge.monthly"
    private let yearlyID = "com.zzoutuo.TripForge.yearly"

    init() {
        transactionListener = Task {
            for await result in Transaction.updates {
                if case .verified(let transaction) = result {
                    await updatePurchasedProducts(transaction)
                    await transaction.finish()
                }
            }
        }
        Task {
            do {
                products = try await Product.products(for: [monthlyID, yearlyID])
            } catch {
                print("Failed to load products: \(error)")
            }
            for await result in Transaction.currentEntitlements {
                if case .verified(let transaction) = result {
                    await updatePurchasedProducts(transaction)
                }
            }
            await MainActor.run {
                self.isLoading = false
            }
        }
    }

    deinit {
        transactionListener?.cancel()
    }

    var monthlyProduct: Product? {
        products.first { $0.id == monthlyID }
    }

    var yearlyProduct: Product? {
        products.first { $0.id == yearlyID }
    }

    func purchase(_ product: Product) async throws -> Bool {
        let result = try await product.purchase()
        switch result {
        case .success(let verification):
            if case .verified(let transaction) = verification {
                await updatePurchasedProducts(transaction)
                await transaction.finish()
                return true
            }
        case .userCancelled, .pending:
            return false
        @unknown default:
            return false
        }
        return false
    }

    func restorePurchases() async {
        do {
            try await AppStore.sync()
            for await result in Transaction.currentEntitlements {
                if case .verified(let transaction) = result {
                    await updatePurchasedProducts(transaction)
                }
            }
        } catch {
            print("Failed to restore purchases: \(error)")
        }
    }

    @MainActor
    private func updatePurchasedProducts(_ transaction: Transaction) {
        purchasedProductIDs.insert(transaction.productID)
        isProUser = purchasedProductIDs.contains(monthlyID) || purchasedProductIDs.contains(yearlyID)
    }
}
