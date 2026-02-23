//
//  PurchaseScreen.swift
//  VideoFaceSwap
//
//  Created by Javad on 11/10/24.
//

import SwiftUI
import StoreKit
import AVFoundation
import _AVKit_SwiftUI

struct OfferPurchaseScreen: View {
    
    @EnvironmentObject var mainViewModel : MainViewModel
    @StateObject private var subscriptionsManager: OfferSubscriptionsManager = OfferSubscriptionsManager()
    
    var links : some View {
        HStack {
            
            Link(destination: URL(string: termsOfServiceLink)!, label: {
                Text("Terms Of Use")
                    .foregroundStyle(.white)
                    .font(.system(size: 12))
                    .underline()
            })
            
            Spacer()
                .frame(width: 36)
            
            Link(destination: URL(string: privacyPolicyLink)!, label: {
                Text("Privacy Policy")
                    .foregroundStyle(.white)
                    .font(.system(size: 12))
                    .underline()
            })
        }
    }
    
    var purchaseItemView : some View {
        Button {
            subscriptionsManager.isLoading = true
            Task {
                if subscriptionsManager.products.count > 0 {
                    await subscriptionsManager.buyProduct(subscriptionsManager.products[0]) {it1,it2,it3,it4,it5 in
                        mainViewModel.sendPurchaseToServer(parameters: [
                           "productId" : it1,
                           "appBundleId" : it2,
                           "purchasedQuantity" : Int(1),
                           "environment" : it4,
                           "id" : it5,
                        ]) {
                            
                        }
                    }
                }
            }
        } label: {
            ZStack {
                
                Color(hex: "#0B1B23").opacity(0.8)
                
                HStack {
                    
                    Group {
                        
                        Text("1000")
                            .foregroundStyle(Color(hex: "#6AA51E"))
                        
                        Text("Video Credits")
                            .foregroundStyle(.white)
                        
                    }.font(.system(size: 18))
                        .bold()
                    
                    Spacer()
                    
                    if subscriptionsManager.products.count > 0 {
                        VStack(alignment: .trailing) {
                            Text("\(subscriptionsManager.crossedPrice)")
                                .font(.system(size: 16))
                                .foregroundStyle(Color.init(hex: "#ADADAD"))
                                .strikethrough()
                                .bold()
                            Text("\(subscriptionsManager.products[0].displayPrice)")
                                .font(.system(size: 18,weight: .semibold))
                                .foregroundStyle(.white)
                                .bold()
                        }
                    }
                }
                .padding(.vertical, 20)
                .padding(.horizontal, 20)
                
            }
            .frame(width: UIScreen.screenWidth - 40, height: 66)
            .roundedCornerWithBorder(lineWidth: 2, borderColor: Color(hex: "#6AA51E"), radius: 8, corners: .allCorners)
        }
    }
    
    var header : some View {
        HStack {
            
            Button(action: {
                //Back to main
                withAnimation {
                    mainViewModel.SCREEN_VIEW = .Main
                }
            }, label: {
                Image(.iconExitWhite)
                    .padding(.horizontal)
            })
            
            Spacer()
            
            
        }.padding(.horizontal, 16)
    }
    
    var body: some View {
        ZStack {
            
            Color(hex: "#1B1B1E")
                .ignoresSafeArea()
            
            VStack {
                
                Image(.imgBlackFridayBackground)
                    .resizable()
                    .scaledToFill()
                    .onDisappear {
                        mainViewModel.getMe { err in
                            
                        }
                    }
                    .frame(width: (UIScreen.screenWidth), height: 490)
                    .task {
                        print("in purchase")
                        await subscriptionsManager.updatePurchasedProducts()
                        await subscriptionsManager.loadProducts()
                    }
                    .ignoresSafeArea()
                
                Spacer()
            }
            .ignoresSafeArea()
            
            
//            Image(.imgPurchase)
//                .resizable()
//                .ignoresSafeArea()
//                .frame(width: UIScreen.screenWidth, height: UIScreen.screenHeight)
//                .task {
//                    print("in purchase")
//                    await subscriptionsManager.updatePurchasedProducts()
//                    await subscriptionsManager.loadProducts()
//                    if !subscriptionsManager.products.isEmpty {
//                        selectedItemIndex = subscriptionsManager.products[0]
//                    }
//                }
            
            VStack {
                
                Spacer()
                    .frame(height: 32)
                
                header
                
                Spacer()
                
                OfferPurchaseTimerView()
                
                Spacer()
                    .frame(height: 24)
                
                HStack {
                    Group {
                        
                        Text("Christmas ")
                            .foregroundStyle(Color(hex: "#C43737"))
                        
                        Text("Exclusive")
                            .foregroundStyle(Color(hex: "#64962A"))
                        
                    }.font(.system(size: 30, weight: .heavy))
                }
                
                Spacer()
                    .frame(height: 24)
                
                purchaseItemView
                
                Spacer()
                    .frame(height: 48)
                
                links
                
                Spacer()
                    .frame(height: 0)
            }
            .alert("Success!", isPresented: $subscriptionsManager.showSuccess) {
                Button("ok") {
                    withAnimation {
                        mainViewModel.SCREEN_VIEW = .Main
                    }
                }
            } message: {
                Text("Credits have been added to your account. Enjoy!")
            }

            
            
            ZStack {
                
                Color.white
                    .ignoresSafeArea()
                
                ProgressView()
            } .opacity(subscriptionsManager.isLoading ? 0.5 : 0.0)
        }
    }
}

struct OfferPurchaseTimerView: View {
    @StateObject private var timerManager = TimerManager()
    
    var body: some View {
        HStack {
            Text("Limited Offer")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Color.white)
            
            Spacer()
            
            Text(timerManager.timeString)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Color.white)
        }
        .padding(.horizontal, 14)
        .frame(width: UIScreen.screenWidth, height: 40)
        .background {
            Image(.imgBackOffer)
                .resizable()
                .frame(width: UIScreen.screenWidth, height: 40)
                .scaledToFit()
                .frame(width: UIScreen.screenWidth, height: 40)
        }
        .frame(width: UIScreen.screenWidth, height: 40)
        .onAppear {
            timerManager.startTimer()
        }
    }
}
