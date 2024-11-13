//
//  CustomScreen.swift
//  VideoFaceSwap
//
//  Created by Javad on 11/3/24.
//

import SwiftUI
import AVFoundation
import CoreTransferable
import _AVKit_SwiftUI
import _PhotosUI_SwiftUI

struct CustomScreen: View {
    
    @EnvironmentObject var swapViewModel: SwapViewModel
    @EnvironmentObject var mainViewModel: MainViewModel
    @State var videoURL : URL? = nil
    
    @State var player : AVPlayer? = nil
    
    @State var showNoCreditsLeftDialog : Bool = false
    @State var creditsNeeded : Int = 0
    
    @State var showErrorDialog: Bool = false
    
    var body: some View {
        ZStack {
            VStack {
                
                Spacer()
                    .onChange(of: swapViewModel.imageSelection) { item in
                        Task {
                            if let loaded = try? await swapViewModel.imageSelection?.loadTransferable(type: Image.self) {
                                swapViewModel.imageSelected = loaded.asUIImage()
                            } else {
                                print("Failed")
                            }
                        }
                    }
                    .onAppear(perform: {
                        mainViewModel.getMe()
                    })
                
                ZStack{
                    
                    PhotosPicker(
                        selection: $swapViewModel.imageSelection,
                          matching: .images,
                          photoLibrary: .shared()) {
                              if swapViewModel.imageSelected == nil {
                                  VStack {
                                      Image(.iconFace)
                                          .resizable()
                                          .aspectRatio( contentMode: .fill)
                                          .frame(width: 36 , height: 36)
                                          .padding(.bottom , 18)
                                      
                                      Text("Tap Here")
                                          .font(.system(size: 18 , weight: .medium))
                                          .foregroundColor(Color.white)
                                          .padding(.bottom , 0)
                                      
                                      Text("to select the photo")
                                          .font(.system(size: 16 ))
                                          .foregroundColor(Color.white)
                                          .padding(.top , 5)
                                      
                                  }
                                  .frame(width: UIScreen.screenWidth - 192 , height: UIScreen.screenWidth - 192)
                              }else {
                                  
                                  ZStack {
                                      Image(uiImage: swapViewModel.imageSelected!)
                                          .resizable()
                                          .aspectRatio( contentMode: .fill)
                                          .frame(width: UIScreen.screenWidth - 120 , height: UIScreen.screenWidth - 192)
                                          .cornerRadius(10)
                                          .padding()
                                      
                                      VStack {
                                          
                                          HStack {
                                              
                                              Spacer()
                                              
                                              Button {
                                                  withAnimation {
                                                      swapViewModel.imageSelected = nil
                                                  }
                                              } label: {
                                                  Image(.iconClose)
                                                      .resizable()
                                                      .frame(width: 22, height:22)
                                              }

                                          }
                                          
                                          Spacer()
                                          
                                      }.padding(24)
                                  }
                                   
                                  
                              }
                          }
                          .frame(width: UIScreen.screenWidth - 120 , height: UIScreen.screenWidth - 192)
                          .background(Color(hex: "#1B1B1E"))
                          .cornerRadius(16)
                          .padding(.bottom , 18)
                    
                }
                
                
                
                //MARK: switch images button
                
                Image(.iconDoubleArrow)
                    .resizable()
                    .frame(width: 64, height: 64)
                
                ZStack {
                    
                    PhotosPicker(
                        selection: $swapViewModel.videoSelection,
                          matching: .videos,
                          photoLibrary: .shared()) {
                        if swapViewModel.videoSelection == nil {
                            VStack {
                                Image(.iconVideo)
                                    .resizable()
                                    .aspectRatio( contentMode: .fill)
                                    .frame(width: 36 , height: 36)
                                    .padding(.bottom , 18)
                                
                                Text("Tap Here")
                                    .font(.system(size: 18 , weight: .medium))
                                    .foregroundColor(.white)
                                    .padding(.bottom , 0)
                                
                                Text("to select the Video")
                                    .font(.system(size: 16 ))
                                    .foregroundColor(.white)
                                    .padding(.top , 5)
                                
                            }
                            .frame(width: UIScreen.screenWidth - 192 , height: UIScreen.screenWidth - 192)
                        } else {
                            
                            ZStack {
                                VideoPlayer(player: player)
                                    .frame(width: UIScreen.screenWidth - 120 , height: UIScreen.screenWidth - 192)
                                VStack {
                                    
                                    HStack {
                                        
                                        Spacer()
                                        
                                        Button {
                                            withAnimation {
                                                swapViewModel.videoSelection = nil
                                            }
                                        } label: {
                                            Image(.iconClose)
                                                .resizable()
                                                .frame(width: 22, height:22)
                                        }
                                        
                                    }
                                    
                                    Spacer()
                                    
                                }.padding(24)
                            }
                            
                        }
                    }.onChange(of:  swapViewModel.videoSelection) { newMedia in
                        Task {
                            guard let item = swapViewModel.videoSelection else {  return }
                            let config = VideoKit.Config(.presetMediumQuality,
                                                         limitFPS: 23,
                                                         limitBitrate: 2_500_000)

                            item.loadTransferable(type: Movie.self) { result in   // <-- here
                                switch result {
                                case .success(let movie):
                                    
                                    if let movie = movie {
                                        VideoKit.mutate(videoUrl: movie.url, config: config) { result in
                                            switch result {
                                                case .success(let videoUrl):
                                                    // DO SOMETHING WITH YOUR VIDEO
                                                player = AVPlayer(url: videoUrl)
                                                player?.volume = 0.0
                                                player?.play()
                                                videoURL = videoUrl
                                                swapViewModel.videoUrl = videoUrl
                                                    break
                                                case .error(let errorString):
                                                    print(errorString)
                                                break
                                            }
                                        }
                                    } else {
                                        print("movie is nil")
                                    }
                                case .failure(let failure):
                                    fatalError("\(failure)")
                                }
                            }
                        }
                    }
                        
                    .frame(width: UIScreen.screenWidth - 120 , height: UIScreen.screenWidth - 192)
                    .background(Color(hex: "#1B1B1E"))
                    .cornerRadius(16)
                    .padding(.top , 18)
                }
                
                    
                
                Spacer()
                //MARK: START SWAPING BUTTON
                Button {
                    if UserSettings.videoIsWorking {
                        if swapViewModel.imageSelected != nil && swapViewModel.videoSelection != nil {
                            creditsNeeded =  Int(self.player?.currentItem?.asset.duration.seconds ?? 10.0)
                            
                            if swapViewModel.imageSelected != nil && swapViewModel.videoSelection != nil {
                                
                                if (Int(self.player?.currentItem?.asset.duration.seconds ?? 10.0) < 10 && (mainViewModel.userModel?.credits ?? 0) < 10) || (mainViewModel.userModel?.credits ?? 0) - Int(self.player?.currentItem?.asset.duration.seconds ?? 10.0) <= 0 {
                                    
                                    withAnimation {
                                        self.showNoCreditsLeftDialog.toggle()
                                    }
                                    
                                } else {
                                    
                                    withAnimation {
                                        mainViewModel.SCREEN_VIEW = .Loading
                                    }
                                }
                            }
                        }
                    } else {
                        withAnimation {
                            showErrorDialog = true
                        }
                    }
                } label: {
                    HStack{
                        Text("Start Swapping")
                            .foregroundColor(.white)
                            .opacity(swapViewModel.imageSelected != nil && swapViewModel.videoSelection != nil ? 1.0 : 0.3)
                            .font(.system(size: 20 , weight: .medium))
                    }
                    .frame(width: UIScreen.screenWidth - 78 , height: UIScreen.screenHeight / 17)
                    .background(
                        swapViewModel.imageSelected != nil && swapViewModel.videoSelection != nil ?
                        LinearGradient(
                            colors: gradientColor,
                            startPoint: .leading,
                            endPoint: .trailing
                        ) : LinearGradient(
                            stops: [
                                Gradient.Stop(color: Color.white.opacity(0.5), location: 0.00),
                            ],
                            startPoint: UnitPoint(x: 0, y: 0.5),
                            endPoint: UnitPoint(x: 1, y: 0.5)
                            )
                    )
                    .cornerRadius(10)
                }
                
                Spacer()
                
                
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
            
        }
    }
}




struct Movie: Transferable {
  let url: URL

