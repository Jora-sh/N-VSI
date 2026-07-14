//
//  CreditHistory.swift
//  VideoFaceSwap
//
//  Created by Javad on 7/5/26.
//

import SwiftUI
import LottieSwiftUI

struct CreditHistory: View {
    
    @EnvironmentObject var mainViewModel : MainViewModel
    
    var header: some View {
        HStack {
            
            Button {
                withAnimation {
                    mainViewModel.SCREEN_VIEW = mainViewModel.CreditDetailsBackstack ?? .Settings
                }
            } label: {
                Image(.iconBack)
                    .resizable()
                    .frame(width: 24, height: 24)
                    .padding(.trailing)
            }
            
            Spacer()

        }
        .overlay(content: {
            Text("Credits Details")
                .foregroundStyle(.white)
                .font(.system(size: 22, weight: .semibold))
        })
        .padding(.horizontal, 12)
        .frame(height: 58)
    }
    
    
    var cardTop : some View {
        Button {
            mainViewModel.purchaseBackstack = .PurchaseHistory
            withAnimation {
                mainViewModel.SCREEN_VIEW = .Purchase
            }
        } label: {
            VStack(alignment: .leading) {
                
                HStack {
                    Text("Credit Balance")
                        .font(.system(size: 16,weight: .semibold))
                        .foregroundStyle(Color.white)
                    
                    Spacer()
                }
                
                Spacer()
                    .frame(height: 16)
                
                Text("\(mainViewModel.userModel?.totalCredits ?? 0)")
                    .font(.system(size: 24))
                    .fontWeight(.black)
                    .foregroundStyle(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.init(hex: "#FF00CC"),
                                Color.init(hex: "#FF00CC"),
                                Color.init(hex: "#00EAFF")
                            ]),
                            startPoint: .trailing,
                            endPoint: .leading
                        )
                    )
                
            }
            .overlay(alignment: .bottomTrailing, content: {
//                Image(.imgGetMoreCrdits)
            })
            .padding(16)
            .frame(width: UIScreen.screenWidth - 32, height: 96)
            .background {
                SettingsItemBackground()
            }
        }

    }
    
    var body: some View {
        VStack {
            
            Spacer()
                .frame(height: 0)
                .onAppear {
                    mainViewModel.getCreditHistory()
                }
            
            header
            
            VStack(spacing: 16) {
                
//                cardTop
                
                VStack {
                    
                    if mainViewModel.creditHistoryList.isEmpty && mainViewModel.isHistoryLoading == false {
                        VStack(spacing: 16) {
                            Spacer()
                            Image(.imgEmptyLogs)
                                .resizable()
                                .frame(width: 220, height: 220)
                            
                            Text("No Logs Here!")
                                .bold()
                                .multilineTextAlignment(.center)
                                .font(.system(size: 20))
                                .foregroundStyle(Color.white)
                            
                            Text("You haven’t created any videos yet.")
                                .multilineTextAlignment(.center)
                                .font(.system(size: 14))
                                .foregroundStyle(Color.init(hex: "#DBDBDB"))
                            
                            Spacer()
                            Spacer()
                        }
                    } else {
                        
                        ScrollView(showsIndicators: false) {
                            ForEach(mainViewModel.creditHistoryList, id: \.id) { item in
                                HStack {
                                    Image(item.transactionType == "DECREASE" ? .iconCreditHistoryMinus : .iconCreditHistoryPlus)
                                        .resizable()
                                        .frame(width: 24, height: 24)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 24)
                                    
                                    VStack(alignment: .leading,spacing: 4) {
                                        
                                        Text(item.reason ?? "")
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundStyle(Color.white.opacity(0.9))
                                        
                                        Text(item.createdAt ?? "")
                                            .font(.system(size: 12))
                                            .foregroundStyle(Color.init(hex: "#909090"))
                                        
                                    }
                                    
                                    Spacer()
                                        
                                    Text("\(item.transactionType == "DECREASE" ? "-" : "+")\(item.amount ?? 0)")
                                        .font(.system(size: 16, weight: .heavy))
                                        .foregroundStyle(Color.init(hex: item.transactionType == "DECREASE" ? "#FF383C" : "#3ECCF8"))
                                        .padding(12)
                                    
                                }
                                .background {
                                    Color.white.opacity(0.0)
                                        .roundedBorder(Color.white.opacity(0.15), width: 1, cornerRadius: 8)
                                }
                            }
                        }.refreshable {
                            mainViewModel.getCreditHistory()
                        }
                        
                    }
                    
                }.frame(width: UIScreen.screenWidth - 32)
                
                
            }
            
        }
    }
}



struct SettingsItemBackground: View {
    
    var body: some View {
        Color.white.opacity(0.08)
            .roundedBorder(Color.white.opacity(0.25), width: 1, cornerRadius: 12)
    }
}
