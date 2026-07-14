//
//  CustomScreen.swift
//  VideoFaceSwap
//
//  Created by Javad on 11/3/24.
//

import SwiftUI
import PhotosUI
import AVKit
import Vision
import OneSignalFramework

struct CustomScreen: View {
    
    @EnvironmentObject var swapViewModel: SwapViewModel
    @EnvironmentObject var mainViewModel: MainViewModel
    
    @State var videoURL : URL? = nil
    @State var player : AVPlayer? = nil
    
    @State var showPHPicker = false
    @State var showNoCreditsLeftDialog : Bool = false
    @State var creditsNeeded : Int = 0
    @State var showErrorDialog: Bool = false
    @State var showNoCreditDialog: Bool = true
    @State private var showNoFaceDetected: Bool = false
    
    var body: some View {
        ZStack {
            VStack {
                
                Spacer()
                    .onAppear {
                        OneSignal.Notifications.requestPermission({ accepted in
                          print("User accepted notifications: \(accepted)")
                        }, fallbackToSettings: true)
                        
                        if let videoURL = swapViewModel.videoUrl {
                            player = AVPlayer(url: videoURL)
                            player?.volume = 0.0
                            player?.play()
                        }
                        mainViewModel.getMe { _ in }
                        if mainViewModel.userModel?.totalCredits ?? 0 > 0 {
                            showNoCreditDialog = false
                        }
                    }
                
//                Button {
//                    withAnimation {
//                        mainViewModel.SCREEN_VIEW = .purchaseOffer
//                    }
//                } label: {
//                    TimerView()
//                }

                Spacer()
                
                // MARK: IMAGE PICKER (PHPicker)
                ZStack {
                    if swapViewModel.imageSelected == nil {
                        Button {
                            showPHPicker = true
                        } label: {
                            VStack {
                                Image(.iconFace)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 36, height: 36)
                                    .padding(.bottom, 18)
                                
                                Text("Tap Here")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(.white)
                                
                                Text("to select the photo")
                                    .font(.system(size: 16))
                                    .foregroundColor(.white)
                                    .padding(.top, 5)
                            }
                            .frame(width: UIScreen.screenWidth - 192, height: UIScreen.screenWidth - 192)
                        }
                    } else {
                        ZStack {
                            Image(uiImage: swapViewModel.imageSelected!)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: UIScreen.screenWidth - 120, height: UIScreen.screenWidth - 192)
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
                                            .frame(width: 22, height: 22)
                                    }
                                }
                                Spacer()
                            }
                            .padding(24)
                        }
                    }
                }
                .frame(width: UIScreen.screenWidth - 120, height: UIScreen.screenWidth - 192)
                .background(Color(hex: "#1B1B1E"))
                .cornerRadius(16)
                .padding(.bottom, 0)
                .sheet(isPresented: $showPHPicker) {
                    PHPickerWrapper(selectedImage: $swapViewModel.imageSelected)
                        .onDisappear {
                            selectImage()
                        }
                }
                
                // MARK: SWITCH ICON
                Image(.iconDoubleArrow)
                    .resizable()
                    .frame(width: 64, height: 64)
                
                // MARK: VIDEO PICKER (Unchanged)
                ZStack {
                    PhotosPicker(
                        selection: $swapViewModel.videoSelection,
                        matching: .videos,
                        photoLibrary: .shared()
                    ) {
                        if swapViewModel.videoSelection == nil {
                            VStack {
                                Image(.iconVideo)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 36, height: 36)
                                    .padding(.bottom, 18)
                                
                                Text("Tap Here")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(.white)
                                
                                Text("to select the Video")
                                    .font(.system(size: 16))
                                    .foregroundColor(.white)
                                    .padding(.top, 5)
                            }
                            .frame(width: UIScreen.screenWidth - 192, height: UIScreen.screenWidth - 192)
                        } else {
                            ZStack {
                                VideoPlayer(player: player)
                                    .frame(width: UIScreen.screenWidth - 120, height: UIScreen.screenWidth - 192)
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
                                                .frame(width: 22, height: 22)
                                        }
                                    }
                                    Spacer()
                                }
                                .padding(24)
                            }
                        }
                    }
                    .onChange(of: swapViewModel.videoSelection) { newMedia in
                        Task {
                            guard let item = swapViewModel.videoSelection else { return }
                            let config = VideoKit.Config(.presetMediumQuality,
                                                         limitFPS: 23,
                                                         limitBitrate: 2_500_000)
                            item.loadTransferable(type: Movie.self) { result in
                                switch result {
                                case .success(let movie):
                                    if let movie = movie {
                                        VideoKit.mutate(videoUrl: movie.url, config: config) { result in
                                            switch result {
                                            case .success(let videoUrl):
                                                player = AVPlayer(url: videoUrl)
                                                player?.volume = 0.0
                                                player?.play()
                                                videoURL = videoUrl
                                                swapViewModel.videoUrl = videoUrl
                                            case .error(let errorString):
                                                print(errorString)
                                            }
                                        }
                                    }
                                case .failure(let failure):
                                    print("Video load error: \(failure)")
                                }
                            }
                        }
                    }
                    .frame(width: UIScreen.screenWidth - 120, height: UIScreen.screenWidth - 192)
                    .background(Color(hex: "#1B1B1E"))
                    .cornerRadius(16)
                    .padding(.top, 0)
                }
                
                Spacer()
                
                // MARK: START SWAPPING BUTTON
                Button {
                    if swapViewModel.imageSelected != nil && swapViewModel.videoSelection != nil {
                        Task {
                            let duration = try? await self.player?.currentItem?.asset.load(.duration)
                            let creditsNeeded = Int(duration?.seconds ?? 10)
                            // use creditsNeeded here
                            swapViewModel.creditsNeededForCustomSwap = creditsNeeded
                            
                        
                            if creditsNeeded >= (mainViewModel.userModel?.totalCredits ?? 0) {
                                swapViewModel.goLoadingWithoutCredits = true
                                swapViewModel.creditsNeededForCustomSwap = creditsNeeded
                                withAnimation {
                                    mainViewModel.SCREEN_VIEW = .Loading
                                }
                            } else {
                                if UserSettings.videoIsWorking {
                                    swapViewModel.goLoadingWithoutCredits = false
                                    withAnimation {
                                        mainViewModel.SCREEN_VIEW = .Loading
                                    }
                                } else {
                                    withAnimation {
                                        showErrorDialog = true
                                    }
                                }
                            }
                        }
                    }
                } label: {
                    Text("Start Swapping")
                        .foregroundColor(.white)
                        .opacity(swapViewModel.imageSelected != nil && swapViewModel.videoSelection != nil ? 1.0 : 0.3)
                        .font(.system(size: 20, weight: .medium))
                        .frame(width: UIScreen.screenWidth - 78, height: UIScreen.screenHeight / 17)
                        .background(
                            swapViewModel.imageSelected != nil && swapViewModel.videoSelection != nil
                            ? LinearGradient(colors: gradientColor, startPoint: .leading, endPoint: .trailing)
                            : LinearGradient(stops: [Gradient.Stop(color: Color.white.opacity(0.5), location: 0.0)],
                                             startPoint: .leading, endPoint: .trailing)
                        )
                        .cornerRadius(10)
                }
                
                Spacer()
            }
            
            // MARK: - Error and Credit Dialogs
            ErrorDialog(errorType: .Sorry, showDialog: $showErrorDialog) {}
            
            ErrorDialog(errorType: .NoFace, showDialog: $showNoFaceDetected) {
                withAnimation {
                    swapViewModel.imageSelected = nil
                }
            }
            
            NoCreditsLeftDialog(shown: $showNoCreditsLeftDialog,
                                creditsOwned: .constant(mainViewModel.userModel?.totalCredits ?? 0),
                                creditsNeeded: $creditsNeeded,
                                onGoToCreditHistoyClicked: {
                mainViewModel.CreditDetailsBackstack = .Main
                withAnimation {
                    mainViewModel.SCREEN_VIEW = .PurchaseHistory
                }
            }) {
                withAnimation {
                    mainViewModel.SCREEN_VIEW = .Purchase
                }
            }
        }
    }
    
    // MARK: - Face Detection
    func selectImage() {
        if let sampleImage = swapViewModel.imageSelected {
            withAnimation {
                showNoFaceDetected = !hasFace(in: sampleImage)
            }
        }
    }
    
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

