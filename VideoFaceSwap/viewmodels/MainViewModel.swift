//
//  MainViewModel.swift
//  VideoFaceSwap
//
//  Created by Javad on 11/3/24.
//

import Foundation
import SwiftUI
import Alamofire
import SwiftyJSON
import OneSignalFramework
import AVFoundation

//let base_url = "https://swp.yagorai.com/nexora-swap-ios-stage/api/"
let base_url = "https://swp.yagorai.com/nexora-swap-ios/api/"

class MainViewModel : ObservableObject {
    
    @Published var isLoadingSignUp = false
    @Published var SCREEN_VIEW : ScreenEnum = .Splash
    @Published var categories : [CategoryModel] = []
    @Published var templateItems : [TemplateModel] = []
    @Published var userModel : UserModel? = nil
    @Published var homeConfig : GetHomeResponseModel? = nil
    @Published var isHistoryLoading = false
    @Published var historyList : [CreationModel] = []
    
    
    @Published var templatePlayers: [TemplateModel: AVPlayer] = [:]
        
    func player(for template: TemplateModel) -> AVPlayer {
        if let existingPlayer = templatePlayers[template] {
            return existingPlayer
        }
        
        let newPlayer = AVPlayer(url: URL(string: template.templateLowResolutionUrl)!)
        newPlayer.volume = 0.0
        templatePlayers[template] = newPlayer
        return newPlayer
    }
    
