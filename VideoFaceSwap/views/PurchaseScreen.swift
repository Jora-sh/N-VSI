//
//  PurchaseScreen.swift
//  VideoFaceSwap
//
//  Created by Javad on 11/10/24.
//

import StoreKit
import SwiftUI
import AVFoundation
import _AVKit_SwiftUI
import FirebaseAnalytics

struct PurchaseScreen: View {
    
    
    @EnvironmentObject var mainViewModel: MainViewModel
    @EnvironmentObject private var purchaseManager: PurchaseManager
    @EnvironmentObject private var entitlementManager: EntitlementManager
    @EnvironmentObject private var subscriptionsManager: SubSubscriptionsManager
    
    
    @State var selectedItemIndex : Product? = nil
    
    @State var isLoading: Bool = false
    @State var showSuccessMessage : Bool = false
    @State var showRestoreDialog : Bool = false
    @State var restoreMessage: Bool = false
    
    
    var header: some View {
        HStack(spacing: 8) {
            
            Button {
                withAnimation {
                    mainViewModel.SCREEN_VIEW = mainViewModel.purchaseBackstack ?? .Main
                }
            } label: {
                Image(.iconBack)
                    .resizable()
                    .frame(width: 24, height: 24)
                    .padding(12)
            }
            
            Spacer()
            
        }
        .padding(.trailing, 12)
        .frame(height: 58)
    }
    
