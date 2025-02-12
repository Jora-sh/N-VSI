//
//  HistoryScreen.swift
//  VideoFaceSwap
//
//  Created by Javad on 1/29/25.
//

import SwiftUI
import Photos
import _AVKit_SwiftUI

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
                    }
                    
                } else {
                    Spacer()
                }
                
            }.refreshable {
                mainViewModel.getMyCreations()
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
                mainViewModel.getMyCreations()
                if mainViewModel.historyList.count == 0 {
                    showNoHistoryDialog = true
                } else {
                    showNoHistoryDialog = false
                }
            })
        }
        
    }
}

struct HistoryItemView : View {
    
    let item : CreationModel
    
    @State var player : AVPlayer = AVPlayer()
    
    @Binding var saveState : SaveState

    @Binding var selectedItem : CreationModel?
    
    @Binding var showDialog : Bool
    
    var body: some View {
        
        ZStack {
            VideoPlayer(player: player)
                .disabled(true)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .onAppear {
                    player = AVPlayer()
                    player = AVPlayer(url: URL(string: item.vidUrl ?? "")!)
                    player.play()
                    player.volume = 0.0
                }
                .onReceive(NotificationCenter
                    .default
                    .publisher(
                        for: .AVPlayerItemDidPlayToEndTime,
                        object: player.currentItem),
                           perform: { _ in
                                player.seek(to: .zero)
                                player.play()
                            }
                )
            
            
            
        }.frame(width: (UIScreen.screenWidth - 64)/2, height: ((UIScreen.screenWidth - 54)/2) + 20)
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
