//
//  SettingsScreen.swift
//  VideoFaceSwap
//
//  Created by Javad on 11/4/24.
//

import SwiftUI

struct SettingsScreen: View {
    
    @EnvironmentObject var mainViewModel : MainViewModel
    
    
    @State var showContactUsBottomSheet = false
    @State var isAutoSaveOn = true
    @State private var showCopiedAlert = false
    @State private var showClearHistoryConfirm = false
    @State private var isClearingHistory = false
    
    @Environment(\.requestReview) var requestReview
    
    
    var header: some View {
        HStack {
            
            Button {
                withAnimation {
                    mainViewModel.SCREEN_VIEW = .Main
                }
            } label: {
                Image(.iconBack)
                    .resizable()
                    .frame(width: 24, height: 24)
                    .padding(.vertical, 8)
            }
            
            Spacer()
            
        }.overlay {
            
            Text("Settings")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(.white)
            
        }
        .frame(width: UIScreen.screenWidth - 32)
    }
    
    
    var body: some View {
        VStack {
            header
                .onAppear {
                    isAutoSaveOn = UserSettings.autoAddToHistory
                }
                .onChange(of: isAutoSaveOn) { newValue in
                    mainViewModel.toggleAddToHistory()
                }
            
            Spacer()
                .frame(height: 16)
            
//            if (mainViewModel.userModel?.totalCredits ?? 0) <= 0 {
//                Button {
//                    withAnimation {
//                        mainViewModel.SCREEN_VIEW = .Purchase
//                    }
//                } label: {
//                    Image(.imgBanner)
//                        .resizable()
//                        .frame(width: UIScreen.screenWidth - 32, height: 120)
//                        .scaledToFit()
//                        .clipShape(RoundedRectangle(cornerRadius: 8))
//                }
//            }

            
            Spacer()
                .frame(height: 24)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    
                    HStack {
                        
                        Text("General")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(Color(hex: textColor))
                        
                        Spacer()
                    }
                    
                    Spacer()
                        .frame(height: 6)
                    
                    Button(action: {
                        withAnimation {
                            mainViewModel.SCREEN_VIEW = .PurchaseHistory
                        }
                    }, label: {
                        HStack {
                            
                            Image(.iconSettingsCreditHistory)
                                .resizable()
                                .frame(width: 32, height: 32)
                            
                            Text("  Credit Status")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(Color(hex: textColor))
                            
                            Spacer()
                            
                            Image(.iconBack)
                                .resizable()
                                .rotationEffect(.degrees(180))
                                .frame(width: 32, height: 32)
                            
                        }.frame(height: 48)
                    })
                    
                    Button(action: {
                        withAnimation {
                            mainViewModel.SCREEN_VIEW = .Purchase
                        }
                    }, label: {
                        HStack {
                            
                            Image(.iconVip)
                                .resizable()
                                .frame(width: 32, height: 32)
                            
                            Text("  More Credits")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(Color(hex: textColor))
                            
                            Spacer()
                            
                            Image(.iconBack)
                                .resizable()
                                .rotationEffect(.degrees(180))
                                .frame(width: 32, height: 32)
                            
                        }.frame(height: 48)
                    })
                    
                    ShareLink(item: "🔥Download AI Video Face Swap now and start creating your own amazing videos to share with everyone!🔥\n\n\nhttps://apps.apple.com/us/app/faceswap-ai-video-swap-faces/id6738142537", label: {
                        HStack {
                            
                            Image(.iconShare)
                                .resizable()
                                .frame(width: 32, height: 32)
                            
                            Text("  Share App")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(Color(hex: textColor))
                            
                            Spacer()
                            
                            Image(.iconBack)
                                .resizable()
                                .rotationEffect(.degrees(180))
                                .frame(width: 32, height: 32)
                            
                        }.frame(height: 48)
                    })
                    
                    Button(action: {
                        showClearHistoryConfirm = true
                    }, label: {
                        HStack {
                            
                            Image(.iconSettingsTrash)
                                .resizable()
                                .frame(width: 32, height: 32)
                            
                            Text("  Clear All History")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(Color(hex: textColor))
                            
                            Spacer()
                            
                            if isClearingHistory {
                                ProgressView()
                                    .frame(width: 32, height: 32)
                            } else {
                                Image(.iconBack)
                                    .resizable()
                                    .rotationEffect(.degrees(180))
                                    .frame(width: 32, height: 32)
                            }
                            
                        }.frame(height: 48)
                    })
                    .disabled(isClearingHistory)
                    
                    Button(action: {
                        isAutoSaveOn.toggle()
                    }, label: {
                        HStack {
                            
                            Image(.iconHistory)
                                .resizable()
                                .frame(width: 32, height: 32)
                            
                            Text("  Add to History")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(Color(hex: textColor))
                            
                            Spacer()
                            
                             Toggle("", isOn: $isAutoSaveOn)
                                .tint(Color.init(hex: "#00C6FF"))
                            
                        }.frame(height: 48)
                    })
                    
                }.padding(.horizontal, 16)
                
                Spacer()
                    .frame(height: 16)
                
                VStack(spacing: 0) {
                    
                    HStack {
                        
                        Text("Feedback")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(Color(hex: textColor))
                        
                        Spacer()
                    }
                    
                    Spacer()
                        .frame(height: 6)
                    
                    Button(action: {
                        mainViewModel.email.send(openUrl: mainViewModel.openURL)
                    }, label: {
                        HStack {
                            
                            Image(.iconContactUs)
                                .resizable()
                                .frame(width: 32, height: 32)
                            
                            Text("  Contact Us")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(Color(hex: textColor))
                            
                            Spacer()
                            
                            Image(.iconBack)
                                .resizable()
                                .rotationEffect(.degrees(180))
                                .frame(width: 32, height: 32)
                            
                        }.frame(height: 48)
                    })
                    
                    Button(action: {
                        if let userId = mainViewModel.userModel?.id {
                            UIPasteboard.general.string = userId
                            showCopiedAlert = true
                        }
                    }, label: {
                        HStack {

                            Image(.iconUserId)
                                .resizable()
                                .frame(width: 32, height: 32)

                            Text("  User Id")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(Color(hex: textColor))

                            Spacer()

                            Text(mainViewModel.userModel?.id ?? "")
                                .font(.system(size: 13))
                                .foregroundStyle(Color(hex: textColor))
                            
                            Spacer()
                                .frame(width: 8)
                            
                            Image(.iconCopy)
                                .resizable()
                                .frame(width: 32, height: 32)
                        }
                        .frame(height: 48)
                    })
                    
//                    Button(action: {
//                        requestReview()
//                    }, label: {
//                        HStack {
//                            
//                            Image(.iconRate)
//                                .resizable()
//                                .frame(width: 32, height: 32)
//                            
//                            Text("  Rate & Review")
//                                .font(.system(size: 16, weight: .semibold))
//                                .foregroundStyle(Color(hex: textColor))
//                            
//                            Spacer()
//                            
//                            Image(.iconBack)
//                                .resizable()
//                                .rotationEffect(.degrees(180))
//                                .frame(width: 32, height: 32)
//                            
//                        }.frame(height: 48)
//                    })
//                    
                }.padding(.horizontal, 16)
                
                Spacer()
                    .frame(height: 16)
                
                VStack(spacing: 0) {
                    
                    HStack {
                        
                        Text("Terms")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(Color(hex: textColor))
                        
                        Spacer()
                    }
                    
                    Spacer()
                        .frame(height: 6)
                    
                    Button {
                        withAnimation {
                            mainViewModel.SCREEN_VIEW = .AiNotice
                        }
                    } label: {
                        HStack {
                            
                            Image(.iconAi)
                                .resizable()
                                .frame(width: 32, height: 32)
                            
                            Text("  How AI Uses Your Data")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(Color(hex: textColor))
                            
                            Spacer()
                            
                            Image(.iconBack)
                                .resizable()
                                .rotationEffect(.degrees(180))
                                .frame(width: 32, height: 32)
                            
                        }.frame(height: 48)
                    }

                    
                    Spacer()
                        .frame(height: 6)
                    
                    Link(destination: URL(string: termsOfServiceLink)!, label: {
                        HStack {
                            
                            Image(.iconTerms)
                                .resizable()
                                .frame(width: 32, height: 32)
                            
                            Text("  Terms of use")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(Color(hex: textColor))
                            
                            Spacer()
                            
                            Image(.iconBack)
                                .resizable()
                                .rotationEffect(.degrees(180))
                                .frame(width: 32, height: 32)
                            
                        }.frame(height: 48)
                    })
                    
                    Link(destination: URL(string: privacyPolicyLink)!) {
                        HStack {
                            
                            Image(.iconPrivacy)
                                .resizable()
                                .frame(width: 32, height: 32)
                            
                            Text("  Privacy Policy")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(Color(hex: textColor))
                            
                            Spacer()
                            
                            Image(.iconBack)
                                .resizable()
                                .rotationEffect(.degrees(180))
                                .frame(width: 32, height: 32)
                            
                        }.frame(height: 48)
                    }
                    
                }.padding(.horizontal, 16)
            }
        }
        .alert("Copied!", isPresented: $showCopiedAlert) {
            Button("OK", role: .cancel) {}
        }
        .alert("Confirm Deletion?", isPresented: $showClearHistoryConfirm) {
            Button("Cancel", role: .cancel) {}
            Button("Yes, Delete it", role: .destructive) {
                isClearingHistory = true
                mainViewModel.clearAllSwapHistory { _ in
                    isClearingHistory = false
                }
            }
        } message: {
            Text("Are you sure you want to delete All history?")
        }
        .sheet(isPresented: $showContactUsBottomSheet, content: {
            ContactUsView(showContactUsBottomSheet: $showContactUsBottomSheet)
        })
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(Rectangle())
        .swipeBack {
            withAnimation {
                mainViewModel.SCREEN_VIEW = .Main
            }
        }
    }
}

