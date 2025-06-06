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

struct PurchaseScreen: View {
    
    @EnvironmentObject var mainViewModel : MainViewModel
    @EnvironmentObject private var entitlementManager: EntitlementManager
    @EnvironmentObject private var subscriptionsManager: SubscriptionsManager
    
    @State var selectedItemIndex : Product? = nil
    
    @State var isLoading: Bool = false
    @State var showSuccessDialog: Bool = false
    @State var player : AVPlayer = AVPlayer(url: URL(string: "http://89.22.239.26/nexora-swap-ios-stage/public/uploads/video_facefusion-20250211154123-3630817-7e464-357966868480.mp4")!)
    
    let texts = [
//        "Instant and unlimited insect identify",
        "Access Exclusive Video Templates",
        "Personalized Face Swap Features",
        "Create Stunning HD Videos",
        "Unlock Premium AI Model",
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
            case "30_video_credits": return "30"
            case "200_video_credits": return "200"
            case "offer_faceswap_video": return "500"
            default : return "500"
        }
    }
    
    var purchaseItemView : some View {
        ForEach(subscriptionsManager.products, id: \.id) { purchaseItem in
            
            if purchaseItem.id == "offer_faceswap_video" {
                Spacer()
                    .frame(height: 16)
                
                Button {
                    selectedItemIndex = purchaseItem
                } label: {
                    ZStack {
                        
                        Color(hex: "#231C0B")
                            .opacity(0.8)
                        
                        HStack {
                            
                            Image(selectedItemIndex == purchaseItem ? .iconCheckCheckedOffer : .iconCheckUnCheckedOffer)
                                
                                .resizable()
                                .frame(width: 24, height: 24)
                            
                            Spacer()
                                .frame(width: 8)
                            
                            Group {
                                
                                Text(getProductNumberFromId(id: purchaseItem.id))
                                    .foregroundStyle(Color(hex: "#FFC700"))
                                
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
                        
                        VStack {
                            HStack {
                                
                                Spacer()
                                
                                Text("Special Offer")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundStyle(.black)
                                    .frame(width: 88, height: 24)
                                    .background(content: {
                                        LinearGradient(colors: [Color(hex: "#FFC700"),Color(hex: "#FDDC00")], startPoint: .leading, endPoint: .trailing)
                                    })
                                    .clipShape(
                                        .rect(
                                            topLeadingRadius: 0,
                                            bottomLeadingRadius: 8,
                                            bottomTrailingRadius: 8,
                                            topTrailingRadius: 0
                                        )
                                    )
                                
                                Spacer()
                                    .frame(width: 70)
                            }
                            
                            Spacer()
                        }
                        
                    }
                    .frame(width: UIScreen.screenWidth - 32, height: 56)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay {
                        ButtonGradient()
                    }
                }
            } else {
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
                        ]) {
                            self.showSuccessDialog = true
                        }
                    }
                }
                isLoading = false
            }
        } label: {
            HStack{
                Text("Continue")
                    .foregroundColor(selectedItemIndex?.id != "offer_faceswap_video" ? .white : .black)
                    .font(.system(size: 20 , weight: .medium))
            }
            .frame(width: UIScreen.screenWidth - 32 , height: 48)
            .background {
                
                if selectedItemIndex?.id != "offer_faceswap_video" {
                    LinearGradient(
                        colors: selectedItemIndex != nil ? gradientColor : [Color.white.opacity(0.5)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                } else {
                    EllipticalGradient(colors:colorGradient,
                                           center: .topLeading,
                                           startRadiusFraction: 0.0,
                                           endRadiusFraction: 1.0)
                }
            }
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
                        .font(.system(size: 13))
                        .foregroundStyle(.white)
                    
                    Spacer()
                    
                }.padding(.leading, 64)
            }
            
        }
    }
    
    var body: some View {
        ZStack {
            
//            VideoView(player: player)
//                .disabled(true) // Hides iOS video controls
//                .aspectRatio(contentMode: .fill)
//                .onAppear {
//
//                    player.play()
//                    player.volume = 0
//                }
//                .onReceive(NotificationCenter
//                    .default
//                    .publisher(
//                        for: .AVPlayerItemDidPlayToEndTime,
//                        object: player.currentItem),
//                           perform: { _ in
//                                player.seek(to: .zero)
//                                player.play()
//                            }
//                )
//                .frame(width: (UIScreen.screenWidth), height: UIScreen.screenHeight/2)
//                
            
            Image(.imgPurchase)
                .resizable()
                .ignoresSafeArea()
                .frame(width: UIScreen.screenWidth, height: UIScreen.screenHeight)
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
            .alert("Success!", isPresented: $showSuccessDialog) {
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
            } .opacity(isLoading ? 0.5 : 0.0)
        }
    }
}

var colorGradient = [Color(hex: "#FFC700"),Color(hex: "#FAFF00")]


struct ButtonGradient: View{
    var body: some View {
        RoundedRectangle(cornerRadius: 8)
            .stroke(
                
                EllipticalGradient(colors:colorGradient,
                                                  center: .topLeading,
                                                  startRadiusFraction: 0.0,
                                                  endRadiusFraction: 1.0),
                lineWidth: 2
            )
    }
}

struct VideoView: UIViewControllerRepresentable {
    let player: AVPlayer

    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.player = player
        controller.showsPlaybackControls = false
        controller.videoGravity = .resizeAspectFill // Center Crop Effect
        return controller
    }

    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {}
}
