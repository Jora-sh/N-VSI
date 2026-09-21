//
//  ResultScreen 2.swift
//  VideoFaceSwap
//
//  Created by Javad on 9/19/26.
//

import SwiftUI
import Photos
import _AVKit_SwiftUI
import SDWebImageSwiftUI

struct ResultImageScreen: View {
    
    @EnvironmentObject var mainViewModel : MainViewModel
    @EnvironmentObject var swapViewModel : SwapViewModel
    
    @State var isShowing = true
    
    @State var saveState : SaveState = .Idle
    
    @State var showContactUsBottomSheet = false
    
    @State private var imageToShare: UIImage?
    @State private var showShareSheet = false
    
    
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
//                withAnimation {
//                    showContactUsBottomSheet = true
//                }
            } label: {
                Image(.iconContactUs)
                    .resizable()
                    .frame(width: 24, height: 24)
                    .padding(.vertical, 8)
                    .opacity(0.0)
            }
            
            
        }
        .overlay {
            
            Text("Result")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(.white)
            
        }
        .frame(width: UIScreen.screenWidth - 32)
    }
    
    var body: some View {
        VStack {
            
            header
            
            ZStack {
                
                AsyncImage(url: URL(string: swapViewModel.resultImageModel?.imageUrl ?? "https://swp.yagorai.com/nexora-swap-web-ios/public/uploads/swap_2ee3f89c-b939-49e2-85a6-d5953500d240.png")!, scale: 1.0) { img in
                    img.resizable()
                        .resizable()
                        .scaledToFit()
                        .frame(width: (UIScreen.screenWidth - 32), height: UIScreen.screenHeight - 280)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .onAppear {
                            mainViewModel.isOnVideoHistory = false
                            print("\(swapViewModel.resultImageModel?.imageUrl ?? "")")
                            print("\(swapViewModel.resultImageModel)")
                        }
                } placeholder: {
                    Image(.imgThumbnailResult)
                        .resizable()
                        .scaledToFill()
                        .frame(width: (UIScreen.screenWidth - 32), height: UIScreen.screenHeight - 280)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .onAppear {
                            print("\(swapViewModel.resultImageModel?.imageUrl ?? "")")
                            print("\(swapViewModel.resultImageModel)")
                        }
                }
                
//                WebImage(url: URL(string: "https://swp.yagorai.com/nexora-swap-web-ios/public/uploads/swap_2ee3f89c-b939-49e2-85a6-d5953500d240.png"))
//                    .resizable()
//                    .scaledToFit()
//                    .frame(width: (UIScreen.screenWidth - 32), height: UIScreen.screenHeight - 280)
//                    .clipShape(RoundedRectangle(cornerRadius: 8))
//                    .onAppear {
//                        print("\(swapViewModel.resultImageModel?.imageUrl ?? "")")
//                        print("\(swapViewModel.resultImageModel)")
//                    }
                
                
            }
            
            Spacer()
                .frame(height: 24)
            
            Button(action: {
                withAnimation {
                    mainViewModel.SCREEN_VIEW = .Main
                }
            }, label: {
                HStack {
                    
                    Text("Swap Again")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)
                    
                }
                .frame(width: UIScreen.screenWidth - 32, height: 48)
                .background {
                    LinearGradient(colors: gradientColor, startPoint: .leading, endPoint: .trailing)
                }
                .clipShape(RoundedRectangle(cornerRadius: 8))
            })
            
            HStack {
                Button(action: {
                    if saveState == .Idle {
                        downloadAndSaveImage()
                    }
                    
                }, label: {
                    HStack {
                        
                        Image(.iconDownloadResult)
                            .resizable()
                            .frame(width: 24,height: 24)
                        
                        Text(getSaveStateText())
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.white)
                        
                    }
                    .frame(width: (UIScreen.screenWidth - 40)/2, height: 48)
                    .background {
                        LinearGradient(colors: gradientColor, startPoint: .leading, endPoint: .trailing)
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                })
                
                Button(action: {
                    
                    downlaodImageAndShare()
                    
                }, label: {
                    HStack(spacing: 10) {
                        
                        Image(.iconShareResult)
                            .resizable()
                            .frame(width: 24,height: 24)
                        
                        Text("Share")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.white)
                        
                    }
                    .frame(width: (UIScreen.screenWidth - 40)/2, height: 48)
                    .background {
                        LinearGradient(colors: gradientColor, startPoint: .leading, endPoint: .trailing)
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                })
            }
            
            Spacer()
                .frame(height: 16)
            
            .sheet(isPresented: $showContactUsBottomSheet, content: {
                ContactUsView(showContactUsBottomSheet: $showContactUsBottomSheet)
            })
            .sheet(isPresented: $showShareSheet) {
                    if let image = imageToShare {
                        ShareSheet(activityItems: [image])
                    }
                }
        }
    }
    
    func getSaveStateText() -> String {
        return switch saveState {
        case .Idle:
            "Save"
        case .Saving:
            "Saving..."
        case .Saved:
            "Photo Saved!"
        }
    }
    
    func downloadAndSaveImage() {
        saveState = .Saving
            
        URLSession.shared.dataTask(with: URL(string: swapViewModel.resultImageModel?.imageUrl ?? "")!) { data, response, error in
            guard let data = data, let image = UIImage(data: data), error == nil else {
                saveState = .Idle
                return
            }
            
            // Request permission if needed
            PHPhotoLibrary.requestAuthorization { status in
                if status == .authorized || status == .limited {
                    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                    withAnimation {
                        saveState = .Saved
                    }
                } else {
                    saveState = .Idle
                }
            }
        }.resume()
    }
    
    func downlaodImageAndShare() {
//        shareState = .Progress
        URLSession.shared.dataTask(with: URL(string: swapViewModel.resultImageModel?.imageUrl ?? "")!) { data, _, error in
            guard let data = data, let image = UIImage(data: data), error == nil else {
                print("Failed to download image")
//                   shareState = .Idle
                return
            }
            DispatchQueue.main.async {
                self.imageToShare = image
                self.showShareSheet = true
//                shareState = .Done
            }
        }.resume()
    }
    
}

struct ShareSheet: UIViewControllerRepresentable {
    var activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems,
                                 applicationActivities: applicationActivities)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // no update needed
    }
}
