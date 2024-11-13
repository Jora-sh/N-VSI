//
//  ErrorDialog.swift
//  VideoFaceSwap
//
//  Created by Javad on 11/5/24.
//

import SwiftUI

struct ErrorDialog: View {
    
    let errorType:ErrorType
    @Binding var showDialog : Bool
    
    let onButtonClicked : () -> Void
    
    var body: some View {
        ZStack {
            
            Color.black
                .ignoresSafeArea()
                .opacity(showDialog ? 0.5 : 0.0)
                .onTapGesture {
                    withAnimation {
                        showDialog = false
                    }
                }
            
            ZStack {
                
                VStack {
                    
                    Image(getIconError())
                        .resizable()
                        .frame(width: 24, height: 24)
                    
                    Spacer()
                        .frame(height: 5)
                    
                    Text(getTitleError())
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)
                    
                    Spacer()
                        .frame(height: 12)
                    
                    Text(getDescError())
                        .multilineTextAlignment(.center)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(Color(hex: textColor))
                    
                    Spacer()
                        .frame(height: 16)
                    
                    Button(action: {
                        onButtonClicked()
                        withAnimation {
                            self.showDialog = false
                        }
                    }, label: {
                        Text(errorType == .Sorry ? "Go Home" : "Try Again")
                            .foregroundStyle(.white)
                            .frame(width:164, height: 44)
                            .background {
                                Color(hex: "#D32F2F")
                            }.clipShape(RoundedRectangle(cornerRadius: 8))
                    })
                }
                .padding(.vertical, 24)
                .padding(.horizontal, 36)
                
            }.background {
                
                Color.black
                    .roundedCornerWithBorder(lineWidth: 2, borderColor: Color(hex: "#D32F2F"), radius: 10, corners: .allCorners)
                    
            }
            .frame(width: UIScreen.screenWidth - 100)
            
            
        }
            .offset(y: showDialog ? 0 : UIScreen.screenHeight)
    }
    
    func getTitleError() ->String {
        switch errorType {
        case .Oops:
            return "Oops!"
        case .NoInternet:
            return "No Internet Connection!"
        case .NoFace:
            return "Can't Detect face!"
        case .Sorry:
            return "We are sorry..."
        }
    }
    
    func getDescError() ->String {
        switch errorType {
        case .Oops:
            return "Sorry, an error occurred. Please try again."
        case .NoInternet:
            return "please try again when your\nconnection is available"
        case .NoFace:
            return "Please ensure your face is\nclearly visible & try again."
        case .Sorry:
            return "The app is currently undergoing maintenance and will be back online shortly.\n\nThank you for your patience and understanding!"
        }
    }
    
    func getIconError() -> ImageResource {
        switch errorType {
        case .Oops:
            return .iconOops
        case .NoInternet:
            return .iconNoInternet
        case .NoFace:
            return .iconNoFace
        case .Sorry:
            return .iconGoHome
        }
    }
}

enum ErrorType {
    case Oops
    case NoInternet
    case NoFace
    case Sorry
}
