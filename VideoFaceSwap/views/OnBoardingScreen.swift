//
//  OnBoardingScreen.swift
//  VideoFaceSwap
//
//  Created by Javad on 11/5/24.
//

import SwiftUI

struct OnBoardingScreen: View {
    
    
    @EnvironmentObject var mainViewModel : MainViewModel
    
    var body: some View {
        ZStack {
            
            Color.init(hex: "#1B1B1E").ignoresSafeArea()
                .onAppear {
                    if UserSettings.isWatchOnBoarding {
                        mainViewModel.SCREEN_VIEW = .Main
                    }
                }
            
            VStack(alignment: .leading) {
                
                Image(.imgOnBoarding)
                    .resizable()
                    .frame(width: UIScreen.screenWidth, height: UIScreen.screenWidth*1.5)
                    .ignoresSafeArea()
                
                VStack {
                    
                    HStack(spacing: 0) {
                        Group {
                            
                            Text("Ready to ")
                                .foregroundStyle(.white)
                            
                            Text("Swap ")
                                .foregroundStyle(Color(hex: "#3ECCF8"))
                            
                            Text("Your ")
                                .foregroundStyle(.white)
                            
                            Text("Videos")
                                .foregroundStyle(Color(hex: "#3ECCF8"))
                            
                            Text("?")
                                .foregroundStyle(.white)
                            
                        }
                        .font(.system(size: 20, weight: .heavy))
                        
                        Spacer()
                        
                    }.frame(width: UIScreen.screenWidth - 32)
                    
                    Spacer()
                        .frame(height: 8)
                    
                    HStack {
                        Text("Upload a video and let the magic begin!")
                            .font(.system(size: 14,weight: .semibold))
                            .foregroundStyle(.white)
                        Spacer()
                    }
                    .frame(width: UIScreen.screenWidth - 32)
                        
                    
                    Spacer()
                        .frame(height: 24)
                    
                   
                    
                    Button(action: {
                        UserSettings.isWatchOnBoarding = true
                        withAnimation {
                            mainViewModel.SCREEN_VIEW = .Main
                        }
                    }, label: {
                        HStack {
                            Text("Get Started")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundStyle(.white)
                        }
                        .frame(width: UIScreen.screenWidth - 32, height: 48)
                        .background {
                            LinearGradient(colors: gradientColor, startPoint: .leading, endPoint: .trailing)
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    })
                    
                    Spacer()
                        .frame(height: 36)
                    
                    HStack {
                        Group {
                            
                            Text("By continuing, You agree to our")
                            
                            Link(destination: URL(string: termsOfServiceLink)!, label: {
                                Text("Terms & Conditions ")
                                    .underline()
                            })
                            
                        }
                        .foregroundStyle(Color(hex: textColor))
                        .font(.system(size: 13, weight: .regular))
                        
                        Spacer()
                    }
                    .frame(width: UIScreen.screenWidth - 32)
                    
                    Spacer()
                        .frame(height: 8)
                    
                    HStack {
                        Group {
                            
                            Text("and")
                            
                            Link(destination: URL(string: privacyPolicyLink)!, label: {
                                Text("Privacy Policy.")
                                    .underline()
                            })
                            
                        }
                        .foregroundStyle(Color(hex: textColor))
                        .font(.system(size: 13, weight: .regular))
                        
                        Spacer()
                    }
                    .frame(width: UIScreen.screenWidth - 32)
                    
                    Spacer()
                        .frame(height: 36)
                    
                }
                .padding(.horizontal, 20)
                
            }
        }
    }
}

let privacyPolicyLink = "https://meet.google.com/landing"
let termsOfServiceLink = "https://meet.google.com/landing"
