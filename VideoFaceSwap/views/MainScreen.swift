//
//  MainScreen.swift
//  VideoFaceSwap
//
//  Created by Javad on 11/3/24.
//

import SwiftUI
import AVFoundation
import AVKit

let gradientColor = [Color(hex: accentColorLight), Color(hex: accentColorDark)]

struct MainScreen: View {
    
    @EnvironmentObject var mainViewModel : MainViewModel
    
    var header: some View {
        HStack {
            
            Button {
                withAnimation {
                    mainViewModel.SCREEN_VIEW = .Settings
                }
            } label: {
                Image(.iconSettings)
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
            
            
        }.overlay {
            switch mainViewModel.mainBottomBar {
            case .Home:
                HStack {
                    Text("Video")
                        .gradientForeground(colors: [Color(hex: accentColorLight), Color(hex: accentColorDark)])
                        .font(.system(size: 20, weight: .heavy))
                    Text("Face Swapper")
                        .font(.system(size: 20, weight: .heavy))
                        .foregroundStyle(.white)
                }
            case .Upload:
                HStack {
                    Text("Custom")
                        .foregroundStyle(.white)
                        .font(.system(size: 20, weight: .heavy))
                    Text("Video Swap")
                        .font(.system(size: 20, weight: .heavy))
                        .gradientForeground(colors: [Color(hex: accentColorLight), Color(hex: accentColorDark)])
                        
                }
            case .History:
                HStack {
                    Text("History")
                        .foregroundStyle(.white)
                        .font(.system(size: 20, weight: .heavy))
                        
                }
            }
            
        }
        .frame(width: UIScreen.screenWidth - 32)
    }
    
    var body: some View {
        ZStack {
            
            
            
            VStack() {
                
                Spacer()
                    .frame(height: 64)
                
                header
                    .onAppear {
                        
                    }
                
                switch mainViewModel.mainBottomBar {
                case .Home:
                    HomeScreen()
                case .Upload:
                    CustomScreen()
                case .History:
                    HistoryScreen(homeBottomBarSelected: $mainViewModel.mainBottomBar)
                }
                
                appBottomBar
                
            }.ignoresSafeArea()
            
            
        }
    }
    
    var appBottomBar : some View {
        HStack {
            Spacer()
            Button(action: {
                withAnimation {
                    mainViewModel.mainBottomBar = .Home
                }
            }, label: {
                VStack {
                    Image(mainViewModel.mainBottomBar == .Home ? .iconTemplateSelected : .iconTemplateUnselected)
                    
                    Text("Templates")
                        .font(.system(size:12))
                        .gradientForeground(colors: mainViewModel.mainBottomBar == .Home ? gradientColor : [.white])
                }.frame(width: 120, height: 64)
            })
            Spacer()
            Button(action: {
                withAnimation {
                    mainViewModel.mainBottomBar = .Upload
                }
            }, label: {
                VStack {
                    Image(mainViewModel.mainBottomBar == .Upload ? .iconCustomSelected : .iconCustomUnselected)
                    
                    Text("Upload Video")
                        .font(.system(size:12))
                        .gradientForeground(colors: mainViewModel.mainBottomBar == .Upload ? gradientColor : [.white])
                }.frame(width: 120, height: 64)
            })
            Spacer()
            Button(action: {
                withAnimation {
                    mainViewModel.mainBottomBar = .History
                }
            }, label: {
                VStack {
                    Image(mainViewModel.mainBottomBar == .History ? .iconHistorySelected : .iconHistoryUnselected)
                    
                    Text("History")
                        .font(.system(size:12))
                        .gradientForeground(colors: mainViewModel.mainBottomBar == .History ? gradientColor : [.white])
                }.frame(width: 120, height: 64)
            })
            Spacer()
        }.frame(width: UIScreen.screenWidth, height: 84)
            .background {
                Color(hex: "#1B1B1E")
            }
    }
}


struct BackgroundView : View {
    
    var body: some View {
        Image(.background)
            .resizable()
            .ignoresSafeArea()
    }
}

enum BottomBar {
    case Home
    case Upload
    case History
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

extension View {
    public func gradientForeground(colors: [Color]) -> some View {
        self.overlay(
            LinearGradient(
                colors: colors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing)
        )
            .mask(self)
    }
}

extension UIScreen{
   static let screenWidth = UIScreen.main.bounds.size.width
   static let screenHeight = UIScreen.main.bounds.size.height
   static let screenSize = UIScreen.main.bounds.size
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

extension View {
    func roundedCornerWithBorder(lineWidth: CGFloat, borderColor: Color, radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners) )
            .overlay(RoundedCorner(radius: radius, corners: corners)
                .stroke(borderColor, lineWidth: lineWidth))
    }
}
