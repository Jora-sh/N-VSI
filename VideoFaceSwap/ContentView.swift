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
                    if !UserSettings.isWatchOnBoarding {
                        mainViewModel.SCREEN_VIEW = .OnBoarding
                    }
                    if UserSettings.username == "" {
                        UserSettings.username = "IOS-\(UUID().uuidString)"
                        
                    }
                    if UserSettings.token == "" {
                        mainViewModel.signupUser { err in }
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
            case .Purchase:
                PurchaseScreen()
            case .Templates:
                TemplateScreen()
            case .Loading:
                LoadingScreen()
            case .Result:
                ResultScreen()
            }
            
        }
    }
}

enum ScreenEnum {
    case OnBoarding
    case Main
    case Settings
    case Purchase
    case Templates
    case Loading
    case Result
}