    var bottomButtons : some View {
        VStack {
            HStack {
                
                Link(destination: URL(string: privacyPolicyLink)!) {
                    Text("Privacy Policy")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color.white.opacity(0.7))
                }
                
                Spacer()
                
                Link(destination: URL(string: termsOfServiceLink)!) {
                    Text("Terms of Use")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color.white.opacity(0.7))
                }
            }
            .overlay(content: {
                Button {
                    // restore purchases from store
                    Task {
                        isLoading = true
                        await subscriptionsManager.loadProducts()
                        await subscriptionsManager.updatePurchasedProducts { bool in
                            
                            self.restoreMessage = bool
                            self.showRestoreDialog = true
                        }
                        isLoading = false
                    }
                } label: {
                    Text("Restore")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color.white.opacity(0.7))
                }
                .opacity(mainViewModel.tabIndex == 1 ? 1.0 : 0.0)

            })
            .padding(.horizontal, 24)
            
            Spacer()
                .frame(height: 16)
        }
    }
    
    var subscriptionItemView : some View {
        HStack(spacing: 24) {
            ForEach(subscriptionsManager.products, id: \.id) { purchaseItem in
                
                Button {
                    isLoading = true
                    Task {
                        await subscriptionsManager.processUnfinishedTransactions()
                        await subscriptionsManager.buyProduct(purchaseItem) {it1,it2,it3,it4,it5,it6,it7 in
                            mainViewModel.verifyReceipt(parameters: [
                                "productId": it1,
                                "signedTransaction": it7
                            ]) {
                                isLoading = false
                                self.showSuccessMessage = true
                            }
                           
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 7) {
                            isLoading = false
                        }
                        
                    }
                } label: {
                    ZStack {
                        
                        Color(hex: "#1B1B1E")
                        
                        VStack(spacing: 11) {
                            
                            Spacer()
                            
                            Text(getTitleById(id: purchaseItem.id))
                                .foregroundStyle(Color.white)
                                .font(.system(size: 26, weight: .semibold))
                            
                            Text(purchaseItem.id.contains("weekly") ? "\(mainViewModel.weeklyCredits) Credits / Week" : "\(mainViewModel.yearlyCredits) Credits / Year")
                                .foregroundStyle(.white)
                                .font(.system(size: 14,weight: .semibold))
                            
                            Spacer()
                            
                            Text("\(purchaseItem.displayPrice)")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(.white)
                                .padding(.vertical, 4)
                                .frame(width: (UIScreen.screenWidth - 56)/2, height: 40)
                                .background {
                                    Rectangle()
                                        .foregroundStyle(Color.init(hex: "#2E2E2E"))
                                }
                        }
                        .padding(.top, 10)
                        .padding(.horizontal, 20)
                        
                    }
                    .frame(width: (UIScreen.screenWidth - 56)/2, height: 200)
                    .overlay(alignment: .top) {
                        Text("Save 80%")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.white)
                            .padding(.vertical, 4)
                            .frame(width: (UIScreen.screenWidth - 56)/2)
                            .background {
                                LinearGradient(colors: gradientColors, startPoint: .bottomTrailing, endPoint: .topLeading)
                            }
                            .opacity(purchaseItem.id.contains("weekly") ? 0.0 : 1.0)
                    }
                    .roundedCornerWithBorder(lineWidth: 2,
                                             borderColor: gradientColors[0],
                                             radius: 16,
                                             corners: .allCorners)
                }

            }
        }
    }
    
    var tabSelectorView : some View {
        HStack {
            
            Button {
                withAnimation {
                    mainViewModel.tabIndex = 0
                }
            } label: {
                Text("Credit")
                    .font(.system(size: 14, weight: mainViewModel.tabIndex == 0 ? .semibold : .regular))
                    .foregroundStyle(.white)
                    .frame(width: (UIScreen.screenWidth - 100)/2, height: 36)
                    .background {
                        if mainViewModel.tabIndex == 0 {
                            GradientColor()
                        }
                    }
            }
            
            Spacer()
                .frame(width: 16)

            Button {
                withAnimation {
                    mainViewModel.tabIndex = 1
                }
            } label: {
                Text("Subscription")
                    .font(.system(size: 14, weight: mainViewModel.tabIndex == 1 ? .semibold : .regular))
                    .foregroundStyle(.white)
                    .frame(width: (UIScreen.screenWidth - 100)/2, height: 36)
                    .background {
                        if mainViewModel.tabIndex == 1 {
                            GradientColor()
                        }
                    }
            }
            
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 10)
        .background {
            Color.white.opacity(0.08)
                .roundedBorder(Color.white.opacity(0.3), width: 1, cornerRadius: 100)
        }
    }
    
    var purchaseItemView : some View {
        VStack(spacing: 8) {
            ForEach(purchaseManager.products.reversed(), id: \.id) { purchaseItem in
                
                Button {
    //                selectedItemIndex = purchaseItem
                    isLoading = true
                    Task {
                        await purchaseManager.processUnfinishedTransactions()
                        await purchaseManager.buyProduct(purchaseItem) {it1,it2,it3,it4,it5,it6 in
                            mainViewModel.verifyReceipt(parameters: [
                                "productId": it1,
                                "signedTransaction": it6
                            ]) {
                                isLoading = false
                                self.showSuccessMessage = true
                            }
                           
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                            isLoading = false
                        }
                    }
                } label: {
                    ZStack {
                        
                        Color.white.opacity(0.08)
                        
                        HStack {
                            
                            Image(.iconCoin1)
                                .resizable()
                                .frame(width: 34, height: 34)
                            
                            Spacer()
                                .frame(width: 16)
                            
                            Group {
                                
                                Text(getProductNumberFromId(id: purchaseItem.id))
                                    .foregroundStyle(Color.white)
                                
                                
                            }.font(.system(size: 16, weight: .semibold))
                            
                            Spacer()
                            
                            Text("\(purchaseItem.displayPrice)")
                                .font(.system(size: 16))
                                .foregroundStyle(.white)
                                .bold()
                        }
                        .padding(.vertical, 13)
                        .padding(.horizontal, 13)
                        
                        
                    }
                    .frame(width: UIScreen.screenWidth - 32, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .roundedCornerWithBorder(lineWidth: 1, borderColor: Color.white.opacity(0.15), radius: 8, corners: .allCorners)
                }

            }
        }
    }
    
    var purchaseTextCenter : some View {
        VStack {
            
            Text("Get Full Access")
                .font(.system(size: 28, weight: .heavy))
                .foregroundStyle(.white)
            
            Spacer()
                .frame(height: 16)
            
            Text("Unlock All Features, Pro model access")
                .font(.system(size: 14, weight: .regular))
                .foregroundStyle(.white)
        }
    }

    
    var body: some View {
        ZStack(alignment: .top) {
            
            Color.init(hex: "#1B1B1E")
                .ignoresSafeArea()
            
            PurchaseVideoView()
                .task {
                    if mainViewModel.userModel?.totalCredits ?? 0 > 0 && mainViewModel.userModel?.hasActiveSubscription == false {
                        mainViewModel.tabIndex = 1
                    } else if mainViewModel.userModel?.totalCredits ?? 0 <= 0 && mainViewModel.userModel?.hasActiveSubscription == true {
                        mainViewModel.tabIndex = 0
                    } else {
                        mainViewModel.tabIndex = 0
                    }
                    isLoading = true
                    print("in purchase")
                    await purchaseManager.processUnfinishedTransactions()
                    await subscriptionsManager.processUnfinishedTransactions()
                    await subscriptionsManager.updatePurchasedProducts()
                    await subscriptionsManager.loadProducts()
                    if !subscriptionsManager.products.isEmpty {
                        selectedItemIndex = subscriptionsManager.products[0]
                    }
                    await purchaseManager.loadProducts()
                    isLoading = false
                    
                }
            
            VStack {
                
                Spacer()
                    .frame(height: 0)
                
                header
                
                Spacer()
                
                purchaseTextCenter
                
                Spacer()
                    .frame(height: 32)
                
                tabSelectorView
                
                Spacer()
                    .frame(height: 24)
                
                TabView(selection: $mainViewModel.tabIndex) {
                    
                    purchaseItemView
                        .tag(0)
                    
                    subscriptionItemView
                        .tag(1)
                    
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(height: 220)
                .animation(.easeInOut, value: mainViewModel.tabIndex)
                
                Spacer()
                    .frame(height: 24)

                Text("Auto-renewal. Cancel at anytime.")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.white.opacity(0.7))
                    .opacity(mainViewModel.tabIndex == 1 ? 1.0 : 0.0)
                
                Spacer()
                    .frame(height: 16)
                
                bottomButtons
            }
            
//            Color.white
//                .ignoresSafeArea()
//                .onTapGesture {
//                    
//                }
//                .overlay {
//                    ProgressView()
//                }
//                .opacity(isLoading ? 0.6 : 0.0)
            
        }
        .alert("Success!", isPresented: $showSuccessMessage) {
            Button("Enjoy") {
                withAnimation {
                    mainViewModel.SCREEN_VIEW = mainViewModel.purchaseBackstack ?? .Main
                }
                mainViewModel.purchaseBackstack = nil
            }
        } message: {
            Text(mainViewModel.tabIndex == 0 ? "Credits have been added to your account successfully." : "Subscription has been activated successfully. ")
        }
        .alert(restoreMessage ? "Success!" : "No Subscription", isPresented: $showRestoreDialog) {
            Button("ok") {
                if restoreMessage {
                    withAnimation {
                        mainViewModel.SCREEN_VIEW = mainViewModel.purchaseBackstack ?? .Main
                    }
                } else {
                    
                }
            }
        } message: {
            Text(restoreMessage ? "You have been successfully resotred! Enjoy.." : "No Active subscription available for you.")
        }
    }
    
    
    func getTitleById(id:String) -> String {
        switch id {
            case "yearly_videoswap": return "1 Year"
            case "weekly_videoswap": return "1 Week"
            default : return "1 Week"
        }
    }
    
    func getPricePerWeek(product: Product) -> String {
        
        let ppweek = product.price/52
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = product.priceFormatStyle.currencyCode
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2

        let strPrice = formatter.string(from: NSDecimalNumber(decimal: ppweek)) ?? "\(ppweek)"
        
        return strPrice
    }
    
    func getProductNumberFromId(id:String) -> String {
        switch id {
        case "starter_videoswap_credits": return "\(mainViewModel.homeConfig?.homeConfig?.creditSettings?.starterCredits ?? 30) Credit"
            case "pro_videoswap_credits": return "\(mainViewModel.homeConfig?.homeConfig?.creditSettings?.proCredits ?? 100) Credit"
            case "offer_videoswap_credits": return "\(mainViewModel.homeConfig?.homeConfig?.creditSettings?.offerCredits ?? 500) Credit"
            default : return "75"
        }
    }
    
    func getHeaderTitleById(id:String) -> String {
        switch id {
            case "starter_videoswap_credits": return "Starter Plan"
            case "pro_videoswap_credits": return "Pro Plan"
            case "offer_videoswap_credits": return "Ultimate Plan"
            default : return "Pro Plan"
        }
    }
}


