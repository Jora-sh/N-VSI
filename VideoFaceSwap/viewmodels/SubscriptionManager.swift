//
//  SubscriptionManager.swift
//  VideoFaceSwap
//
//  Created by Javad on 11/10/24.
//

import StoreKit
import FirebaseAnalytics

@MainActor
class SubscriptionsManager: NSObject, ObservableObject {
    let productIDs: [String] = [
        "30_video_credits",
        "200_video_credits",
        "offer_faceswap_video"
    ]
    var purchasedProductIDs: Set<String> = []

    @Published var products: [Product] = []
    @Published var isLoading: Bool = false
    @Published var showSuccess: Bool = false
    
    private var entitlementManager: EntitlementManager? = nil
    private var updates: Task<Void, Never>? = nil
    
    init(entitlementManager: EntitlementManager) {
        self.entitlementManager = entitlementManager
        super.init()
        self.updates = observeTransactionUpdates()
        SKPaymentQueue.default().add(self)
    }
    
    deinit {
        updates?.cancel()
    }
    
    func observeTransactionUpdates() -> Task<Void, Never> {
        Task(priority: .background) { [unowned self] in
            for await _ in Transaction.updates {
                await self.updatePurchasedProducts()
            }
        }
    }
}

// MARK: StoreKit2 API
extension SubscriptionsManager {
    func loadProducts() async {
        do {
            self.products = try await Product.products(for: productIDs)
                .sorted(by: { $0.price < $1.price })
            print(self.products)
        } catch {
            print("Failed to fetch products!")
        }
    }
    
    func buyProduct(_ product: Product, didBuy : @escaping (String, String,Int,String,String) -> Void) async {
        do {
            
            isLoading = true
            let token = UserSettings.getAppAccountToken()
            let options = Product.PurchaseOption.appAccountToken(token)
            let result = try await product.purchase(options: [options])
            
            switch result {
            case let .success(.verified(transaction)):
                // Successful purhcase
                await transaction.finish()
                await self.updatePurchasedProducts()
                print("\(transaction)")
                didBuy(transaction.productID,
                       transaction.appBundleID,
                       transaction.purchasedQuantity,
                       transaction.environment.rawValue,
                       String(transaction.id))
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    self.isLoading = false
                    self.showSuccess = true
                }
                //send to ali sadeghi boos kardani
            case let .success(.unverified(_, error)):
                // Successful purchase but transaction/receipt can't be verified
                // Could be a jailbroken phone
                print("Unverified purchase. Might be jailbroken. Error: \(error)")
                isLoading = false
                break
            case .pending:
                // Transaction waiting on SCA (Strong Customer Authentication) or
                // approval from Ask to Buy
                isLoading = false
                break
            case .userCancelled:
                print("User cancelled!")
                Analytics.logEvent("User_cancel", parameters: ["product" : product])
                isLoading = false
                break
            @unknown default:
                print("Failed to purchase the product!")
                Analytics.logEvent("Failed_purchase", parameters: ["product" : product])
                isLoading = false
                break
            }
        } catch {
            print("Failed to purchase the product!")
            Analytics.logEvent("Failed_purchase_catch", parameters: ["product" : product])
            isLoading = false
        }
    }
    
    func updatePurchasedProducts() async {
        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else {
                continue
            }
            if transaction.revocationDate == nil {
                self.purchasedProductIDs.insert(transaction.productID)
            } else {
                self.purchasedProductIDs.remove(transaction.productID)
            }
        }
        
        self.entitlementManager?.hasPro = !self.purchasedProductIDs.isEmpty
    }
    
    func restorePurchases() async {
        do {
            try await AppStore.sync()
        } catch {
            print(error)
        }
    }
}

extension SubscriptionsManager: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, shouldAddStorePayment payment: SKPayment, for product: SKProduct) -> Bool {
        return true
    }
}

import SwiftUI

class EntitlementManager: ObservableObject {
    static let userDefaults = UserDefaults.standard
    
    @AppStorage("hasPro", store: userDefaults)
    var hasPro: Bool = false
}
