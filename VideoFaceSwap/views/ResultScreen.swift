//
//  ResultScreen.swift
//  VideoFaceSwap
//
//  Created by Javad on 11/4/24.
//

import SwiftUI
import Photos

struct ResultScreen: View {
    
    @EnvironmentObject var mainViewModel : MainViewModel
    @EnvironmentObject var swapViewModel : SwapViewModel
    
    @State var isShowing = true
    
    @State var saveState : SaveState = .Idle
    
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
        VStack {
            
            header
            
            ZStack {
                
                LoopingVideoPlayer(videoURL: URL(string: swapViewModel.resultModel?.vidUrl ?? "")!)
                    .disabled(true) // Hides iOS video controls
                    .aspectRatio(contentMode: .fill)
                    .frame(width: (UIScreen.screenWidth - 32))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                
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
                        withAnimation {
                            saveState = .Saving
                        }
                        DispatchQueue.global(qos: .background).async {
                            if let url = URL(string: swapViewModel.resultModel?.vidUrl ?? ""),
                                let urlData = NSData(contentsOf: url)
                            {
                                let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0];
                                let filePath="\(documentsPath)/tempFile.mp4"
                                DispatchQueue.main.async {
                                    urlData.write(toFile: filePath, atomically: true)
                                    PHPhotoLibrary.shared().performChanges({
                                        PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: URL(fileURLWithPath: filePath))
                                    }) { completed, error in
                                        if completed {
                                            print("Video is saved!")
                                            withAnimation {
                                                saveState = .Saved
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                }, label: {
                    HStack {
                        
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
                    
                    DispatchQueue.global(qos: .background).async {
                        if let url = URL(string: swapViewModel.resultModel?.vidUrl ?? ""),
                            let urlData = NSData(contentsOf: url)
                        {
                            let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0];
                            let filePath="\(documentsPath)/tempFile.mp4"
                            DispatchQueue.main.async {
                                urlData.write(toFile: filePath, atomically: true)
                                share(items: ["", swapViewModel.resultModel?.vidUrl ?? ""])
                                
                                
                                
                            }
                        }
                    }
                    
                }, label: {
                    HStack {
                        
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
        }
    }
    
    func getSaveStateText() -> String {
        return switch saveState {
        case .Idle:
            "Save"
        case .Saving:
            "Saving..."
        case .Saved:
            "Video Saved!"
        }
    }
    
    @discardableResult
    func share(
        items: [Any],
        excludedActivityTypes: [UIActivity.ActivityType]? = nil
    ) -> Bool {
        guard let source = UIApplication.shared.windows.last?.rootViewController else {
            return false
        }
        let vc = UIActivityViewController(
            activityItems: items,
            applicationActivities: nil
        )
        vc.excludedActivityTypes = excludedActivityTypes
        vc.popoverPresentationController?.sourceView = source.view
        source.present(vc, animated: true)
        return true
    }
}


enum SaveState {
    case Idle
    case Saving
    case Saved
}