@MainActor
class PurchaseManager: NSObject, ObservableObject {
    let productIDs: [String] = [
        "starter_videoswap_credits",
        "pro_videoswap_credits",
        "offer_videoswap_credits"
    ]
    var purchasedProductIDs: Set<String> = []

    @Published var products: [Product] = []
    
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
            for await result in Transaction.updates {
                if case .verified(let transaction) = result {
                    await transaction.finish()
                }
                await self.updatePurchasedProducts()
            }
        }
    }
}

// MARK: StoreKit2 API
extension PurchaseManager {
    func loadProducts() async {
        do {
            self.products = try await Product.products(for: productIDs)
                .sorted(by: { $0.price > $1.price })
            print(self.products)
            print(self.productIDs)
        } catch {
            print("Failed to fetch products!")
        }
    }
    
    func buyProduct(_ product: Product, didBuy : @escaping (String, String,Int,String,String,String) -> Void) async {
        do {
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
                    break
                }
                // Successful purhcase
                print("success")
                await transaction.finish()
                await self.updatePurchasedProducts()
                print("\(transaction)")

                // Firebase Analytics purchase event (imported into Google Ads for conversion tracking).
                Analytics.logEvent(AnalyticsEventPurchase, parameters: [
                    AnalyticsParameterValue: NSDecimalNumber(decimal: product.price).doubleValue,
                    AnalyticsParameterCurrency: product.priceFormatStyle.currencyCode,
                    AnalyticsParameterItemID: product.id,
                    AnalyticsParameterTransactionID: String(transaction.id),
                    AnalyticsParameterQuantity: transaction.purchasedQuantity
                ])
                didBuy(transaction.productID,
                       transaction.appBundleID,
                       transaction.purchasedQuantity,
                       transaction.environment.rawValue,
                       String(transaction.id),
                       verification.jwsRepresentation)
                //send to ali sadeghi boos kardani
            case .pending:
                // Transaction waiting on SCA (Strong Customer Authentication) or
                // approval from Ask to Buy
                break
            case .userCancelled:
                print("User cancelled!")
//                Analytics.logEvent("User_cancel", parameters: ["product" : product])
                break
            @unknown default:
                print("Failed to purchase the product!")
//                Analytics.logEvent("Failed_purchase", parameters: ["product" : product])
                break
            }
        } catch {
            print("Failed to purchase the product!")
//            Analytics.logEvent("Failed_purchase_catch", parameters: ["product" : product])
        }
    }
    
    func updatePurchasedProducts() async {
//        for await result in Transaction.currentEntitlements {
//            guard case .verified(let transaction) = result else {
//                continue
//            }
//            if transaction.revocationDate == nil {
//                self.purchasedProductIDs.insert(transaction.productID)
//            } else {
//                self.purchasedProductIDs.remove(transaction.productID)
//            }
//        }
//
//        self.entitlementManager?.hasPro = !self.purchasedProductIDs.isEmpty
    }
    
    func restorePurchases() async {
        do {
            try await AppStore.sync()
        } catch {
            print(error)
        }
    }
    
    // Clears any consumable transactions that were never finished in previous app versions.
    // Without this, StoreKit blocks re-purchase of the same consumable product.
    func processUnfinishedTransactions() async {
        for await result in Transaction.unfinished {
            if case .verified(let transaction) = result {
                await transaction.finish()
            }
        }
    }
    
    
}

