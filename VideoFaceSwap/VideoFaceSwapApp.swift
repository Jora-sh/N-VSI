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
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @Environment(\.scenePhase) private var scenePhase
    
    @StateObject var mainViewModel = MainViewModel()
    @StateObject var swapViewModel = SwapViewModel()
    @StateObject var subscriptionManager : SubscriptionsManager = SubscriptionsManager(entitlementManager: EntitlementManager())
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(subscriptionManager)
                .environmentObject(mainViewModel)
                .environmentObject(swapViewModel)
                .task(id: scenePhase) {
                    if scenePhase == .active {
                        
                        await subscriptionManager.updatePurchasedProducts()
                        await subscriptionManager.loadProducts()
                    }
                }
        }
    }
}
