//
//  HistoryScreen.swift
//  VideoFaceSwap
//
//  Created by Javad on 1/29/25.
//

import SwiftUI
import Photos
import _AVKit_SwiftUI
import SDWebImageSwiftUI

struct HistoryScreen: View {
    
    @EnvironmentObject var mainViewModel : MainViewModel
    @EnvironmentObject var swapViewModel : SwapViewModel
    
    @State var saveState : SaveState = .Idle

    @State var showDialog = false
    
    @State var showSuccessfullySavedDialog = false
    
    @State var selectedItem : CreationModel? = nil
    @State var showNoHistoryDialog = false
    
    @Binding var homeBottomBarSelected : BottomBar

    
    var body: some View {
        let gridItems = [GridItem(.flexible()), GridItem(.flexible())]

        ZStack {
            VStack {
                
                if homeBottomBarSelected == .Home {
                    Spacer()
                        .frame(height: 54)
                        
                }
                   
                Spacer()
                    .frame(height: 16)
                
                if !mainViewModel.isHistoryLoading {
                    ScrollView(showsIndicators: false) {
                        LazyVGrid(columns: gridItems, content: {
                            ForEach(mainViewModel.historyList, id: \.vidUrl) { item in
                                
                                Button {
                                    if item.isLoading == false {
                                        swapViewModel.resultModel = CheckForVideoResponseModel(success: true, isLoading: false, vidUrl: item.vidUrl, message: "")
                                        withAnimation {
                                            mainViewModel.SCREEN_VIEW = .Result
                                        }
                                    }
                                } label: {
                                    HistoryItemView(item: item,
                                                    saveState: $saveState,
                                                    selectedItem: $selectedItem,
                                                    showDialog: $showDialog)
                                }

                                
                            }
                        }).padding(.horizontal, 24)
                            .alert("Saved!", isPresented: $showSuccessfullySavedDialog, actions: {
                                Button("Ok") {
                                    
                                }
                            }, message: {
                                Text("Video Successfully Saved! enjoy..")
                            })
                            .alert("Delete Video?", isPresented: $showDialog, presenting: selectedItem) { item in
                                Button("Cancel", role: .cancel) {}
                                Button("Delete", role: .destructive) {
                                    if let jobId = item.jobId, !jobId.isEmpty {
                                        if let index = mainViewModel.historyList.firstIndex(where: { $0.jobId == jobId }) {
                                            withAnimation {
                                                _ = mainViewModel.historyList.remove(at: index)
                                            }
                                        }
                                        mainViewModel.deleteSwapHistoryItem(jobId: jobId) { _ in
//                                            mainViewModel.getMyCreations { _ in }
                                        }
                                    }
                                }
                            } message: { _ in
                                Text("This will permanently delete this video. This action cannot be undone.")
                            }
                    }
                    
                } else {
                    Spacer()
                }
                
            }.refreshable {
                mainViewModel.getMyCreations{_ in}
            }
            
            NoHistoryDialog(shown: $showNoHistoryDialog) {
                withAnimation {
                    homeBottomBarSelected = .Home
                    mainViewModel.SCREEN_VIEW = .Main
                }
            }
            
            VStack {
                Spacer()
                ProgressView()
                Spacer()
            }
            .opacity(mainViewModel.isHistoryLoading ? 1.0 : 0.0)
            .onAppear(perform: {
                mainViewModel.getMyCreations{_ in}
                if mainViewModel.historyList.count == 0 {
                    showNoHistoryDialog = true
                } else {
                    showNoHistoryDialog = false
                }
            })
        }
        
    }
}

struct HistoryItemView: View {
    
    let item: CreationModel
    
    @State private var player: AVPlayer = AVPlayer()
    @State private var isVideoReady: Bool = false
    @State private var playerObserver: NSKeyValueObservation? = nil
    @State private var isSharing: Bool = false
    
    @Binding var saveState: SaveState
    @Binding var selectedItem: CreationModel?
    @Binding var showDialog: Bool
    