extension PurchaseManager: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, shouldAddStorePayment payment: SKPayment, for product: SKProduct) -> Bool {
        return true
    }
}

@MainActor
class SubSubscriptionsManager: NSObject, ObservableObject {
    let productIDs: [String] = [
        "yearly_videoswap",
        "weekly_videoswap"
    ]
    var purchasedProductIDs: Set<String> = []

    @Published var products: [Product] = []
    
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
            for await result in Transaction.updates {
                if case .verified(let transaction) = result {
                    await transaction.finish()
                }
                await self.updatePurchasedProducts()
            }
        }
    }
    
    // Clears any consumable transactions that were never finished in previous app versions.
    // Without this, StoreKit blocks re-purchase of the same consumable product.
    func processUnfinishedTransactions() async {
        for await result in Transaction.unfinished {
            if case .verified(let transaction) = result {
                await transaction.finish()
            }
        }
    }
}

// MARK: StoreKit2 API
extension SubSubscriptionsManager {
    func loadProducts() async {
        do {
            self.products = try await Product.products(for: productIDs)
                .sorted(by: { $0.price > $1.price })
            print(self.products)
            print(self.productIDs)
        } catch {
            print("Failed to fetch products!")
        }
    }
    
    func buyProduct(_ product: Product, didBuy: @escaping (String, String, Int, String, String, String, String) -> Void) async {
        do {
            let token = UserSettings.getAppAccountToken()
            let options = Product.PurchaseOption.appAccountToken(token)
            let result = try await product.purchase(options: [options])

            switch result {
            case let .success(verification):
                guard case let .verified(transaction) = verification else {
                    if case let .unverified(_, error) = verification {
                        print("⚠️ Purchase unverified: \(error)")
                    }
                    break
                }
                print("✅ Purchase successful and verified.")

                await transaction.finish()

                // Firebase Analytics events (imported into Google Ads for conversion tracking).
                // A subscription is logged both as a `subscribe` conversion and a standard `purchase`.
                let subscribeParams: [String: Any] = [
                    AnalyticsParameterValue: NSDecimalNumber(decimal: product.price).doubleValue,
                    AnalyticsParameterCurrency: product.priceFormatStyle.currencyCode,
                    AnalyticsParameterItemID: product.id,
                    AnalyticsParameterTransactionID: String(transaction.id)
                ]
                Analytics.logEvent("subscribe", parameters: subscribeParams)
                Analytics.logEvent(AnalyticsEventPurchase, parameters: subscribeParams)

                // Attempt to load receipt
//                var receiptString: String = "Unavailable"
//                if let receiptURL = Bundle.main.appStoreReceiptURL,
//                   let receiptData = try? Data(contentsOf: receiptURL) {
//                    receiptString = receiptData.base64EncodedString()
//                    print("📄 Receipt retrieved.")
//                } else {
//                    print("⚠️ Receipt not found. Attempting refresh...")
//
//                    let receiptRefreshed = await refreshReceipt()
//                    if let refreshedReceipt = receiptRefreshed {
//                        receiptString = refreshedReceipt
//                        print("📄 Receipt successfully refreshed.")
//                    } else {
//                        print("❌ Failed to refresh receipt.")
//                    }
//                }

                // Call didBuy callback with transaction data and receipt
                let transactionInfo = """
                transaction ->
                appBundleId: \(transaction.appBundleID),
                appAccountToken: \(transaction.appAccountToken ?? UUID()),
                deviceVerification: \(transaction.deviceVerification),
                deviceVerificationNonce: \(transaction.deviceVerificationNonce),
                originalPurchaseDate: \(transaction.originalPurchaseDate),
                revocationDate: \(transaction.revocationDate?.description ?? "nil"),
                offerID: \(transaction.offerID ?? "nil"),
                ownershipType: \(transaction.ownershipType),
                revocationReason: \(transaction.revocationReason?.rawValue ?? -1),
                subscriptionStatus: \(await transaction.subscriptionStatus),
                receipt: [truncated]
                """

                didBuy(
                    transaction.productID,
                    transaction.appBundleID,
                    transaction.purchasedQuantity,
                    transaction.environment.rawValue,
                    String(transaction.id),
                    transactionInfo,
                    verification.jwsRepresentation
                )

            case .pending:
                print("⏳ Purchase pending (SCA or Ask to Buy).")
            case .userCancelled:
                print("❌ User cancelled purchase.")
            @unknown default:
                print("❌ Unknown purchase result.")
            }
        } catch {
            print("❌ Error during purchase: \(error)")
        }
    }

