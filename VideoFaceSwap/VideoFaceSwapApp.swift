//
//  VideoFaceSwapApp.swift
//  VideoFaceSwap
//
//  Created by Javad on 11/3/24.
//

import SwiftUI
import FirebaseCore
import FirebaseAnalytics
import OneSignalFramework
import SDWebImageWebPCoder
import AppTrackingTransparency
import AdSupport

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    Analytics.logEvent("logged_in", parameters: nil)
      
      OneSignal.Debug.setLogLevel(.LL_INFO)
              
    // OneSignal initialization
    OneSignal.initialize("0c0485d0-79a2-472f-afcd-f73ea0e58c0d", withLaunchOptions: launchOptions)
      print(OneSignal.User.externalId)
    

    // requestPermission will show the native iOS notification permission prompt.
    // We recommend removing the following code and instead using an In-App Message to prompt for notification permission
    

    // Login your customer with externalId
    // OneSignal.login("EXTERNAL_ID")
    return true
  }
}


@main
struct VideoFaceSwapApp: App {
    
    init() {
            let webPCoder = SDImageWebPCoder.shared
            SDImageCodersManager.shared.addCoder(webPCoder) //  Enables WebP decoding
        }
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @Environment(\.scenePhase) private var scenePhase

    @StateObject var mainViewModel = MainViewModel()
    @StateObject var swapViewModel = SwapViewModel()
    @StateObject var subsubscriptionManager : SubSubscriptionsManager = SubSubscriptionsManager(entitlementManager: EntitlementManager())
    @StateObject var purchaseManager : PurchaseManager = PurchaseManager(entitlementManager: EntitlementManager())

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(mainViewModel)
                .environmentObject(swapViewModel)
                .environmentObject(subsubscriptionManager)
                .environmentObject(purchaseManager)
                .task {
                    await purchaseManager.processUnfinishedTransactions()
                    await subsubscriptionManager.processUnfinishedTransactions()
                }
                .onChange(of: scenePhase) { newPhase in
                    if newPhase == .active {
                        requestTrackingAuthorization()
                    }
                }
        }
    }

    /// Asks for App Tracking Transparency permission. Must run while the app is
    /// active, so it's triggered on the `.active` scene phase. The system only
    /// shows the prompt once; later calls just return the cached status.
    private func requestTrackingAuthorization() {
        // Small delay so the window is fully active before the prompt is shown.
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//            ATTrackingManager.requestTrackingAuthorization { status in
//                switch status {
//                case .authorized:
//                    print("ATT: authorized, IDFA = \(ASIdentifierManager.shared().advertisingIdentifier)")
//                case .denied:
//                    print("ATT: denied")
//                case .notDetermined:
//                    print("ATT: not determined")
//                case .restricted:
//                    print("ATT: restricted")
//                @unknown default:
//                    print("ATT: unknown")
//                }
//            }
//        }
    }
}
