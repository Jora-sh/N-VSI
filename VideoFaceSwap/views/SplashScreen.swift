//
//  SplashScreen.swift
//  VideoFaceSwap
//
//  Created by Javad on 4/13/25.
//

import SwiftUI


struct SplashScreen : View {
    
    @EnvironmentObject var mainViewModel : MainViewModel
    
    var body: some View {
        ZStack {
            
            VStack(alignment: .center) {
                
                Spacer()
                    .onAppear {
                        if UserSettings.token == "" {
                            mainViewModel.signupUser { err in
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                    withAnimation {
                                        if UserSettings.isWatchOnBoarding {
                                            mainViewModel.SCREEN_VIEW = .Main
                                        } else {
                                            mainViewModel.SCREEN_VIEW = .OnBoarding
                                        }
                                    }
                                }
                            }
                        } else {
                            mainViewModel.getMe {err in
                                if err == nil {
                                    print(UserSettings.username)
                                    mainViewModel.getHomeConfig()
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                        withAnimation {
                                            mainViewModel.SCREEN_VIEW = .Main
                                        }
                                    }
                                } else {
                                    print("FAAAAALSE")
                                }
                            }
                        }
                        
                    }
                
                Image(.appIconSplash)
                    .resizable()
                    .frame(width: 220, height: 220)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                
                Spacer()
                    .frame(height: 16)
                
                HStack(spacing: 0) {
                    Group {
                        
                        Text("Video ")
                            .foregroundStyle(Color(hex: "#3ECCF8"))
                        
                        Text("Face Swapper")
                            .foregroundStyle(.white)
                        
                    }
                    .font(.system(size: 20, weight: .heavy))
                    
                    
                }.frame(width: UIScreen.screenWidth - 32)
                
                Spacer()
                
            }
            
            VStack(alignment: .center) {
                
                Spacer()
                
                Text("Seamlessly swap faces in videos\nwith advanced AI technology!")
                    .multilineTextAlignment(.center)
                    .font(.system(size: 16))
                    .foregroundStyle(Color.white)
                
                Spacer()
                    .frame(height: 18)
                
                Text("You must be online to use App!")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.white.opacity(0.9))
                
                Spacer()
                    .frame(height: 16)
                
                AnimatedProgressBar()
                
                Spacer()
                    .frame(height: 32)
                
            }
            
        }
    }
}

struct AnimatedProgressBar: View {
    @State private var progress: CGFloat = 0.0

    var body: some View {
        VStack(spacing: 30) {
            ZStack(alignment: .leading) {
                Capsule()
                    .frame(height: 5)
                    .foregroundColor(.white)

                Capsule()
                    .frame(width: progress * 300, height: 5)
                    .foregroundColor(Color(hex: "#34A5F2"))
                    .animation(.easeInOut(duration: 0.5), value: progress)
            }
            .frame(width: 300)
        }
        .padding()
        .onAppear {
            withAnimation(.linear(duration: 1.4)) {
                progress = 1.0
            }
        }
    }
}
