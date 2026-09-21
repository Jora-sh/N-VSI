//
//  AiNoticeScreen.swift
//  VideoFaceSwap
//
//  Created by Javad on 9/19/26.
//

import SwiftUI

struct AiNoticeScreen: View {
    
    @EnvironmentObject var mainViewModel : MainViewModel
    
    var header: some View {
        HStack {
            
            Button {
                withAnimation {
                    mainViewModel.SCREEN_VIEW = .Settings
                }
            } label: {
                Image(.iconBack)
                    .resizable()
                    .frame(width: 24, height: 24)
                    .padding(.vertical, 8)
            }
            
            Spacer()
            
        }.overlay {
            
            Text("How AI Uses Your Data")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(.white)
            
        }
        .frame(width: UIScreen.screenWidth - 32)
    }
    
    var body: some View {
        VStack {
            
            header
                .onAppear {
                    
                }
            
            VStack {
                
                Spacer()
                    .frame(height: 40)
                
                Text(noticeText)
                    
                    .multilineTextAlignment(.leading)
                    .font(.system(size: 15))
                    
                    .foregroundStyle(Color.white)
                
                Spacer()
                    .frame(height: 40)
                
                Link(destination: URL(string: privacyPolicyLink)!) {
                    HStack(spacing: 12) {
                        
                        Image(.iconPrivacy)
                            .resizable()
                            .frame(width: 24, height: 24)
                        
                        Text("Privacy & Policy")
                            .font(.system(size: 16,weight: .medium))
                            .foregroundStyle(Color.white)
                        
                        Spacer()
                        
                        Image(.iconBack)
                            .resizable()
                            .rotationEffect(.degrees(180))
                            .frame(width: 32, height: 32)
                            
                        
                    }.padding(.horizontal,16)
                        .padding(.vertical,8)
                        .background {
                            Color.white.opacity(0.05)
                                .cornerRadius(10)
                        }
                }
            }
            .frame(width: UIScreen.screenWidth - 32)
            
            Spacer()
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(Rectangle())
        .swipeBack {
            withAnimation {
                mainViewModel.SCREEN_VIEW = .Settings
            }
        }
    }
    
    let noticeText = "To generate AI videos, the photos and videos you provide are securely sent to our servers for processing.\nYour uploaded content is used only to provide the AI features and generate the results you request. We do not sell your personal data or uploaded photos and videos.\nYour content may be temporarily processed and stored as needed to complete your request. We do not retain your uploaded content longer than necessary to provide the requested service, unless otherwise stated in our Privacy Policy.\nWe take reasonable measures to protect your content during transmission and processing. Access to your content is limited to what is necessary to provide the AI features.\nFor more information about how we collect, use, store, and protect your data, please review our Privacy Policy."
    
}