    var body: some View {
        ZStack {

            WebImage(url: URL(string: item.thumbnailUrl ?? "")) { img in
                img
                    .resizable()
                    .scaledToFill()
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            } placeholder: {
                Image(.imgThumbnailSmall)
                    .resizable()
                    .scaledToFill()
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .frame(width: (UIScreen.screenWidth - 64)/2, height: ((UIScreen.screenWidth - 64)/2) * 16/9)
            .scaledToFill()
            .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(alignment: .bottom) {
                    LinearGradient(
                        colors: [.black,.black.opacity(0.0)],
                        startPoint: .bottom,
                        endPoint: .center
                    )
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(alignment: .bottom) {
                            HStack {
                                Button {
                                    selectedItem = item
                                    showDialog = true
                                } label: {
                                    Image(.iconTrash)
                                        .resizable()
                                        .frame(width: 24, height: 24)
                                        .padding(3)
                                }

                                Spacer()
                                
                                Button {
                                    shareVideo()
                                } label: {
                                    ZStack {
                                        Image(.iconShareHistory)
                                            .resizable()
                                            .frame(width: 24, height: 24)
                                            .padding(3)
                                            .opacity(isSharing ? 0 : 1)
                                        if isSharing {
                                            ProgressView()
                                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        }
                                    }
                                }
                                .disabled(isSharing)
                                
                            }.padding(.horizontal, 12)
                                .padding(.vertical)
                        }
                    
                }
        }
        .frame(width: (UIScreen.screenWidth - 64)/2, height: ((UIScreen.screenWidth - 64)/2) * 16/9)
    }

    func shareVideo() {
        guard let vidUrlString = item.vidUrl,
              let url = URL(string: vidUrlString) else {
            return
        }

        isSharing = true

        DispatchQueue.global(qos: .background).async {
            if let urlData = NSData(contentsOf: url) {
                let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
                let fileURL = URL(fileURLWithPath: "\(documentsPath)/VideoFaceSwap.mp4")
                urlData.write(to: fileURL, atomically: true)
                DispatchQueue.main.async {
                    isSharing = false
                    share(items: [fileURL])
                }
            } else {
                DispatchQueue.main.async {
                    isSharing = false
                }
            }
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

struct NoHistoryDialog: View {
    
    @EnvironmentObject var mainViewModel : MainViewModel
    
    @Binding var shown : Bool
    
    var onTryFaceSwapClicked : () -> Void
    
    var body: some View {
        ZStack(alignment:.center) {
            
            Color.black
                .opacity(shown ? 0 : 0.0)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation {
                        shown = false
                    }
                }
            
                
            ZStack(alignment:.top) {
                
                VStack {
                    
                    Image(.iconNoHistory)
                        .resizable()
                        .frame(width: 210, height: 210)
                    
                    VStack {
                        
                        Text("No Videos Yet")
                            .foregroundStyle(.white)
                            .font(.system(size: 20, weight: .heavy))
                        
                        Spacer()
                            .frame(height: 12)
                        
                        Text("You haven’t created any videos yet.")
                            .multilineTextAlignment(.center)
                            .bold()
                            .foregroundStyle(Color(hex: "#757575"))
                            .font(.system(size: 16))
                        
                        Spacer()
                            .frame(height: 24)
                        
                        Button {
                            withAnimation {
                                shown = false
                            }
                            onTryFaceSwapClicked()
                        } label: {
                            
                            HStack {
                                
                                Image(.iconAdd)
                                    .resizable()
                                    .frame(width: 24, height: 24)
                                
                                Spacer()
                                    .frame(width: 8)
                                
                                Text("Make Your First Video")
                                    .font(.system(size: 18 , weight: .semibold))
                                    .foregroundColor(.white)
                            }
                            
                            .padding(.vertical, 16)
                            .frame(width: UIScreen.screenWidth - 110, height: 48)
                            .background(
                                LinearGradient(
                                    colors: [
                                        Color(hex: "#00C6FF"),
                                        Color(hex: "#068FFF")
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .cornerRadius(10)
                        }
                        .padding(.bottom , 24)
                        
                    }.frame(width: UIScreen.screenWidth - 72)
                        
                    
                }
                
            }.offset(y: -0)
            
            
        }.opacity((mainViewModel.historyList.count == 0 && !mainViewModel.isHistoryLoading) ? 1.00 : 0.0)
            .offset(y:(mainViewModel.historyList.count == 0 && !mainViewModel.isHistoryLoading) ? 0 : UIScreen.screenHeight)
    }
}
