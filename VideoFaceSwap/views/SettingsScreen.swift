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
            
            Spacer()
                .frame(height: 16)
            
            Button {
                withAnimation {
                    mainViewModel.SCREEN_VIEW = .Purchase
                }
            } label: {
                AsyncImage(url: URL(string: mainViewModel.homeConfig?.homeConfig?.icons?.bannerImage ?? "http://89.22.239.26/nexora-swap-ios-stage/public/home/5a7f7f0e-2c69-4d94-b833-77a6e13fbd1d.png")!, scale: 1.0) { img in
                    img.resizable()
                        .frame(width: UIScreen.screenWidth - 32, height: 120)
                        .scaledToFill()
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                } placeholder: {
                    Image(.background)
                        .frame(width: UIScreen.screenWidth - 32, height: 120)
                        .scaledToFill()
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }

            
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
                            mainViewModel.SCREEN_VIEW = .Purchase
                        }
                    }, label: {
                        HStack {
                            
                            Image(.iconVip)
                                .resizable()
                                .frame(width: 24, height: 24)
                            
                            Text("  More Credits")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(Color(hex: textColor))
                            
                            Spacer()
                            
                            Image(.iconBack)
                                .resizable()
                                .rotationEffect(.degrees(180))
                                .frame(width: 24, height: 24)
                            
                        }.frame(height: 48)
                    })
                    
                    Button(action: {
                        
                    }, label: {
                        HStack {
                            
                            Image(.iconShare)
                                .resizable()
                                .frame(width: 24, height: 24)
                            
                            Text("  Share App")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(Color(hex: textColor))
                            
                            Spacer()
                            
                            Image(.iconBack)
                                .resizable()
                                .rotationEffect(.degrees(180))
                                .frame(width: 24, height: 24)
                            
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
                        withAnimation {
                            showContactUsBottomSheet = true
                        }
                    }, label: {
                        HStack {
                            
                            Image(.iconContactUs)
                                .resizable()
                                .frame(width: 24, height: 24)
                            
                            Text("  Contact Us")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(Color(hex: textColor))
                            
                            Spacer()
                            
                            Image(.iconBack)
                                .resizable()
                                .rotationEffect(.degrees(180))
                                .frame(width: 24, height: 24)
                            
                        }.frame(height: 48)
                    })
                    
                    Button(action: {
                        
                    }, label: {
                        HStack {
                            
                            Image(.iconRate)
                                .resizable()
                                .frame(width: 24, height: 24)
                            
                            Text("  Rate & Review")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(Color(hex: textColor))
                            
                            Spacer()
                            
                            Image(.iconBack)
                                .resizable()
                                .rotationEffect(.degrees(180))
                                .frame(width: 24, height: 24)
                            
                        }.frame(height: 48)
                    })
                    
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
                    
                    Button(action: {
                        
                    }, label: {
                        HStack {
                            
                            Image(.iconTerms)
                                .resizable()
                                .frame(width: 24, height: 24)
                            
                            Text("  Terms of use")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(Color(hex: textColor))
                            
                            Spacer()
                            
                            Image(.iconBack)
                                .resizable()
                                .rotationEffect(.degrees(180))
                                .frame(width: 24, height: 24)
                            
                        }.frame(height: 48)
                    })
                    
                    Button(action: {
                        
                    }, label: {
                        HStack {
                            
                            Image(.iconPrivacy)
                                .resizable()
                                .frame(width: 24, height: 24)
                            
                            Text("  Privacy Policy")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(Color(hex: textColor))
                            
                            Spacer()
                            
                            Image(.iconBack)
                                .resizable()
                                .rotationEffect(.degrees(180))
                                .frame(width: 24, height: 24)
                            
                        }.frame(height: 48)
                    })
                    
                }.padding(.horizontal, 16)
            }
        }.sheet(isPresented: $showContactUsBottomSheet, content: {
            ContactUsView(showContactUsBottomSheet: $showContactUsBottomSheet)
        })
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
                    
                    
                    Text("We're Here to Support You!")
                        .font(.system(size: 16))
                        .bold()
                        .foregroundStyle(Color.white)
                    
                    
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