    // MARK: - Receipt Refresh Helper

    func refreshReceipt() async -> String? {
        return await withCheckedContinuation { continuation in
            let request = SKReceiptRefreshRequest()
            let delegate = ReceiptRefreshHandler { receiptString in
                continuation.resume(returning: receiptString)
            }
            request.delegate = delegate
            request.start()
        }
    }

    class ReceiptRefreshHandler: NSObject, SKRequestDelegate {
        private let completion: (String?) -> Void

        init(completion: @escaping (String?) -> Void) {
            self.completion = completion
        }

        func requestDidFinish(_ request: SKRequest) {
            if let receiptURL = Bundle.main.appStoreReceiptURL,
               let receiptData = try? Data(contentsOf: receiptURL) {
                let receiptString = receiptData.base64EncodedString()
                completion(receiptString)
            } else {
                completion(nil)
            }
        }

        func request(_ request: SKRequest, didFailWithError error: Error) {
            print("❌ Receipt refresh failed: \(error)")
            completion(nil)
        }
    }

    
    func updatePurchasedProducts(onRestoreFinish : @escaping (Bool) -> Void = {_ in }) async {
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
        if self.entitlementManager?.hasPro == true {
            onRestoreFinish(true)
        } else {
            onRestoreFinish(false)
        }
    }
    
