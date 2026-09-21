//
//  ResultScreen.swift
//  VideoFaceSwap
//
//  Created by Javad on 11/4/24.
//

import SwiftUI
import Photos
import _AVKit_SwiftUI

struct ResultScreen: View {
    
    @EnvironmentObject var mainViewModel : MainViewModel
    @EnvironmentObject var swapViewModel : SwapViewModel
    
    @State var isShowing = true
    
    @State var saveState : SaveState = .Idle
    
    @State var showContactUsBottomSheet = false
    
    @State var player : AVPlayer = AVPlayer()
    
    @State private var isVideoReady: Bool = false

    @State private var playerObserver: NSKeyValueObservation? = nil

    @State private var isScreenshotDetected: Bool = false

    @State private var isScreenBeingCaptured: Bool = false

    private var shouldHideVideoForCapture: Bool {
        (mainViewModel.userModel?.azizom == false || mainViewModel.userModel?.azizom == nil) && (isScreenshotDetected || isScreenBeingCaptured)
    }
    
    @Environment(\.requestReview) var requestReview
    
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
                    .frame(width: 32, height: 32)
                    .padding(.vertical, 8)
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
                        if !isVideoReady || shouldHideVideoForCapture {
                            Image(.imgThumbnailResult)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: UIScreen.main.bounds.width - 32, height: UIScreen.screenHeight - 280)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        
                        VideoPlayer(player: player)
                            .disabled(false)
                            .aspectRatio(contentMode: .fill)
                            .frame(width: UIScreen.main.bounds.width - 32, height: UIScreen.screenHeight - 280)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .opacity((isVideoReady && !shouldHideVideoForCapture) ? 1 : 0)
                            .onAppear {
                                mainViewModel.isOnVideoHistory = true
                                loadVideo()
                                isScreenBeingCaptured = UIScreen.main.isCaptured
                                if !UserSettings.didRequestReview {
                                    UserSettings.didRequestReview = true
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                        requestReview()
                                    }
                                }
                            }
                            .onDisappear {
                                player.pause()
                                player.volume = 0.0
                                playerObserver = nil // Clean up observer
                            }
                            .onReceive(NotificationCenter.default.publisher(for: .AVPlayerItemDidPlayToEndTime, object: player.currentItem)) { _ in
                                player.seek(to: .zero)
                                player.play()
                            }
                            .onReceive(NotificationCenter.default.publisher(for: UIApplication.userDidTakeScreenshotNotification)) { _ in
                                guard mainViewModel.userModel?.azizom != true else { return }
                                isScreenshotDetected = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                    isScreenshotDetected = false
                                }
                            }
                            .onReceive(NotificationCenter.default.publisher(for: UIScreen.capturedDidChangeNotification)) { _ in
                                isScreenBeingCaptured = UIScreen.main.isCaptured
                            }
                    }
                    .screenshotProtected(mainViewModel.userModel?.azizom != true)
            
            Spacer()
                .frame(height: 24)
            
            Button(action: {
                withAnimation {
                    mainViewModel.SCREEN_VIEW = .Main
                }
                mainViewModel.mainBottomBar = .Upload
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
                    
                    DispatchQueue.global(qos: .background).async {
                        if let url = URL(string: swapViewModel.resultModel?.vidUrl ?? ""),
                            let urlData = NSData(contentsOf: url)
                        {
                            let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0];
                            let filePath="\(documentsPath)/VideoFaceSwap.mp4"
                            DispatchQueue.main.async {
                                urlData.write(toFile: filePath, atomically: true)
                                share(items: [URL(fileURLWithPath: filePath)])
                            }
                        }
                    }
                    
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
                                let filePath="\(documentsPath)/VideoFaceSwap.mp4"
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
            }
            
            Spacer()
                .frame(height: 16)
            
            .sheet(isPresented: $showContactUsBottomSheet, content: {
                ContactUsView(showContactUsBottomSheet: $showContactUsBottomSheet)
            })
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(Rectangle())
        .swipeBack {
            withAnimation {
                mainViewModel.SCREEN_VIEW = .Main
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
    
    func loadVideo() {
        if let url = URL(string: swapViewModel.resultModel?.vidUrl ?? "") {
            let playerItem = AVPlayerItem(url: url)
            player.replaceCurrentItem(with: playerItem)
            player.volume = 1.0
            
            // ✅ Retain observer to avoid deallocation
            playerObserver = playerItem.observe(\.status, options: [.new, .initial]) { item, _ in
                if item.status == .readyToPlay {
                    DispatchQueue.main.async {
                        isVideoReady = true
                        player.play()
                    }
                } else if item.status == .failed {
                    loadVideo()
                }
            }
        }
    }
}


enum SaveState {
    case Idle
    case Saving
    case Saved
}
// MARK: - Screenshot / Screen Recording Protection
//
// Uses UITextField's private secure text canvas as a container for arbitrary
// content. Anything placed inside that canvas is blanked out by the OS in
// screenshots and screen recordings — the only reliable way to block capture
// on iOS without a public API.

struct ScreenshotProtectedView<Content: View>: UIViewRepresentable {
    private let contentBuilder: () -> Content

    init(@ViewBuilder content: @escaping () -> Content) {
        self.contentBuilder = content
    }

    func makeUIView(context: Context) -> UIView {
        let container = UIView()
        container.backgroundColor = .clear

        let host = context.coordinator.host
        host.rootView = AnyView(contentBuilder())
        host.view.backgroundColor = .clear
        host.view.translatesAutoresizingMaskIntoConstraints = false

        let secureField = UITextField()
        secureField.isSecureTextEntry = true

        // The private canvas view attached to a secure UITextField is what
        // iOS hides from captures. If Apple ever changes this, fall back to
        // rendering the content unprotected rather than crashing.
        let canvas = (secureField.layer.sublayers?.first?.delegate as? UIView) ?? container

        canvas.subviews.forEach { $0.removeFromSuperview() }
        canvas.translatesAutoresizingMaskIntoConstraints = false

        if canvas !== container {
            container.addSubview(canvas)
            NSLayoutConstraint.activate([
                canvas.topAnchor.constraint(equalTo: container.topAnchor),
                canvas.bottomAnchor.constraint(equalTo: container.bottomAnchor),
                canvas.leadingAnchor.constraint(equalTo: container.leadingAnchor),
                canvas.trailingAnchor.constraint(equalTo: container.trailingAnchor)
            ])
        }

        canvas.addSubview(host.view)
        NSLayoutConstraint.activate([
            host.view.topAnchor.constraint(equalTo: canvas.topAnchor),
            host.view.bottomAnchor.constraint(equalTo: canvas.bottomAnchor),
            host.view.leadingAnchor.constraint(equalTo: canvas.leadingAnchor),
            host.view.trailingAnchor.constraint(equalTo: canvas.trailingAnchor)
        ])

        return container
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        context.coordinator.host.rootView = AnyView(contentBuilder())
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    final class Coordinator {
        let host = UIHostingController(rootView: AnyView(EmptyView()))
    }
}

extension View {
    @ViewBuilder
    func screenshotProtected(_ isProtected: Bool) -> some View {
        if isProtected {
            ScreenshotProtectedView { self }
        } else {
            self
        }
    }
}

