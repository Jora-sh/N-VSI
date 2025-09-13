//
//  TemplateScreen.swift
//  VideoFaceSwap
//
//  Created by Javad on 11/3/24.
//

import SwiftUI
import PhotosUI
import AVKit
import Vision

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
    
    @State var selectedTemplate : TemplateModel? = nil
    @State var player : AVPlayer = AVPlayer()

    @State var showVideo = true
    
    @State private var showNoFaceDetected: Bool = false
    
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
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.white)
                        
                }.padding(.horizontal, 7)
                    .padding(.vertical,5).roundedCornerWithBorder(lineWidth: 1, borderColor: .white, radius: 8, corners: .allCorners)
                    
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
                    .frame(width: 32, height: 32)
                    .padding(.vertical, 8)
            }
            
        }
        .frame(width: UIScreen.screenWidth - 32)
    }
    
    var body: some View {
        ZStack {
            VStack {
                
                header
                    .onAppear(perform: {
                        selected = mainViewModel.templateItems[0].id
                        print(selected)
                        selectedTemplate = mainViewModel.templateItems[0]
                    })
                    .onDisappear(perform: {
                        player.volume = 0.0
                    })
                    .onChange(of: selected) { newValue in
                        player.pause()
                        selectedTemplate = mainViewModel.templateItems.first(where: { item in
                            return item.id == selected
                        })
                        showVideo = false
                        DispatchQueue.main.asyncAfter(deadline: .now()+1.0) {
                            showVideo = true
                        }
                    }
                    .onChange(of: imageSelection) { item in
                        Task {
                            print(selected)
                            if let loaded = try? await imageSelection?.loadTransferable(type: Image.self) {
                                swapViewModel.imageToSwapWithTemplate = loaded.asUIImage()
                                swapViewModel.templateToSwapWithTemplate = mainViewModel.templateItems.first(where: { item in
                                    return item.id == selected
                                })
                                print(selected)
                                
                                self.creditsNeeded = Int(swapViewModel.templateToSwapWithTemplate?.duration ?? 10.0)
                                
                                if hasFace(in: swapViewModel.imageToSwapWithTemplate!) {
                                    if ((mainViewModel.userModel?.credits ?? 0) - Int(swapViewModel.templateToSwapWithTemplate?.duration ?? 10.0) <= 0) && selectedTemplate?.isFree == false {
                                        
                                        withAnimation {
                                            self.showNoCreditsLeftDialog.toggle()
                                        }
                                        
                                    } else {
                                        
                                        if mainViewModel.homeConfig?.homeConfig?.features?.videoWorking == true {
                                            withAnimation {
                                                mainViewModel.SCREEN_VIEW = .Loading
                                            }
                                        } else {
                                            withAnimation {
                                                showErrorDialog = true
                                            }
                                        }
                                        
                                    }
                                } else {
                                    withAnimation {
                                        showNoFaceDetected = true
                                    }
                                }
                                
                            } else {
                                print("Failed")
                            }
                            
                        }
                    }
                
                
                VTabView(selection: $selected) {
                    ForEach(mainViewModel.templateItems, id: \.id) { item in
                        
                        ZStack {
                            if item.id == selected && showVideo {
                                VideoPlayer(player: player)
                                    .disabled(true) // Hides iOS video controls
                                    .aspectRatio(contentMode: .fill)
                                    .onAppear {
                                        
                                        player = AVPlayer(url: URL(string: item.templateUrl)!)
                                        player.play()
                                        player.volume = 0.7
                                    }
                                    .onReceive(NotificationCenter
                                        .default
                                        .publisher(
                                            for: .AVPlayerItemDidPlayToEndTime,
                                            object: player.currentItem),
                                               perform: { _ in
                                                    player.seek(to: .zero)
                                                    player.seek(to: .zero)
                                                    player.play()
                                                }
                                    )
                                    .frame(width: (UIScreen.screenWidth - 32))
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            } else {
                                AsyncImage(
                                    url: URL(string: item.thumbnailUrl),
                                    content: { image in
                                        image.resizable()
                                            .scaledToFill()
                                            .frame(width: UIScreen.screenWidth - 32, height: UIScreen.screenHeight - 228)
                                            
                                            
                                    },
                                    placeholder: {
                                        Image(.imgThumbnailResult)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: UIScreen.screenWidth - 32, height: UIScreen.screenHeight - 228)
                                            
                                    }
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                        }
                        .background(content: {
                            RoundedRectangle(cornerRadius: 8)
                                .foregroundStyle(Color.black.opacity(0.7))
                                .frame(width: UIScreen.screenWidth - 32, height: UIScreen.screenHeight - 228)
                        })
                        .tag(item.id)
                        
                        
                    }
                    
                }.tabViewStyle(.page(indexDisplayMode: .never))
                    
                
                Spacer()
                    .frame(height: 10)
                
                PhotosPicker(
                      selection: $imageSelection,
                      matching: .images,
                      photoLibrary: .shared()) {
                          HStack {
                              if selectedTemplate?.isFree == false && (mainViewModel.userModel?.credits ?? 0) <= 0 {
                                  Image(.iconPremium)
                                  Spacer()
                                      .frame(width: 6)
                              }
                              Text(selectedTemplate?.isFree == true || (mainViewModel.userModel?.credits ?? 0) > 0
                                   ? "Choose Face" : "Premium Swap")
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
        
        ZStack {
            
            Color.black.opacity(0.5)
                .ignoresSafeArea()
            
            
            VStack {
                
                Spacer()
                
                Image(.iconOnBoardingSwapTemplates)
                    .resizable()
                    .frame(width: 236, height: 148)
                    .offset(y: isOnboardingAnimating ? 20 : -20)
                    .onAppear {
                        startAnimateOnBoarding()
                        isShowingOnBoardingTemplate = !UserSettings.didShowTemplateOnBoarding
                    }
                
                Spacer()
                    .frame(height: 64)
                
            }
            
            
        }
        .onTapGesture {
            withAnimation {
                isShowingOnBoardingTemplate = false
            }
            UserSettings.didShowTemplateOnBoarding = true
        }.opacity(isShowingOnBoardingTemplate ? 1.0 : 0.0)
            .offset(y: isShowingOnBoardingTemplate ? 0 : UIScreen.screenHeight)
        
        ErrorDialog(errorType: .Sorry, showDialog: $showErrorDialog) {
            
        }
        
        ErrorDialog(errorType: .NoFace, showDialog: $showNoFaceDetected) {
            withAnimation {
                swapViewModel.imageToSwapWithTemplate = nil
                imageSelection = nil
            }
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
    
    @State var isOnboardingAnimating = false
    @State var isShowingOnBoardingTemplate = true
    
    func startAnimateOnBoarding() {
        withAnimation {
            isOnboardingAnimating = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.bouncy) {
                isOnboardingAnimating = false
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            startAnimateOnBoarding()
        }
    }
    
    func selectImage() {
        if let sampleImage = swapViewModel.imageSelected {
            withAnimation {
                showNoFaceDetected = !hasFace(in: sampleImage)
            }
        }
    }
    
    func hasFace(in image: UIImage) -> Bool {
        guard let cgImage = image.cgImage else {
            print("Invalid CGImage")
            return false
        }

        let request = VNDetectFaceRectanglesRequest()
#if targetEnvironment(simulator)
        request.usesCPUOnly = true
#endif
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])

        do {
            try handler.perform([request])
            if let results = request.results as? [VNFaceObservation] {
                return !results.isEmpty
            } else {
                return false
            }
        } catch {
            print("Face detection error: \(error.localizedDescription)")
            return false
        }
    }
    
}


@available(iOS 14.0, *)
public struct VTabView<Content, SelectionValue>: View where Content: View, SelectionValue: Hashable {
    
    private var selection: Binding<SelectionValue>?
    
    private var indexPosition: IndexPosition
    
    private var content: () -> Content
    
    /// Creates an instance that selects from content associated with
    /// `Selection` values.
    public init(selection: Binding<SelectionValue>?, indexPosition: IndexPosition = .leading, @ViewBuilder content: @escaping () -> Content) {
        self.selection = selection
        self.indexPosition = indexPosition
        self.content = content
    }
    
    private var flippingAngle: Angle {
        switch indexPosition {
        case .leading:
            return .degrees(0)
        case .trailing:
            return .degrees(180)
        }
    }
    
    public var body: some View {
        GeometryReader { proxy in
            TabView(selection: selection) {
                Group {
                    content()
                }
                .frame(width: proxy.size.width, height: proxy.size.height)
                .rotationEffect(.degrees(-90))
                .rotation3DEffect(flippingAngle, axis: (x: 1, y: 0, z: 0))
            }
            .frame(width: proxy.size.height, height: proxy.size.width)
            .rotation3DEffect(flippingAngle, axis: (x: 1, y: 0, z: 0))
            .rotationEffect(.degrees(90), anchor: .topLeading)
            .offset(x: proxy.size.width)
        }
    }
    
    public enum IndexPosition {
        case leading
        case trailing
    }
}

@available(iOS 14.0, *)
extension VTabView where SelectionValue == Int {
    
    public init(indexPosition: IndexPosition = .leading, @ViewBuilder content: @escaping () -> Content) {
        self.selection = nil
        self.indexPosition = indexPosition
        self.content = content
    }
}