  static var transferRepresentation: some TransferRepresentation {
    FileRepresentation(contentType: .movie) { movie in
      SentTransferredFile(movie.url)
    } importing: { receivedData in
      let fileName = receivedData.file.lastPathComponent
      let copy: URL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)

      if FileManager.default.fileExists(atPath: copy.path) {
        try FileManager.default.removeItem(at: copy)
      }

      try FileManager.default.copyItem(at: receivedData.file, to: copy)
      return .init(url: copy)
    }
  }
}


extension View {
// This function changes our View to UIView, then calls another function
// to convert the newly-made UIView to a UIImage.
    public func asUIImage() -> UIImage {
        let controller = UIHostingController(rootView: self)
        
 // Set the background to be transparent incase the image is a PNG, WebP or (Static) GIF
        controller.view.backgroundColor = .clear
        
        controller.view.frame = CGRect(x: 0, y: CGFloat(Int.max), width: 1, height: 1)
        UIApplication.shared.windows.first!.rootViewController?.view.addSubview(controller.view)
        
        let size = controller.sizeThatFits(in: UIScreen.main.bounds.size)
        controller.view.bounds = CGRect(origin: .zero, size: size)
        controller.view.sizeToFit()
        
// here is the call to the function that converts UIView to UIImage: `.asUIImage()`
        let image = controller.view.asUIImage()
        controller.view.removeFromSuperview()
        return image
    }
}

extension UIView {
// This is the function to convert UIView to UIImage
    public func asUIImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
}