//
// MARK: - PHPicker Wrapper
//
struct PHPickerWrapper: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration(photoLibrary: .shared())
        config.filter = .images
        config.selectionLimit = 1
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        var parent: PHPickerWrapper
        
        init(_ parent: PHPickerWrapper) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            guard let provider = results.first?.itemProvider else { return }
            
            if provider.canLoadObject(ofClass: UIImage.self) {
                provider.loadObject(ofClass: UIImage.self) { image, _ in
                    DispatchQueue.main.async {
                        self.parent.selectedImage = image as? UIImage
                    }
                }
            }
        }
    }
}



struct TimerView: View {
    @StateObject private var timerManager = TimerManager()
    
    var body: some View {
        HStack {
            Text("Limited Offer")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Color.white)
            
            Spacer()
            
            Text(timerManager.timeString)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Color.white)
        }
        .frame(height: 40)
        .padding(.horizontal, 14)
        .background {
//            Color.init(hex: "#C43737").opacity(0.7)
//                .clipShape(RoundedRectangle(cornerRadius: 10))
            Image(.imgBackOffer)
                .resizable()
                .scaledToFit()
        }
        .frame(width: UIScreen.screenWidth - 32, height: 40)
        .roundedCornerWithBorder(lineWidth: 1.5, borderColor: Color(hex: "#C43737"), radius: 10, corners: .allCorners)
        .onAppear {
            timerManager.startTimer()
        }
    }
}

