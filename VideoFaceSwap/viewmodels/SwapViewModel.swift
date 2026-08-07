//
//  SwapViewModel.swift
//  VideoFaceSwap
//
//  Created by Javad on 11/3/24.
//

import Foundation
import UIKit
import SwiftUI
import PhotosUI
import _PhotosUI_SwiftUI
import Alamofire
import SwiftyJSON

class SwapViewModel : ObservableObject {
    
    @Published var imageToSwapWithTemplate : UIImage? = nil
    @Published var templateToSwapWithTemplate : TemplateModel? = nil
    
    @Published var imageSelection: PhotosPickerItem? = nil
    @Published var imageSelected: UIImage? = nil
    @Published var videoSelection: PhotosPickerItem? = nil
    @Published var videoUrl : URL? = nil
    @Published var goLoadingWithoutCredits : Bool = false
    @Published var creditsNeededForCustomSwap : Int = 0
    
    @Published var resultModel : CheckForVideoResponseModel? = nil
    
    func swapWithTemplate(image:UIImage?, templateId:String,onResponse : @escaping (Bool,String?) -> Void) {
        
        let headers : HTTPHeaders = [
            
            "Authorization" : "Bearer \(UserSettings.token)",
            "x-api-key" : "ae6a1d02bde6a2e299e2e2033e6a2e20310686"
            
        ]
        
        print(headers)
        
        
        if let image = image {
            AF.upload( multipartFormData: { multipartFormData in
                
                multipartFormData.append(((image.resizeToMaxSize(maxSize: CGSize(width: 1000, height: 1000)) ?? image).jpegData(compressionQuality: 0.5))!, withName: "image", fileName: "image.jpg", mimeType: "image/jpeg")
                multipartFormData.append(templateId.data(using: .utf8)!, withName: "templateName")
                
                
            },
                       to: "\(base_url)users/template-video" , method: .post , headers: headers)  { $0.timeoutInterval = 100 }
              
                .validate().uploadProgress(closure: { progress in
                    print(progress)
                }).responseData { result in
                    
                    let json = JSON(result.data)
                    print(json)
                    print(result.response?.statusCode)
                    
                    switch result.result{
                        
                    case .success(let value):
                        let json = JSON(value)
                        print(json)
                        
                        let data = MyDecoder<FaceSwapResponseModel>().decodeJSON(json: value)
                        
                        switch data {
                        case .success(let data):
                            if data?.success == true {
                                onResponse(true, data?.jobId ?? "")
                            } else {
                                onResponse(false, data?.message)
                            }
                        case .failure(let error):
                            print(error?.localizedDescription ?? "")
                            onResponse(false, "some error occurred")
                            break
                        }
                        
                        
                    case .failure(let err):
                        let data = try? MyDecoder<FaceSwapResponseModel>().decodeJSON(json: json.rawData())
                        if let data = data {
                            switch data {
                            case .success(let data):
                                if data?.success == true {
                                    onResponse(true, data?.jobId ?? "")
                                } else {
                                    print(data?.message)
                                    onResponse(false, data?.message)
                                }
                            case .failure(let error):
                                print(error?.localizedDescription ?? "")
                                onResponse(false, nil)
                                break
                            }
                        }
                        print(err.localizedDescription)
                        
                    }
                }
            
        } else {
            onResponse(false, "Video is not selected")
        }
    }
    
