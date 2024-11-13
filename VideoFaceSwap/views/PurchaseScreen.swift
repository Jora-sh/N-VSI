//
//  PurchaseScreen.swift
//  VideoFaceSwap
//
//  Created by Javad on 11/10/24.
//

import SwiftUI
import StoreKit

struct PurchaseScreen: View {
    
    @EnvironmentObject var mainViewModel : MainViewModel
    @EnvironmentObject private var entitlementManager: EntitlementManager
    @EnvironmentObject private var subscriptionsManager: SubscriptionsManager
    
    @State var selectedItemIndex : Product? = nil
    
    @State var isLoading: Bool = false
    
    let texts = [
//        "Instant and unlimited insect identify",
        "Unlock All video templates",
        "High Quality Result",
        "Custom Face Swap Videos",
        "Unlock All video templates",
    ]
    
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
    
    func getProductNumberFromId(id:String) -> String {
        switch id {
            case "prod_1": return "30"
            case "prod_2": return "100"
            case "prod_3": return "200"
            default : return "2000"
        }
    }
    
    var purchaseItemView : some View {
        ForEach(subscriptionsManager.products, id: \.id) { purchaseItem in
            
            Spacer()
                .frame(height: 16)
            
            Button {
                selectedItemIndex = purchaseItem
            } label: {
                ZStack {
                    
                    Color(hex: selectedItemIndex == purchaseItem ? "#1B1B1E" : "#2D2D31" )
                        .opacity(selectedItemIndex == purchaseItem ? 1.0 : 0.8)
                    
                    HStack {
                        
                        Image(selectedItemIndex == purchaseItem ? .iconCheckChecked : .iconCheckUnChecked)
                            .resizable()
                            .frame(width: 24, height: 24)
                        
                        Spacer()
                            .frame(width: 8)
                        
                        Group {
                            
                            Text(getProductNumberFromId(id: purchaseItem.id))
                                .foregroundStyle(Color(hex: "#34A5F2"))
                            
                            Text("Video Credits")
                                .foregroundStyle(.white)
                            
                        }.font(.system(size: 16))
                            .bold()
                        
                        Spacer()
                        
                        Text("\(purchaseItem.displayPrice)")
                            .font(.system(size: 16))
                            .foregroundStyle(.white)
                            .bold()
                    }
                    .padding(.vertical, 20)
                    .padding(.horizontal, 20)
                    
                }
                .frame(width: UIScreen.screenWidth - 32, height: 56)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .roundedCornerWithBorder(lineWidth: 2, borderColor: Color(hex: "#34A5F2"), radius: 8, corners: .allCorners)
            }

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
                Image(.iconExit)
                    .padding(.horizontal)
            })
            
            Spacer()
            
            
        }.padding(.horizontal, 16)
    }
    
    var purchaseButton : some View {
        Button {
            isLoading = true
            Task {
                if let selectedItemIndex = selectedItemIndex {
                    await subscriptionsManager.buyProduct(selectedItemIndex) {it1,it2,it3,it4,it5 in
                        mainViewModel.sendPurchaseToServer(parameters: [
                           "productId" : it1,
                           "appBundleId" : it2,
                           "purchasedQuantity" : Int(1),
                           "environment" : it4,
                           "id" : it5,
                        ])
                    }
                }
                isLoading = false
            }
        } label: {
            HStack{
                Text("Continue")
                    .foregroundColor(.white)
                    .font(.system(size: 20 , weight: .medium))
            }
            .frame(width: UIScreen.screenWidth - 32 , height: 48)
            .background(
                selectedItemIndex != nil ?
                LinearGradient(
                    colors: gradientColor,
                    startPoint: .leading,
                    endPoint: .trailing
                ) : LinearGradient(
                    stops: [
                        Gradient.Stop(color: Color.white.opacity(0.5), location: 0.00),
                    ],
                    startPoint: UnitPoint(x: 0, y: 0.5),
                    endPoint: UnitPoint(x: 1, y: 0.5)
                    )
            )
            .cornerRadius(10)
        }
    }
    
    var purchaseTexts : some View {
        VStack(alignment: .leading) {
            
            ForEach(texts, id: \.self) { item in
                HStack(spacing: 8) {
                    
                    Image(.iconPurchaseCheck)
                    
                    Text(item)
                        .bold()
                        .font(.system(size: 14))
                        .foregroundStyle(.white)
                    
                    Spacer()
                    
                }.padding(.leading, 64)
            }
            
        }
    }
    
    var body: some View {
        ZStack {
            
            Image(.imgPurchase)
                .ignoresSafeArea()
                .task {
                    print("in purchase")
                    await subscriptionsManager.updatePurchasedProducts()
                    await subscriptionsManager.loadProducts()
                    if !subscriptionsManager.products.isEmpty {
                        selectedItemIndex = subscriptionsManager.products[0]
                    }
                }
            
            VStack {
                
                Spacer()
                    .frame(height: 32)
                
                header
                
                Spacer()
                
                HStack {
                    Group {
                        
                        Text("Pro")
                            .foregroundStyle(Color(hex: "#34A5F2"))
                        
                        Text("Features")
                            .foregroundStyle(Color.white)
                        
                    }.font(.system(size: 24, weight: .heavy))
                }
                
                Spacer()
                    .frame(height: 16)
                
                purchaseTexts
                
                Spacer()
                    .frame(height: 24)
                
                purchaseItemView
                
                Spacer()
                    .frame(height: 24)
                
                purchaseButton
                
                Spacer()
                    .frame(height: 24)
                
                links
                
                Spacer()
                    .frame(height: 32)
            }
            
            
            ZStack {
                
                Color.white
                    .ignoresSafeArea()
                
                ProgressView()
            } .opacity(isLoading ? 0.5 : 0.0)
        }
    }
}

