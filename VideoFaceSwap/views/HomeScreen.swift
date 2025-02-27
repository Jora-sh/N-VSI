//
//  HomeScreen.swift
//  VideoFaceSwap
//
//  Created by Javad on 11/3/24.
//

import SwiftUI
import OneSignalFramework

struct HomeScreen: View {
    
    @EnvironmentObject var mainViewModel  :MainViewModel
    
    @State var selectedCategory = ""
    
    var body: some View {
        VStack {
            
            
            Button {
                withAnimation {
                    mainViewModel.SCREEN_VIEW = .Purchase
                }
            } label: {
                AsyncImage(url: URL(string: mainViewModel.homeConfig?.homeConfig?.icons?.bannerImage ?? "http://89.22.239.26/nexora-swap-ios-stage/public/home/3e294587-97d8-4405-97d9-5fcd9b8fd4b3.png")!, scale: 1.0) { img in
                    img.resizable()
                        .frame(width: UIScreen.screenWidth - 32, height: 120)
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                } placeholder: {
                    Image(.background)
                        .frame(width: UIScreen.screenWidth - 32, height: 120)
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
                .onAppear {
                    
                    OneSignal.Notifications.requestPermission({ accepted in
                      print("User accepted notifications: \(accepted)")
                    }, fallbackToSettings: true)
                    if mainViewModel.categories.count > 0 {
                        selectedCategory = mainViewModel.categories[0].id
                    }
                    mainViewModel.getAllCategories { err in
                        if mainViewModel.categories.count > 0 {
                            selectedCategory = mainViewModel.categories[0].id
                        }
                    }
                    mainViewModel.getMe()
                }
            
            VStack {
                
                Spacer()
                    .frame(height: 16)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    
                    HStack(spacing: 8) {
                        Spacer()
                            .frame(width: 12)
                        ForEach(mainViewModel.categories, id: \.id) { category in
                            
                            Button {
                                withAnimation(.easeIn(duration: 0.2)) {
                                    selectedCategory = category.id
                                }
                            } label: {
                                Text(category.name)
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundStyle(.white)
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 8)
                                    .background {
                                        LinearGradient(colors: selectedCategory == category.id ? gradientColor : [], startPoint: .leading, endPoint: .trailing)
                                    }
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                        }
                        Spacer()
                            .frame(width: 12)
                    }
                    
                }
                
                Spacer()
                    .frame(height: 16)
                
                TabView(selection: $selectedCategory) {
                    
                    ForEach(mainViewModel.categories, id: \.id) { item in
                        VideoTabView(category: item)
                            .tag(item.id)
                    }
                    
                }.tabViewStyle(.page(indexDisplayMode: .never))
                
                
            }.offset(y: 10)
            
        }
    }
}