    func signupUser(onResponse : @escaping (Error?) -> Void) {
        
        let headers : HTTPHeaders = [
            "x-api-key" : "ae6a1d02bde6a2e299e2e2033e6a2e20310686"
        ]
        
        let url = URL(string: "\(base_url)auth/signup")!
        
        if UserSettings.username == "" {
            UserSettings.username = "IOS-\(UUID().uuidString)"
        }
        let parameters = [
            "username":"\(UserSettings.getAppAccountToken())",
            "appAccountToken":"\(UserSettings.getAppAccountToken())"
        ]
        
        print(parameters)
        
        AF.request(url,method: .post,parameters: parameters,headers: headers)
            .validate()
            .response { result in
                
                
                switch result.result{
                    
                case .success(let value):
                    let json = JSON(value ?? "{}")
                    print(json)
                    
                    let data = MyDecoder<UserResponseModel>().decodeJSON(json: value!)
                    
                    switch data {
                    case .success(let data):
                        print(data ?? "")
                        UserSettings.token = data?.user?.token?.token ?? ""
                        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                            
                            
                            if self.isLoadingSignUp {
                                self.SCREEN_VIEW = .Main
                            }
//                            self.getMe {_ in}
                        }
                        
                        onResponse(nil)
                        
                    case .failure(let error):
                        self.signupUser(onResponse: onResponse)
                    }
                    
                    
                case .failure(let err):
                    print(err.localizedDescription)
                    self.signupUser(onResponse: onResponse)
                }
            }
    }
    
    func getAllCategories(onResponse : @escaping (Error?) -> Void) {
        
        if categories.count != 0 {
            return
        }
        
        
        let headers : HTTPHeaders = [
            "Authorization" : "Bearer \(UserSettings.token)",
            "x-api-key" : "ae6a1d02bde6a2e299e2e2033e6a2e20310686"
        ]
        
        print(headers)
        
        let url = URL(string: "\(base_url)templates/categories")!

        
        AF.request(url,method: .get,headers: headers)
            .validate()
            .response { result in
                
                
                switch result.result{
                    
                case .success(let value):
                    let json = JSON(value ?? "{}")
                    print(json)
                    
                    let data = MyDecoder<GetCategoryResponseModel>().decodeJSON(json: value!)
                    
                    switch data {
                    case .success(let data):
                        print(data ?? "")
                        self.categories = data?.categories ?? []
                        
                        onResponse(nil)
                        
                    case .failure(let error):
                        self.signupUser { err in
                            self.getAllCategories(onResponse: onResponse)
                        }
                    }
                    
                    
                case .failure(let err):
                    print(err.localizedDescription)
                    self.signupUser { err in
                        self.getAllCategories(onResponse: onResponse)
                    }
                }
            }
    }
    
    func getMe(onResponse : @escaping (Error?) -> Void) {
        
        self.getHomeConfig()
        
        let headers : HTTPHeaders = [
            "Authorization" : "Bearer \(UserSettings.token)",
            "x-api-key" : "ae6a1d02bde6a2e299e2e2033e6a2e20310686"
        ]
        
        print(headers)
        
        let url = URL(string: "\(base_url)users/me")!

        
        AF.request(url,method: .get,headers: headers)
            .validate()
            .response { result in
                print(result.data ?? "")
                
                switch result.result{
                    
                case .success(let value):
                    let json = JSON(value ?? "{}")
                    print(json)
                    
                    let data = MyDecoder<UserResponseModel>().decodeJSON(json: value!)
                    
                    switch data {
                    case .success(let data):
                        print(data ?? "")
                        UserSettings.autoAddToHistory = data?.user?.autoAddToHistory ?? false
                        
                        self.userModel = data?.user
                        OneSignal.login(self.userModel?.id ?? "NO_ID")
                        onResponse(nil)
                        
                    case .failure(let error):
                        print(error?.localizedDescription ?? "")
                        self.signupUser { e in
                            onResponse(e)
                        }
                    }
                    
                    
                case .failure(let err):
                    print(err.localizedDescription)
                    self.signupUser { e in
                        onResponse(e)
                    }
                    
                }
            }
    }
    
    func getTemplateForCategoryById(id:String, onResponse : @escaping ([TemplateModel]?,Error?) -> Void) {
        
        
        let headers : HTTPHeaders = [
            "Authorization" : "Bearer \(UserSettings.token)",
            "x-api-key" : "ae6a1d02bde6a2e299e2e2033e6a2e20310686"
        ]
        
        print(headers)
        
        let url = URL(string: "\(base_url)templates/category/\(id)")!

        
        AF.request(url, method: .get, headers: headers)
            .validate()
            .response { result in
                
                
                switch result.result{
                    
                case .success(let value):
                    let json = JSON(value ?? "{}")
                    print(json)
                    
                    let data = MyDecoder<GetCategoryByIdResponseModel>().decodeJSON(json: value!)
                    
                    switch data {
                    case .success(let data):
                        print(data ?? "")
                        
                        onResponse(data?.templates,nil)
                        
                    case .failure(let error):
                        print(error?.localizedDescription)
                        self.signupUser { err in
                            self.getTemplateForCategoryById(id: id, onResponse: onResponse)
                        }
                    }
                    
                    
                case .failure(let err):
                    print(err.localizedDescription)
                    self.signupUser { err in
                        self.getTemplateForCategoryById(id: id, onResponse: onResponse)
                    }
                }
            }
    }
    
    func sendContactUs(message:String) {
        
        
        let headers : HTTPHeaders = [
            "Authorization" : "Bearer \(UserSettings.token)",
            "x-api-key" : "ae6a1d02bde6a2e299e2e2033e6a2e20310686"
        ]
        
        print(headers)
        
        let parameter = ["message":message]

        
        let url = URL(string: "\(base_url)contact-us/")!

        
        AF.request(url,method: .post,parameters: parameter,headers: headers)
            .validate()
            .response { result in
                
                
                switch result.result{
                    
                case .success(let value):
                    let json = JSON(value ?? "{}")
                    print(json)
                    
                case .failure(let err):
                    print(err.localizedDescription)
                }
            }
    }
    
    func sendPurchaseToServer(parameters : [String:Any], onResponse: @escaping () -> Void) {
        
        let url = "\(base_url)users/verifyPurchase"
        
        let headers : HTTPHeaders = [
            "Authorization" : "Bearer \(UserSettings.token)",
            "x-api-key" : "ae6a1d02bde6a2e299e2e2033e6a2e20310686"
        ]
        
        print(parameters)
        
        AF.request(url,method: .post, parameters: parameters, headers: headers)
            .validate()
            .response { result in
                
                print(JSON(result.data))
                
                switch result.result{
                    
                case .success(let value):
                    let json = JSON(value ?? "{}")
                    print(json)
                    let data = MyDecoder<UserResponseModel>().decodeJSON(json: value!)
                    
                    switch data {
                    case .success(let data):
                        print(data ?? "")
                        
                        self.userModel = data?.user
                        onResponse()
                        
                    case .failure(let error):
                        print(error?.localizedDescription ?? "")
                        self.signupUser { err in
                            self.sendPurchaseToServer(parameters: parameters, onResponse: onResponse)
                        }
                    }
                case .failure(let err):
                    print(err.localizedDescription)
                    self.signupUser { err in
                        self.sendPurchaseToServer(parameters: parameters, onResponse: onResponse)
                    }
                }
            }
    }
    
    func getHomeConfig() {
        
        let headers : HTTPHeaders = [
            "Authorization" : "Bearer \(UserSettings.token)",
            "x-api-key" : "ae6a1d02bde6a2e299e2e2033e6a2e20310686"
        ]
        
        print(headers)
        
        let url = URL(string: "\(base_url)home/")!

        
        AF.request(url,method: .get,headers: headers)
            .validate()
            .response { result in
                
                
                switch result.result{
                    
                case .success(let value):
                    let json = JSON(value ?? "{}")
                    print(json)
                    
                    let data = MyDecoder<GetHomeResponseModel>().decodeJSON(json: value!)
                    
                    switch data {
                    case .success(let data):
                        print(data ?? "")
                        
                        UserSettings.videoIsWorking = data?.homeConfig?.features?.videoWorking ?? false
                        print(data?.homeConfig?.features?.videoWorking ?? false)
                        self.homeConfig = data
                        
                        
                    case .failure(let error):
                        print(error?.localizedDescription ?? "")
                    }
                    
                    
                case .failure(let err):
                    print(err.localizedDescription)
                    
                }
            }
    }
    
    func getMyCreations(onResponse : @escaping (Error?) -> Void) {
        
        
        let headers : HTTPHeaders = [
            "Authorization" : "Bearer \(UserSettings.token)",
            "x-api-key" : "ae6a1d02bde6a2e299e2e2033e6a2e20310686"
        ]
        
        print(headers)
        
        let url = URL(string: "\(base_url)users/swap-history")!

        withAnimation {
            isHistoryLoading = true
        }
        
        print(url)
        
        AF.request(url,method: .get,headers: headers)
            .validate()
            .response { result in
                
                
                switch result.result{
                    
                case .success(let value):
                    let json = JSON(value ?? "{}")
                    print(json)
                    
                    let data = MyDecoder<GetCreationsResponseModel>().decodeJSON(json: value!)
                    
                    switch data {
                    case .success(let data):
                        print(data ?? "")
                        withAnimation {
                            self.isHistoryLoading = false
                        }
                        self.historyList = data?.videoSwaps ?? []
                        
                        
                    case .failure(let error):
                        print(error?.localizedDescription ?? "")
                        self.signupUser { err in
                            self.getMyCreations(onResponse: onResponse)
                        }
                    }
                    
                    
                case .failure(let err):
                    print(err.localizedDescription)
                    self.signupUser { err in
                        self.getMyCreations(onResponse: onResponse)
                    }
                    
                }
            }
    }
    
    func toggleAddToHistory() {
        let url = "\(base_url)users/toggle-add-to-history"
        
        let headers : HTTPHeaders = [
            "Authorization" : "Bearer \(UserSettings.token)",
            "x-api-key" : "ae6a1d02bde6a2e299e2e2033e6a2e20310686"
        ]
        
        
        AF.request(url,method: .post, headers: headers)
            .validate()
            .response { result in
                
                print(JSON(result.data))
                
                self.getMe{_ in}
                
            }
    }

}

