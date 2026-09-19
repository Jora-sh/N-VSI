//
//  ContentView.swift
//  VideoFaceSwap
//
//  Created by Javad on 11/3/24.
//

import SwiftUI
import OneSignalFramework

struct ContentView: View {
    
    @EnvironmentObject var mainViewModel : MainViewModel
    
    var body: some View {
        ZStack {
            
            BackgroundView()
                .onAppear {
                    if UserSettings.username == "" {
                        UserSettings.username = "IOS-\(UUID().uuidString)"
                        
                    }
                    print(UserSettings.username)
                    
                }
            
            
            switch mainViewModel.SCREEN_VIEW {
            case .OnBoarding:
                OnBoardingScreen()
            case .Main:
                MainScreen()
            case .Settings:
                SettingsScreen()
            case .purchaseOffer:
                OfferPurchaseScreen()
            case .Purchase:
                PurchaseScreen()
            case .Templates:
                TemplateScreen()
            case .Loading:
                LoadingScreen()
            case .Result:
                ResultScreen()
            case .ResultImage:
                ResultImageScreen()
            case .Splash:
                SplashScreen()
            case .PurchaseHistory:
                CreditHistory()
            case .AiNotice:
                AiNoticeScreen()
            }
            
        }
    }
}

enum ScreenEnum {
    case OnBoarding
    case Main
    case Settings
    case PurchaseHistory
    case Purchase
    case purchaseOffer
    case Templates
    case Loading
    case Result
    case ResultImage
    case AiNotice
    case Splash
}
