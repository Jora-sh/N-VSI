//
//  VideoFaceSwapApp.swift
//  VideoFaceSwap
//
//  Created by Javad on 11/3/24.
//

import SwiftUI


class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {

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
                    }
                }
        }
    }
}