struct UserResponseModel : Codable {
    let success: Bool
    let user: UserModel?
}

struct UserModel : Codable {
    let username: String?
    let role:String?
    let id:String?
    let token: TokenModel?
    let credits:Int?
    let autoAddToHistory: Bool?
}

struct TokenModel : Codable {
    let token:String
}

struct GetCategoryResponseModel : Codable {
    let success:Bool
    let categories : [CategoryModel]?
    let message:String?
}

struct CategoryModel : Codable {
    let name:String
    let id:String
}

struct GetCategoryByIdResponseModel : Codable {
    let success : Bool
    let message:String?
    let templates:[TemplateModel]?
}

struct TemplateModel : Codable, Hashable {
    let id : String
    let templateName : String
    let isActive : Bool
    let isFree : Bool
    let categoryId : String
    let templateUrl : String
    let templateLowResolutionUrl : String
    let templateLowResUrlV2 : String?
    let thumbnailUrl : String
    let duration: Float?
}


struct GetHomeResponseModel : Codable {
    let success:Bool
    let homeConfig: HomeConfigModel?
}

struct HomeConfigModel : Codable {
    let icons:ImageConfigModel?
    let features: FeatureModel?
    let id:String
}

struct ImageConfigModel : Codable {
    let bannerImage:String?
}

struct FeatureModel  :Codable {
    let videoWorking:Bool?
    let testFeature:Bool?
}

struct GetCreationsResponseModel : Codable {
    let success:Bool
    let videoSwaps: [CreationModel]?
}

struct CreationModel : Codable {
    let isLoading : Bool
    let vidUrl:String?
    let jobId:String?
    let videoName:String?
}