struct ContactUsView : View {
    
    @EnvironmentObject var mainViewModel : MainViewModel
    @State var contactUsText = ""
    @Binding var showContactUsBottomSheet:Bool
    
    var body: some View {
            ZStack {
                
                Color.init(hex: "#1B1B1E")
                    .ignoresSafeArea()
                
                VStack(spacing: 16) {
                    
                    Text("Contact US")
                        .font(.system(size: 18))
                        .bold()
                        .foregroundStyle(Color.white)
                    
                    
                    Divider()
                    
                    Text("If you need assistance or have questions while using our app, feel free to reach out. Our support team is dedicated to helping you every step of the way, ensuring a seamless and enjoyable experience.")
                        .multilineTextAlignment(.center)
                        .font(.system(size: 12))
                        .foregroundStyle(Color.white)
                        .padding(.horizontal, 24)
                    
                    
                    VStack {
                        
                        TextEditor(text: $contactUsText)
                            .scrollContentBackground(.hidden) // <- Hide it
                            .foregroundStyle(Color.white)
                            .background(Color(hex: "#2A2A2D"))
                                .font(.system(size: 14))
                                .clipShape(RoundedRectangle(cornerRadius: 4))
                                .roundedCornerWithBorder(lineWidth: 1, borderColor: Color(hex: "#3ECCF8"), radius: 10, corners: .allCorners)
                                .padding(12)
                            
                        
                    }.frame(width: UIScreen.screenWidth - 16, height: 200)
                        .shadow(radius: 4)
                        
                        
                    HStack {
                        
                        Button {
                            showContactUsBottomSheet = false
                            mainViewModel.sendContactUs(message: contactUsText)
                            contactUsText = ""
                        } label: {
                            Text("Send Your Feedback")
                                .foregroundStyle(.white)
                                .font(.system(size: 16))
                                .frame(maxWidth: .infinity, minHeight: 55)
                                .background {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color(hex: "#3ECCF8"))
                                }
                        }
                        
                    }.padding(.horizontal, 16)
                    
                    
                }.presentationDetents([.height(470)])
            }
    }
}
