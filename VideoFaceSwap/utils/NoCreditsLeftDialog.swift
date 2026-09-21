//
//  NoCreditsLeftDialog.swift
//  VideoFaceSwap
//
//  Created by Javad on 11/9/24.
//

import Foundation
import SwiftUI


struct NoCreditsLeftDialog: View {
    
    @EnvironmentObject var mainViewModel : MainViewModel
    
    @Binding var shown : Bool
    @Binding var creditsOwned : Int
    @Binding var creditsNeeded : Int
    
    var onGoToCreditHistoyClicked : () -> Void
    var onGoToPurchaseClicked : () -> Void
    
    var body: some View {
        ZStack(alignment:.center) {
            
            Color.black
                .opacity(shown ? 0.66 : 0.0)
                .blur(radius: 5.0)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation {
                        shown = false
                    }
                    onGoToPurchaseClicked()
                }
            
            
            ZStack(alignment: .center) {
                
                VStack {
                    
                    Image(.iconHeaderNoCreditsDialog)
                        .resizable()
                        .frame(width: 164 * 1.5, height: 146 * 1.5)
                        .offset(y: 20)
                    
                    VStack {
                        
                        Text("Sorry, You don’t have enough credit! ")
                            .foregroundStyle(.white.opacity(0.8))
                            .font(.system(size: 16))
                        
                        if mainViewModel.userModel?.totalCredits ?? 0 > 0 || mainViewModel.userModel?.hasActiveSubscription == true {
                            Spacer()
                                .frame(height: 16)
                            
                            HStack {
                                
                                Group {
                                    Text("Your")
                                        .foregroundStyle(Color(hex: "#34A5F2"))
                                    Text("Credit :")
                                        .foregroundStyle(.white)
                                }.bold()
                                    .font(.system(size: 16))
                                
                                Spacer()
                                    .frame(width: 8)
                                
                                Text("\(creditsOwned)")
                                    .bold()
                                    .foregroundStyle(.white)
                                    .font(.system(size: 16))
                                    .padding(6)
                                    .listRowBackground(
                                        RoundedRectangle(cornerRadius: 5)
                                            .strokeBorder(
                                                Color(hex: "#FF7518"),
                                                style: StrokeStyle(lineWidth: 1, dash: [10])
                                            )
                                    )
                                    
                                
                            }
                            .frame(width: UIScreen.screenWidth - 116, height: 50)
                            .roundedCornerWithBorder(lineWidth: 1, borderColor: Color(hex: "#34A5F2"), radius: 5, corners: .allCorners)
                            
                            Spacer()
                                .frame(height: 16)
                            
                            HStack {
                                
                                Group {
                                    Text("Required")
                                        .foregroundStyle(Color(hex: "#D32F2F"))
                                    Text("Credit :")
                                        .foregroundStyle(.white)
                                }.bold()
                                    .font(.system(size: 16))
                                
                                Spacer()
                                    .frame(width: 8)
                                
                                Text("\(creditsNeeded)")
                                    .bold()
                                    .foregroundStyle(.white)
                                    .font(.system(size: 16))
                                    .padding(6)
                                    .listRowBackground(
                                        RoundedRectangle(cornerRadius: 5)
                                            .strokeBorder(
                                                Color(hex: "#AD00FF"),
                                                style: StrokeStyle(lineWidth: 1, dash: [10])
                                            )
                                    )
                            }
                            .frame(width: UIScreen.screenWidth - 116, height: 50)
                            .roundedCornerWithBorder(lineWidth: 1, borderColor: Color(hex: "#D32F2F"), radius: 5, corners: .allCorners)
                        }
                        
                        Spacer()
                            .frame(height: 24)
                        
                        if mainViewModel.userModel?.totalCredits ?? 0 > 0 || mainViewModel.userModel?.hasActiveSubscription == true {
                            Button {
                                withAnimation {
                                    shown = false
                                }
                                onGoToCreditHistoyClicked()
                            } label: {
                                
                                HStack {
                                    
                                    Image(.iconSettingsCreditHistory)
                                        .resizable()
                                        .frame(width: 24, height: 24)
                                    
                                    Text("View Credit Details")
                                        .font(.system(size: 18 , weight: .semibold))
                                        .foregroundColor(.white)
                                }
                                
                                .padding(.vertical, 16)
                                .frame(width: UIScreen.screenWidth - 110, height: 55)
                                .roundedBorder(Color(hex: "#34A5F2"), width: 1, cornerRadius: 10)
                                
                            }
                            
                            Spacer()
                                .frame(height: 12)
                        }
                        
                        Button {
                            withAnimation {
                                shown = false
                            }
                            onGoToPurchaseClicked()
                        } label: {
                            
                            HStack {
                                
                                Image(.iconDiamond)
                                    .resizable()
                                    .frame(width: 24, height: 24)
                                
                                Text("Get More Credit")
                                    .font(.system(size: 18 , weight: .semibold))
                                    .foregroundColor(.white)
                            }
                            
                            .padding(.vertical, 16)
                            .frame(width: UIScreen.screenWidth - 110, height: 55)
                            .background(
                                LinearGradient(
                                    colors: [
                                        Color(hex: "#3ECCF8"),
                                        Color(hex: "#34A5F2")
                                    ],
                                    startPoint: UnitPoint(x: 0, y: 0.5),
                                    endPoint: UnitPoint(x: 1, y: 0.5)
                                )
                            )
                            .cornerRadius(10)
                        }
                    }
                    .padding(.vertical, 24)
                    .frame(width: UIScreen.screenWidth - 64)
                        .background {
                            Color(hex: "#1D1B20")
                                .frame(width: UIScreen.screenWidth - 64)
                        }
                        .roundedCornerWithBorder(lineWidth: 1, borderColor: Color(hex: "#34A5F2"), radius: 10, corners: .allCorners)
                    
                    Spacer()
                        .frame(height: 24)
                    
                }
                
                

            }
            
            
        }.opacity(shown ? 1.00 : 0.0)
            .offset(y: shown ? 0 : UIScreen.screenHeight)
    }
}

