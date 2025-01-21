//
//  VideoTabView.swift
//  VideoFaceSwap
//
//  Created by Javad on 11/3/24.
//

import SwiftUI
import AVKit

struct VideoTabView: View {
    
    @State var templates : [TemplateModel] = []
    
    
    
    @EnvironmentObject var mainViewModel : MainViewModel
    
    let category : CategoryModel
    
    var body: some View {
        let gridItems = [GridItem(.flexible()), GridItem(.flexible())]
        HStack {
            
            VStack {
                
            }.onAppear {
                mainViewModel.getTemplateForCategoryById(id: category.id) { templates, err in
                    self.templates = templates ?? []
                }
            }
            
            ScrollView(showsIndicators: false) {
                LazyVGrid(columns: gridItems, content: {
                    ForEach(templates, id: \.id) { item in
                        
                        eachItem(templates: $templates,item: item)
                        
                    }
                }).padding(.horizontal, 16)
                
            }
            
            
        }
    }
    
    func getDimesion() -> (Int, Bool) {
            var toReturn = (0, false)
        if templates.count.isMultiple(of: 2) {
                toReturn = ( templates.count / 2, false)
            }else {
                toReturn = (( templates.count - 1) / 2, true)
            }
            return toReturn
        }
    
}

struct eachItem : View {
    
    @EnvironmentObject var mainViewModel : MainViewModel
    
    @Binding var templates : [TemplateModel]
    
    @State var player = AVPlayer()
    
    let item : TemplateModel
    
    var body: some View {
        VStack {
            Button {
                
                var tempos = templates
                print(tempos.count)
                
                let first = tempos.remove(at: tempos.firstIndex(where: { it in
                    return it.id == item.id
                })!)
                
                var list = [TemplateModel]()
                list.append(first)
                tempos.forEach { temp in
                    list.append(temp)
                }
                mainViewModel.templateItems = list
                withAnimation {
                    mainViewModel.SCREEN_VIEW = .Templates
                }
            } label: {
                VideoPlayer(player: player)
                    .onAppear {
                        print(item.templateLowResolutionUrl)
                        player = AVPlayer(url: URL(string: item.templateLowResolutionUrl)!)
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
                    .frame(width: (UIScreen.screenWidth - 40)/2, height: 220)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(alignment: .topTrailing) {
                        if item.isFree == false {
                            Image(.iconPremiumAccent)
                                .padding(8)
                        }
                    }
                    
            }
        }
    }
}

struct LoopingVideoPlayer: UIViewControllerRepresentable {
    let player: AVQueuePlayer
    let looper: AVPlayerLooper?

    init(videoURL: URL) {
        // Create an AVQueuePlayer for looping
        player = AVQueuePlayer()
        
        // Create an AVPlayerItem with the video URL
        let playerItem = AVPlayerItem(url: videoURL)
        
        // Use AVPlayerLooper for continuous looping
        looper = AVPlayerLooper(player: player, templateItem: playerItem)
        
        // Start playing
        player.play()
        player.volume = 0.0
    }
    
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.player = player
        controller.showsPlaybackControls = false // Hide controls if not needed
        return controller
    }
    
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        // No update logic needed for looping playback
    }
}