class TimerManager: ObservableObject {
    @Published var timeString: String = "24:00:00"
    
    private var timer: Timer?
    private let totalDuration: TimeInterval = 24 * 60 * 60 // 24 hours in seconds
    private let startTimeKey = "timerStartTime"
    
    init() {
        updateTimeString()
    }
    
    func startTimer() {
        // Initialize start time if not set
        if UserDefaults.standard.object(forKey: startTimeKey) == nil {
            UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: startTimeKey)
        }
        
        // Update immediately
        updateTimeString()
        
        // Start repeating timer for UI updates
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateTimeString()
        }
    }
    
    private func updateTimeString() {
        guard let startTime = UserDefaults.standard.object(forKey: startTimeKey) as? TimeInterval else {
            return
        }
        
        let startDate = Date(timeIntervalSince1970: startTime)
        let currentDate = Date()
        let elapsedTime = currentDate.timeIntervalSince(startDate)
        
        // Calculate how many complete 24-hour cycles have passed
        let completeCycles = floor(elapsedTime / totalDuration)
        
        // Calculate time within current cycle
        let timeInCurrentCycle = elapsedTime - (completeCycles * totalDuration)
        
        // Calculate remaining time (countdown)
        let remainingTime = totalDuration - timeInCurrentCycle
        
        // If cycle completed, reset start time
        if remainingTime <= 0 {
            let newStartTime = currentDate.timeIntervalSince1970
            UserDefaults.standard.set(newStartTime, forKey: startTimeKey)
            timeString = formatTime(totalDuration)
            return
        }
        
        timeString = formatTime(remainingTime)
    }
    
    private func formatTime(_ timeInterval: TimeInterval) -> String {
        let hours = Int(timeInterval) / 3600
        let minutes = Int(timeInterval) / 60 % 60
        let seconds = Int(timeInterval) % 60
        
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    deinit {
        timer?.invalidate()
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