struct NoFreeCreditDialog: View {
    
    @EnvironmentObject var mainviewmodel: MainViewModel
    
    @Binding var shown : Bool
    
    var body: some View {
        ZStack(alignment:.center) {
            
            Color.init(hex: "#222222")
                .opacity(shown ? 0.90 : 0.0)
                .blur(radius: 5.0)
                .ignoresSafeArea()
            
            
            ZStack(alignment: .center) {
                
                VStack {
                    
                    Image(.iconHeaderNoCreditsDialog)
                        .resizable()
                        .frame(width: 164 * 1.8, height: 146 * 1.8)
                        .offset(y: 20)
                    
                    VStack {
                        
                        Text("Your free attempts for today are over.\nTry again tomorrow\nor upgrade for more access.")
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.white.opacity(0.8))
                            .font(.system(size: 16))
                        
                        Spacer()
                            .frame(height: 24)
                        
                        Button {
                            withAnimation {
                                mainviewmodel.SCREEN_VIEW = .Purchase
                            }
                            
                        } label: {
                            
                            HStack {
                                
                                Image(.iconDiamond)
                                    .resizable()
                                    .frame(width: 24, height: 24)
                                
                                Text("Get Credit")
                                    .font(.system(size: 18 , weight: .semibold))
                                    .foregroundColor(.white)
                            }
                            
                            .padding(.vertical, 16)
                            .frame(width: UIScreen.screenWidth - 110, height: 55)
                            .background(
                                LinearGradient(
                                    colors: [
                                        Color(hex: "#3ECCF8"),
                                        Color(hex: "#34A5F2")
                                    ],
                                    startPoint: UnitPoint(x: 0, y: 0.5),
                                    endPoint: UnitPoint(x: 1, y: 0.5)
                                )
                            )
                            .cornerRadius(10)
                        }
                        
                    }.frame(width: UIScreen.screenWidth - 64, height: 145)
                        .background {
                            Color(hex: "#1D1B20")
                                .frame(width: UIScreen.screenWidth - 64, height: 145)
                        }
                        .roundedCornerWithBorder(lineWidth: 1, borderColor: Color(hex: "#34A5F2"), radius: 10, corners: .allCorners)
                    
                    Spacer()
                        .frame(height: 110)
                    
                }
                
                

            }
            
            
        }.opacity(shown ? 1.00 : 0.0)
            .offset(y: shown ? 0 : UIScreen.screenHeight)
    }
}

struct NoFreeCreditsLeftDialog: View {
    
    @EnvironmentObject var mainviewmodel: MainViewModel
    
    @Binding var shown : Bool
    
    var body: some View {
        ZStack(alignment:.center) {
            
            Color.init(hex: "#222222")
                .opacity(shown ? 0.90 : 0.0)
                .blur(radius: 5.0)
                .ignoresSafeArea()
            
            
            ZStack(alignment: .center) {
                
                VStack {
                    
                    Image(.iconHeaderNoCreditsDialog)
                        .resizable()
                        .frame(width: 164 * 1.8, height: 146 * 1.8)
                        .offset(y: 20)
                    
                    VStack {
                        
                        Text("Your free attempts for today are over.\nTry again tomorrow\nor upgrade for more access.")
                            .lineSpacing(14)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.white.opacity(0.8))
                            .font(.system(size: 16))
                        
                        Spacer()
                            .frame(height: 24)
                        
                        Button {
                            withAnimation {
                                mainviewmodel.SCREEN_VIEW = .Purchase
                            }
                            
                        } label: {
                            
                            HStack {
                                
                                Image(.iconDiamond)
                                    .resizable()
                                    .frame(width: 24, height: 24)
                                
                                Text("Get More Credit")
                                    .font(.system(size: 18 , weight: .semibold))
                                    .foregroundColor(.white)
                            }
                            
                            .padding(.vertical, 16)
                            .frame(width: UIScreen.screenWidth - 110, height: 55)
                            .background(
                                LinearGradient(
                                    colors: [
                                        Color(hex: "#3ECCF8"),
                                        Color(hex: "#34A5F2")
                                    ],
                                    startPoint: UnitPoint(x: 0, y: 0.5),
                                    endPoint: UnitPoint(x: 1, y: 0.5)
                                )
                            )
                            .cornerRadius(10)
                        }
                        
                    }.frame(width: UIScreen.screenWidth - 64, height: 200)
                        .background {
                            Color(hex: "#1D1B20")
                                .frame(width: UIScreen.screenWidth - 64, height: 200)
                        }
                        .roundedCornerWithBorder(lineWidth: 1, borderColor: Color(hex: "#34A5F2"), radius: 10, corners: .allCorners)
                    
                    Spacer()
                        .frame(height: 110)
                    
                }
                
                

            }
            
            
        }.opacity(shown ? 1.00 : 0.0)
            .offset(y: shown ? 0 : UIScreen.screenHeight)
    }
}