    func restorePurchases(onSuccess : @escaping (Bool) -> Void) async {
        do {
            try await AppStore.sync()
            await updatePurchasedProducts { b in
                onSuccess(b)
            }
        } catch {
            print(error)
        }
    }
    
    
}

extension SubSubscriptionsManager: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, shouldAddStorePayment payment: SKPayment, for product: SKProduct) -> Bool {
        return true
    }

    
}


class EntitlementManager: ObservableObject {
    static let userDefaults = UserDefaults.standard
    
    @AppStorage("hasPro", store: userDefaults)
    var hasPro: Bool = false
}


struct PurchaseVideoView: View {
    @State private var player: AVPlayer? = nil
    @State private var loopObserver: Any? = nil

    var body: some View {
        ZStack {
            if let player = player {
                VideoPlayer(player: player)
                    .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width)
                    .overlay(alignment: .bottom) {
                        LinearGradient(colors: [
                            Color.init(hex: "#1B1B1E"),
                            .black.opacity(0.0)],
                        startPoint: .bottom,
                        endPoint: .center)
                    }
                    .onAppear {
                        player.play()
                    }
                    .onDisappear {
                        player.pause()
                    }
                    .ignoresSafeArea()
            } else {
                Color.black
                    .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width)
            }
        }
        .onAppear {
            // load and configure player once
            guard player == nil,
                  let path = Bundle.main.path(forResource: "vsi_purchase_vid", ofType: "mp4")
            else {
                if player != nil { player?.play() }
                return
            }

            let url = URL(fileURLWithPath: path)
            let avPlayer = AVPlayer(url: url)
            avPlayer.isMuted = true
            avPlayer.actionAtItemEnd = .none

            // Keep a reference to the observer token so we can remove it later.
            loopObserver = NotificationCenter.default.addObserver(
                forName: .AVPlayerItemDidPlayToEndTime,
                object: avPlayer.currentItem,
                queue: .main
            ) { _ in
                avPlayer.seek(to: .zero)
                avPlayer.play()
            }

            player = avPlayer
            avPlayer.play()
        }
        .onDisappear {
            // Remove the NotificationCenter observer using the token
            if let obs = loopObserver {
                NotificationCenter.default.removeObserver(obs)
                loopObserver = nil
            }

            // Pause and discard player if desired
            player?.pause()
            // keep or nil out depending on lifecycle you want:
            // player = nil
        }
    }
}

struct GradientColor: View {
    
    var body: some View {
        Rectangle()
            .overlay {
                AppLinearGradient()
            }
            .clipShape(Capsule())
    }
    
}

let gradientColors = [
    Color(hex: "#3ECCF8"),
    Color(hex: "#34A5F2")
]

struct AppLinearGradient: View {
    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: gradientColors),
            startPoint: .bottomLeading,
            endPoint: .topTrailing
        )
    }
}


extension View {
    /// Applies a rounded border with given color, width, and corner radius.
    func roundedBorder(_ color: Color, width: CGFloat = 1, cornerRadius: CGFloat) -> some View {
        self
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(color, lineWidth: width)
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }
}
