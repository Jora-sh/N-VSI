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
    
    @State var showNoCreditsLeftDialog = false
    @State var showContactUsBottomSheet = false
    @State var showNoFreeCreditsLeftDialog = false
    
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
                        if swapViewModel.goLoadingWithoutCredits {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 6) {
                                withAnimation {
                                    self.showNoCreditsLeftDialog = true
                                }
                            }
                        } else {
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
                                        if msg == "not enough credits" {
                                            self.showNoCreditsLeftDialog = true
                                        } else if msg == "not enough free credits" {
                                            self.showNoFreeCreditsLeftDialog = true
                                        } else {
                                            self.showErrorDialog = true
                                        }
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
                    }
                
                Spacer()
                
                VStack {
                    
                    LottieView(name: "loading2.json", play: .constant(true))
                        .lottieLoopMode(.loop)
                        .frame(width: 200, height: 200)
                    
                    Spacer()
                        .frame(height: 24)
                    
                    Text("Please wait, Processing...")
                        .bold()
                        .foregroundStyle(.white)
                        .font(.system(size: 16))
                    
                    Spacer()
                        .frame(height: 24)
                    
                    Text("Please wait patiently for your result to be\ngenerated; rushing may affect the outcome and\nconsume credits without providing results.")
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.white)
                        .font(.system(size: 14))
                    
                }
                
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
            
            ErrorDialog(errorType: .Oops, showDialog: $showErrorDialog) {
                withAnimation {
                    mainViewModel.SCREEN_VIEW = .Main
                }
            }
            
            NoFreeCreditsLeftDialog(shown: $showNoFreeCreditsLeftDialog)
            
            NoCreditsLeftDialog(shown: $showNoCreditsLeftDialog,
                                creditsOwned: .constant(mainViewModel.userModel?.credits ?? 0),
                                creditsNeeded: $swapViewModel.creditsNeededForCustomSwap) {
                withAnimation {
                    mainViewModel.SCREEN_VIEW = .Purchase
                }
            }.onChange(of: showNoCreditsLeftDialog) { new in
                if !showNoCreditsLeftDialog {
                    withAnimation {
                        mainViewModel.SCREEN_VIEW = .Purchase
                    }
                }
            }
            
        }.sheet(isPresented: $showContactUsBottomSheet, content: {
            ContactUsView(showContactUsBottomSheet: $showContactUsBottomSheet)
        })

    }
}