    func uploadMedia(videoPath : URL?, image:UIImage, onResponse : @escaping (Bool,String?) -> Void){
        
        
        
        let headers : HTTPHeaders = [
            
            "Authorization" : "Bearer \(UserSettings.token)",
            "x-api-key" : "ae6a1d02bde6a2e299e2e2033e6a2e20310686"
            
        ]
        
        print(headers)
        
        
        if let videoPath = videoPath {
            AF.upload( multipartFormData: { multipartFormData in
                
                multipartFormData.append(((image.resizeToMaxSize(maxSize: CGSize(width: 1000, height: 1000)) ?? image).jpegData(compressionQuality: 0.5))!, withName: "image", fileName: "image.jpg", mimeType: "image/jpeg")
                multipartFormData.append(videoPath, withName: "video")
                
            },
                       to: "\(base_url)users/video" , method: .post , headers: headers)  { $0.timeoutInterval = 100 }
              
                .validate().uploadProgress(closure: { progress in
                    print(progress)
                }).responseData { result in
                    let json = JSON(result.data ?? "")
                    print(json)
                    
                    switch result.result{
                        
                    case .success(let value):
                        let json = JSON(value)
                        print(json)
                        
                        let data = MyDecoder<FaceSwapResponseModel>().decodeJSON(json: value)
                        
                        switch data {
                        case .success(let data):
                            if data?.success == true {
                                onResponse(true, data?.jobId ?? "")
                            } else {
                                onResponse(false, data?.message)
                            }
                        case .failure(let error):
                            print(error?.localizedDescription ?? "")
                            onResponse(false, nil)
                            break
                        }
                        
                        
                    case .failure(let err):
                        let data = MyDecoder<FaceSwapResponseModel>().decodeJSON(json: result.data ?? Data())
                        
                        switch data {
                        case .success(let data):
                            onResponse(false, data?.message)
                        case .failure(let error):
                            print(error?.localizedDescription ?? "")
                            onResponse(false, nil)
                            break
                        }
                    }
                }
            
        } else {
            onResponse(false, "Video is not selected")
        }
    }
    
    func checkForVideo(jobId:String,  onResponse : @escaping (Bool,String?,String?) -> Void) {
        
        let headers : HTTPHeaders = [
            "Authorization" : "Bearer \(UserSettings.token)",
            "x-api-key" : "ae6a1d02bde6a2e299e2e2033e6a2e20310686"
        ]
        
        print(headers)
        
        let url = URL(string: "\(base_url)users/video/\(jobId)")!

        
        AF.request(url,method: .get,headers: headers)
            .validate()
            .response { result in
                
                
                switch result.result{
                    
                case .success(let value):
                    let json = JSON(value ?? "{}")
                    print(json)
                    
                    let data = MyDecoder<CheckForVideoResponseModel>().decodeJSON(json: value!)
                    
                    switch data {
                    case .success(let data):
                        print(data ?? "")

                        if data?.isContentRejected == true {
                            self.resultModel = data
                            onResponse(false, nil, data?.message)
                        } else if data?.success == true{
                            if data?.isLoading == true {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                                    self.checkForVideo(jobId: jobId, onResponse: onResponse)
                                }
                            } else {
                                self.resultModel = data
                                onResponse(true, data?.vidUrl, "")

                            }
                        } else {
                            onResponse(false, nil, data?.message)
                        }
                        
                    case .failure(let error):
                        print(error?.localizedDescription ?? "")
                        onResponse(false, nil,"")
                        break
                    }
                    
                    
                case .failure(let err):
                    print(err.localizedDescription)
                    onResponse(false, nil,"")
                }
            }
    }
}

struct FaceSwapResponseModel : Codable {
    let success:Bool
    let jobId:String?
    let message:String?
}

struct CheckForVideoResponseModel : Codable {
    let success:Bool
    let isLoading: Bool
    let vidUrl:String?
    let message:String?
    let isContentRejected:Bool?
}

extension UIImage {
    func resizeToMaxSize(maxSize: CGSize) -> UIImage? {
        let size = self.size
        let widthRatio = maxSize.width / size.width
        let heightRatio = maxSize.height / size.height
        
        // Check if the current image size exceeds the maximum size
        if widthRatio >= 1.0 && heightRatio >= 1.0 {
            // The image is smaller than the maximum size, so no resizing needed
            return self
        }
        
        // Determine the scale factor that will ensure the image fits within maxSize
        let scaleFactor = min(widthRatio, heightRatio)
        
        // Calculate the new size based on the scale factor
        let newSize = CGSize(width: size.width * scaleFactor, height: size.height * scaleFactor)
        
        // Create a new image context with the new size
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        self.draw(in: CGRect(origin: .zero, size: newSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return resizedImage
    }
}
