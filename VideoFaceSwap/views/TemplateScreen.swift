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
import UIKit

struct TemplateScreen: View {
    
    @EnvironmentObject var mainViewModel  : MainViewModel
    @EnvironmentObject var swapViewModel  : SwapViewModel
    
    @State private var isShowing = true
    @State private var selected = ""
    
    @State private var uiImage: UIImage? = nil
    @State private var showImagePicker = false
    
    @State private var showNoCreditsLeftDialog = false
    @State private var creditsNeeded: Int = 0
    @State private var showErrorDialog = false
    @State private var showContactUsBottomSheet = false
    @State private var selectedTemplate: TemplateModel? = nil
    @State private var player: AVPlayer = AVPlayer()
    @State private var showVideo = true
    @State private var showNoFaceDetected = false
    
    @State private var isOnboardingAnimating = false
    @State private var isShowingOnBoardingTemplate = true
    
    @State var showTermsDialog: Bool = false
    
    // MARK: - HEADER
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
                        
                    Text(String(mainViewModel.userModel?.totalCredits ?? 0))
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 7)
                .padding(.vertical, 5)
                .roundedCornerWithBorder(lineWidth: 1, borderColor: .white, radius: 8, corners: .allCorners)
            }
            
            Spacer().frame(width: 12)
            
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
    
    // MARK: - BODY
    var body: some View {
        ZStack {
            VStack {
                header
                    .onAppear {
                        selected = mainViewModel.templateItems.first?.id ?? ""
                        selectedTemplate = mainViewModel.templateItems.first
                    }
                    .onDisappear {
                        player.volume = 0.0
                    }
                    .onChange(of: selected) { newValue in
                        player.pause()
                        selectedTemplate = mainViewModel.templateItems.first(where: { $0.id == selected })
                        showVideo = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            showVideo = true
                        }
                    }
                    .onChange(of: uiImage) { image in
                        guard let image = image else { return }
                        handleSelectedImage(image)
                    }
                
                // MARK: Templates
                VTabView(selection: $selected) {
                    ForEach(mainViewModel.templateItems, id: \.id) { item in
                        ZStack {
                            if item.id == selected && showVideo {
                                VideoPlayer(player: player)
                                    .disabled(true)
                                    .aspectRatio(contentMode: .fill)
                                    .onAppear {
                                        player = AVPlayer(url: URL(string: item.templateUrl)!)
                                        player.play()
                                        player.volume = 0.7
                                    }
                                    .onReceive(NotificationCenter.default.publisher(for: .AVPlayerItemDidPlayToEndTime, object: player.currentItem)) { _ in
                                        player.seek(to: .zero)
                                        player.play()
                                    }
                                    .frame(width: UIScreen.screenWidth - 32)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            } else {
                                AsyncImage(url: URL(string: item.thumbnailUrl)) { image in
                                    image.resizable()
                                        .scaledToFill()
                                        .frame(width: UIScreen.screenWidth - 32, height: UIScreen.screenHeight - 228)
                                } placeholder: {
                                    Image(.imgThumbnailResult)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: UIScreen.screenWidth - 32, height: UIScreen.screenHeight - 228)
                                }
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .foregroundStyle(Color.black.opacity(0.7))
                                .frame(width: UIScreen.screenWidth - 32, height: UIScreen.screenHeight - 228)
                        )
                        .tag(item.id)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                
                Spacer().frame(height: 10)
                
                // MARK: Choose Face Button
                Button {
                    if !UserSettings.didShowTermsDialog {
                        showTermsDialog = true
                        return
                    }
                    showImagePicker = true
                } label: {
                    HStack {
                        if selectedTemplate?.isFree == false && (mainViewModel.userModel?.totalCredits ?? 0) <= 0 {
                            Image(.iconPremium)
                            Spacer().frame(width: 6)
                        }
                        Text(selectedTemplate?.isFree == true || (mainViewModel.userModel?.totalCredits ?? 0) > 0
                             ? "Choose Face" : "Premium Swap")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.white)
                    }
                    .frame(width: UIScreen.screenWidth - 32, height: 48)
                    .background(
                        LinearGradient(colors: gradientColor, startPoint: .leading, endPoint: .trailing)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(alignment: .trailing) {
                        if mainViewModel.userModel?.totalCredits ?? 0 > 0 && selectedTemplate?.isFree == false {
                            HStack {
                                Image(.iconCoins)
                                    .resizable()
                                    .frame(width: 19, height: 19)
                                    
                                Text(String(selectedTemplate?.durationSec ?? 5))
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundColor(.white)
                                
                            }.padding(.trailing, 16)
                        }
                    }
                }
                .sheet(isPresented: $showImagePicker) {
                    ClassicImagePicker(selectedImage: $uiImage)
                }
                
                Spacer().frame(height: 16)
            }
        }
        .swipeBack {
            withAnimation {
                mainViewModel.SCREEN_VIEW = .Main
            }
        }
        
        // MARK: - Overlays
        ErrorDialog(errorType: .Sorry, showDialog: $showErrorDialog) {}
        
        ErrorDialog(errorType: .NoFace, showDialog: $showNoFaceDetected) {
            withAnimation {
                swapViewModel.imageToSwapWithTemplate = nil
                uiImage = nil
            }
        }
        
        NoCreditsLeftDialog(
            shown: $showNoCreditsLeftDialog,
            creditsOwned: .constant(mainViewModel.userModel?.totalCredits ?? 0),
            creditsNeeded: $creditsNeeded,
            onGoToCreditHistoyClicked: {
                mainViewModel.CreditDetailsBackstack = .Templates
withAnimation {
mainViewModel.SCREEN_VIEW = .PurchaseHistory
}
}) {
withAnimation {
mainViewModel.SCREEN_VIEW = .Purchase
}
}
        .sheet(isPresented: $showContactUsBottomSheet) {
            ContactUsView(showContactUsBottomSheet: $showContactUsBottomSheet)
        }
        .alert("AI Processing & Privacy", isPresented: $showTermsDialog) {
            Button("Cancel") {
                
            }
            Button("Privacy & Policy") {
                if let url = URL(string: privacyPolicyLink) {
                    UIApplication.shared.open(url)
                }
            }
            Button("Agree & Continue") {
                UserSettings.didShowTermsDialog = true
            }
        } message: {
            Text("To create your face swap, the photos and videos you provide are securely sent to our servers for AI processing. \nYour content is used only to create the result you request. We do not sell or share your personal data or uploaded content, and we never use it to train AI models. \nYour uploads are deleted automatically from our servers once processing is complete. Your results are saved only in History on your device, and you can delete them at any time. \nFor more details, please review our Privacy Policy.")
        }

    }
    
    // MARK: - Handle Selected Image
    func handleSelectedImage(_ image: UIImage) {
        swapViewModel.imageToSwapWithTemplate = image
        swapViewModel.templateToSwapWithTemplate = mainViewModel.templateItems.first(where: { $0.id == selected })
        creditsNeeded = Int(swapViewModel.templateToSwapWithTemplate?.durationSec ?? 10)
        
        if hasFace(in: image) {
            if ((mainViewModel.userModel?.totalCredits ?? 0) - creditsNeeded <= 0) && selectedTemplate?.isFree == false {
                withAnimation {
                    showNoCreditsLeftDialog = true
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
    }
    
    // MARK: - Face Detection
    func hasFace(in image: UIImage) -> Bool {
        guard let cgImage = image.cgImage else { return false }
        let request = VNDetectFaceRectanglesRequest()
        #if targetEnvironment(simulator)
        request.usesCPUOnly = true
        #endif
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        do {
            try handler.perform([request])
            if let results = request.results as? [VNFaceObservation] {
                return !results.isEmpty
            }
        } catch {
            print("Face detection error: \(error.localizedDescription)")
        }
        return false
    }
}

struct ClassicImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.presentationMode) var presentationMode
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ClassicImagePicker
        
        init(_ parent: ClassicImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.allowsEditing = false
        picker.sourceType = .photoLibrary
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
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
