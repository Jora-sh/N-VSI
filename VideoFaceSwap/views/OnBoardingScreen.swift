//
//  OnBoardingScreen.swift
//  VideoFaceSwap
//
//  Created by Javad on 11/5/24.
//

import SwiftUI

struct OnBoardingScreen: View {
    
    
    @EnvironmentObject var mainViewModel : MainViewModel
    
    @Environment(\.requestReview) var requestReview
    
    @State var step = 1
    
    var body: some View {
        ZStack {
            
            Color.init(hex: "#1B1B1E").ignoresSafeArea()
                .onAppear {
                    if UserSettings.isWatchOnBoarding {
                        mainViewModel.SCREEN_VIEW = .Main
                        if mainViewModel.userModel?.hasActiveSubscription == false &&
                            mainViewModel.userModel?.totalCredits ?? 0 <= 0 {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                                if mainViewModel.SCREEN_VIEW == .Main {
                                    withAnimation {
                                        mainViewModel.SCREEN_VIEW = .Purchase
                                    }
                                }
                            }
                        }
                    }
                }
            
            VStack {
                Image(step == 1 ? .imgOnBoarding : .imgOnBoarding2)
                    .resizable()
                    .frame(width: UIScreen.screenWidth,
                           height: step == 1 ? UIScreen.screenWidth*1.5 : UIScreen.screenHeight-200)
                    .ignoresSafeArea()
                Spacer()
            }
            
            VStack(alignment: .leading) {
                
                Spacer()
                
                VStack {
                    
                    HStack(spacing: 0) {
                        if step == 1 {
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
                            .font(.system(size: 24, weight: .heavy))
                        } else {
                            VStack {
                                HStack {
                                    Group {
                                        
                                        Text("Help Us")
                                            .foregroundStyle(.white)
                                        
                                        Text("Grow ")
                                            .foregroundStyle(Color(hex: "#3ECCF8"))
                                        
                                    }
                                    .font(.system(size: 24, weight: .heavy))
                                }
                            }
                        }
                        
                    }.frame(width: UIScreen.screenWidth - 32)
                    
                    Spacer()
                        .frame(height: 8)
                    
                    HStack(spacing: 0) {
                        
                        if step == 1 {
                            Group {
                                
                                Text("Upload a video and let the ")
                                    .foregroundStyle(.white)
                                
                                Text("magic ")
                                    .foregroundStyle(Color(hex: "#3ECCF8"))
                                
                                Text("begin! ")
                                    .foregroundStyle(.white)
                                
                            }
                            .font(.system(size: 14,weight: .semibold))
                        } else {
                            Group {
                                
                                Text("Your ")
                                    .foregroundStyle(.white)
                                
                                Text("support ")
                                    .foregroundStyle(Color(hex: "#3ECCF8"))
                                
                                Text("means ")
                                    .foregroundStyle(.white)
                                
                                Text("everything ")
                                    .foregroundStyle(Color(hex: "#3ECCF8"))
                                
                                Text("to us.")
                                    .foregroundStyle(.white)
                                
                            }.font(.system(size: 14,weight: .semibold))
                        }
                    }
                    
                    
                    Spacer()
                        .frame(height: step == 1 ? 20 : 36)
                    
                    if step == 1 {
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
                            
                            Text(" (You must be online to use App!)")
                                .font(.system(size: 12))
                                .foregroundStyle(Color.init(hex: "#f1f1f1").opacity(0.9))
                            
                        }
                        .frame(width: UIScreen.screenWidth - 32)
                        
                        Spacer()
                            .frame(height: 20)
                    }
                   
                    
                    Button(action: {
                        if step == 1 {
                            withAnimation {
                                step = 2
                            }
                        } else {
                            requestReview()
                            
                            DispatchQueue.main.asyncAfter(deadline: .now()+3) {
                                UserSettings.isWatchOnBoarding = true
                                if UserSettings.token != "" {
                                    withAnimation {
                                        mainViewModel.SCREEN_VIEW = .Main
                                    }
                                }
                                mainViewModel.isLoadingSignUp = true
                                if mainViewModel.userModel?.hasActiveSubscription == false &&
                                    mainViewModel.userModel?.totalCredits ?? 0 <= 0 {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                                        if mainViewModel.SCREEN_VIEW == .Main {
                                            withAnimation {
                                                mainViewModel.SCREEN_VIEW = .Purchase
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }, label: {
                        HStack {
                            Text(step == 1 ? "Continue" : "Get Started")
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
                        .frame(height: 24)
                }
                .padding(.horizontal, 20)
                
            }
        }
    }
}


let privacyPolicyLink = "https://marked-cymbal-c29.notion.site/FaceSwap-AI-Video-Swap-Faces-Privacy-Policy-39b8aaa542c38004b545d530ea34ba25"
let termsOfServiceLink = "https://marked-cymbal-c29.notion.site/FaceSwap-AI-Video-Swap-Faces-Terms-and-Conditions-39b8aaa542c38026a05df6c37eba3e04"
