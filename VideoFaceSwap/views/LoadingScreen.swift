//
//  LoadingScreen.swift
//  VideoFaceSwap
//
//  Created by Javad on 11/4/24.
//

import SwiftUI
import LottieSwiftUI

struct LoadingScreen: View {
    
    @EnvironmentObject var mainViewModel : MainViewModel
    @EnvironmentObject var swapViewModel : SwapViewModel
    
    @State var showCancelDialog = false
    
    @State var showErrorDialog = false
    
    @State var showContactUsBottomSheet = false
    
    var header: some View {
        HStack {
            
            Button {
                showCancelDialog = true
            } label: {
                Image(.iconBack)
                    .resizable()
                    .frame(width: 24, height: 24)
                    .padding(.vertical, 8)
            }
            
            Spacer()
            
            Button {
                withAnimation {
                    showContactUsBottomSheet = true
                }
            } label: {
                Image(.iconContactUs)
                    .resizable()
                    .frame(width: 24, height: 24)
                    .padding(.vertical, 8)
            }
            
        }.overlay {
            
            Text("Loading...")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(.white)
            
        }
        .frame(width: UIScreen.screenWidth - 32)
    }
    
    
    var body: some View {
        ZStack {
            VStack {
                
                header
                    .onAppear{
                        if swapViewModel.templateToSwapWithTemplate != nil {
                            swapViewModel.swapWithTemplate(image: swapViewModel.imageToSwapWithTemplate, templateId : swapViewModel.templateToSwapWithTemplate?.templateName ?? "") { isSuccess, msg in
                                
                                if isSuccess {
                                    swapViewModel.checkForVideo(jobId: msg ?? "") { isSuccess, videoUrl in
                                        if isSuccess {
                                            withAnimation {
                                                mainViewModel.SCREEN_VIEW = .Result
                                            }
                                        } else {
                                            self.showErrorDialog = true
                                        }
                                    }
                                } else {
                                    self.showErrorDialog = true
                                }
                                swapViewModel.templateToSwapWithTemplate = nil
                            }
                        } else {
                            swapViewModel.uploadMedia(videoPath: swapViewModel.videoUrl, image: swapViewModel.imageSelected!) { isSuccess, msg in
                                
                                if isSuccess {
                                    swapViewModel.checkForVideo(jobId: msg ?? "") { isSuccess, videoUrl in
                                        if isSuccess {
                                            withAnimation {
                                                mainViewModel.SCREEN_VIEW = .Result
                                            }
                                        } else {
                                            self.showErrorDialog = true
                                        }
                                    }
                                } else {
                                    self.showErrorDialog = true
                                }
                                swapViewModel.templateToSwapWithTemplate = nil
                            }
                        }
                    }
                
                Spacer()
                
                LottieView(name: "loading2.json", play: .constant(true))
                    .lottieLoopMode(.loop)
                    .frame(width: 200, height: 200)
                
                Spacer()
                
            }.alert("Cancel Generating?", isPresented: $showCancelDialog) {
                Button("Yes, Cancel") {
                    withAnimation {
                        mainViewModel.SCREEN_VIEW = .Main
                    }
                }
                Button("No, Continue") { }
            } message: {
                Text("Are you sure you want to cancel swapping faces? this will reduce your credits.")
            }
            
            ErrorDialog(errorType: .Sorry, showDialog: $showErrorDialog) {
                withAnimation {
                    mainViewModel.SCREEN_VIEW = .Main
                }
            }
            
        }.sheet(isPresented: $showContactUsBottomSheet, content: {
            ContactUsView(showContactUsBottomSheet: $showContactUsBottomSheet)
        })

    }
}

