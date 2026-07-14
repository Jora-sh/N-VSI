//
//  OfferSubscriptionManager.swift
//  VideoFaceSwap
//
//  Created by Javad on 11/23/25.
//

import StoreKit
import FirebaseAnalytics
import StoreKit

@MainActor
class OfferSubscriptionsManager: NSObject, ObservableObject {
    let productIDs: [String] = [
        "Christmas_yearly"
    ]
    var purchasedProductIDs: Set<String> = []

    @Published var products: [Product] = []
    @Published var crossedPrice: String = ""
    @Published var isLoading: Bool = false
    @Published var showSuccess: Bool = false
    
    private var updates: Task<Void, Never>? = nil
    
    
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
extension OfferSubscriptionsManager {
    func loadProducts() async {
        do {
            self.products = try await Product.products(for: productIDs)
                .sorted(by: { $0.price < $1.price })
            self.crossedPrice = "\(currencySymbol(for: self.products[0].priceFormatStyle.currencyCode))\(String(format: "%.2f", NSDecimalNumber(decimal: self.products[0].price * 1.7).doubleValue))"
            print(self.products)
        } catch {
            print("Failed to fetch products!")
        }
    }
    
    func currencySymbol(for currencyCode: String) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currencyCode
        return formatter.currencySymbol ?? currencyCode
    }
    
    func buyProduct(_ product: Product, didBuy : @escaping (String, String,Int,String,String,String) -> Void) async {
        do {
            
            isLoading = true
            let token = UserSettings.getAppAccountToken()
            let options = Product.PurchaseOption.appAccountToken(token)
            let result = try await product.purchase(options: [options])
            
            switch result {
            case let .success(verification):
                guard case let .verified(transaction) = verification else {
                    // Successful purchase but transaction/receipt can't be verified
                    // Could be a jailbroken phone
                    if case let .unverified(_, error) = verification {
                        print("Unverified purchase. Might be jailbroken. Error: \(error)")
                    }
                    isLoading = false
                    break
                }
                // Successful purhcase
                await transaction.finish()
                await self.updatePurchasedProducts()
                print("\(transaction)")

                // Firebase Analytics events (imported into Google Ads for conversion tracking).
                let offerParams: [String: Any] = [
                    AnalyticsParameterValue: NSDecimalNumber(decimal: product.price).doubleValue,
                    AnalyticsParameterCurrency: product.priceFormatStyle.currencyCode,
                    AnalyticsParameterItemID: product.id,
                    AnalyticsParameterTransactionID: String(transaction.id)
                ]
                Analytics.logEvent("subscribe", parameters: offerParams)
                Analytics.logEvent(AnalyticsEventPurchase, parameters: offerParams)

                didBuy(transaction.productID,
                       transaction.appBundleID,
                       transaction.purchasedQuantity,
                       transaction.environment.rawValue,
                       String(transaction.id),
                       verification.jwsRepresentation)
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    self.isLoading = false
                    self.showSuccess = true
                }
                //send to ali sadeghi boos kardani
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
    }
    
    func restorePurchases() async {
        do {
            try await AppStore.sync()
        } catch {
            print(error)
        }
    }
}

extension OfferSubscriptionsManager: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, shouldAddStorePayment payment: SKPayment, for product: SKProduct) -> Bool {
        return true
    }
}
