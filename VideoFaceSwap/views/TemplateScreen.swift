//
//  TemplateScreen.swift
//  VideoFaceSwap
//
//  Created by Javad on 11/3/24.
//

import SwiftUI
import PhotosUI
import AVKit

struct TemplateScreen: View {
    
    @EnvironmentObject var mainViewModel  :MainViewModel
    @EnvironmentObject var swapViewModel  :SwapViewModel
    
    @State var isShowing = true
    @State var selected = ""
    
    @State var uiImage: UIImage? = nil
    @State var imageSelection: PhotosPickerItem? = nil
    
    @State var showNoCreditsLeftDialog : Bool = false
    @State var creditsNeeded : Int = 0
    
    @State var showErrorDialog: Bool = false
    
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
            
            Button {
                withAnimation {
                    mainViewModel.SCREEN_VIEW = .Purchase
                }
            } label: {
                HStack(spacing: 4) {
                    Image(.iconCoins)
                        .resizable()
                        .frame(width: 19, height: 19)
                        
                    Text(String(mainViewModel.userModel?.credits ?? 0))
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        
                }.padding(8).roundedCornerWithBorder(lineWidth: 1, borderColor: .white, radius: 8, corners: .allCorners)
                    
            }
            
            Spacer()
                .frame(width: 12)
            
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
            
        }
        .frame(width: UIScreen.screenWidth - 32)
    }
    
    var body: some View {
        ZStack {
            VStack {
                
                header
                    .onChange(of: imageSelection) { item in
                        Task {
                            print(selected)
                            if UserSettings.videoIsWorking {
                                if let loaded = try? await imageSelection?.loadTransferable(type: Image.self) {
                                    swapViewModel.imageToSwapWithTemplate = loaded.asUIImage()
                                    swapViewModel.templateToSwapWithTemplate = mainViewModel.templateItems.first(where: { item in
                                        return item.id == selected
                                    })
                                    print(selected)
                                    
                                    self.creditsNeeded = Int(swapViewModel.templateToSwapWithTemplate?.duration ?? 10.0)
                                    
                                    if (mainViewModel.userModel?.credits ?? 0) - Int(swapViewModel.templateToSwapWithTemplate?.duration ?? 10.0) <= 0 {
                                        
                                        withAnimation {
                                            self.showNoCreditsLeftDialog.toggle()
                                        }
                                        
                                    } else {
                                        
                                        withAnimation {
                                            mainViewModel.SCREEN_VIEW = .Loading
                                        }
                                    }
                                    
                                } else {
                                    print("Failed")
                                }
                            } else {
                                withAnimation {
                                    showErrorDialog = true
                                }
                            }
                        }
                    }
                TabView(selection: $selected) {
                    ForEach(mainViewModel.templateItems, id: \.id) { item in
                        
                        ZStack {
                            LoopingVideoPlayer(videoURL: URL(string: item.templateUrl)!)
                                .disabled(true) // Hides iOS video controls
                                .aspectRatio(contentMode: .fill)
                                .frame(width: (UIScreen.screenWidth - 32))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
//                            if isShowing {
//                                AsyncImage(
//                                    url: URL(string: item.thumbnailUrl),
//                                    content: { image in
//                                        image.resizable()
//                                            .aspectRatio(contentMode: .fit)
//                                            .clipShape(RoundedRectangle(cornerRadius: 8))
//                                            .frame(width: UIScreen.screenWidth - 32)
//                                    },
//                                    placeholder: {
//                                        ProgressView()
//                                    }
//                                )
//                            }
                        }.onAppear(perform: {
                            selected = item.id
//                            isShowing = true
//                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
//                                isShowing = false
//                            }
                        })
                        .tag(item.id)
                    }
                    
                }.tabViewStyle(.page(indexDisplayMode: .never))
                    
                
                Spacer()
                    .frame(height: 24)
                
                PhotosPicker(
                      selection: $imageSelection,
                      matching: .images,
                      photoLibrary: .shared()) {
                          HStack {
                              Image(.iconPremium)
                              Spacer()
                                  .frame(width: 6)
                              Text("Premium Swap")
                                  .font(.system(size: 16, weight: .bold))
                                  .foregroundStyle(.white)
                          }
                          .frame(width: UIScreen.screenWidth - 32, height: 48)
                          .background {
                              LinearGradient(colors: gradientColor, startPoint: .leading, endPoint: .trailing)
                          }
                          .clipShape(RoundedRectangle(cornerRadius: 8))
                      }
                
                Spacer()
                    .frame(height: 16)
                
            }
        }
        
        ErrorDialog(errorType: .Sorry, showDialog: $showErrorDialog) {
            
        }
        
        NoCreditsLeftDialog(shown: $showNoCreditsLeftDialog,
                            creditsOwned: .constant(mainViewModel.userModel?.credits ?? 0),
                            creditsNeeded: $creditsNeeded) {
            withAnimation {
                mainViewModel.SCREEN_VIEW = .Purchase
            }
        }
        .sheet(isPresented: $showContactUsBottomSheet, content: {
            ContactUsView(showContactUsBottomSheet: $showContactUsBottomSheet)
        })
    }
    
}


