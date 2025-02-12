//
//  UserSettings.swift
//  Insect_EP
//
//  Created by Javad on 8/13/24.
//

import Foundation


class UserSettings : NSObject {
    
    static let defaults = UserDefaults.standard

    
    static var username : String {
        get{
            return UserSettings.defaults.string(forKey: "username") ?? ""
        }
        set{
            UserSettings.defaults.set(newValue , forKey: "username")
        }
    }
    
    static var token : String {
        get{
            return UserSettings.defaults.string(forKey: "token") ?? ""
        }
        set{
            UserSettings.defaults.set(newValue , forKey: "token")
        }
    }
    
    static var purchasePageType : Int {
        get{
            return UserSettings.defaults.integer(forKey: "purchasePageType")
        }
        set{
            UserSettings.defaults.set(newValue , forKey: "purchasePageType")
        }
    }
    
    
    static var isPro : Bool{
        get{
            return UserSettings.defaults.bool(forKey: "isPro")
        }
        set{
            UserSettings.defaults.set(newValue , forKey: "isPro")
        }
    }
    
    
    static var isWatchOnBoarding : Bool{
        get{
            return UserSettings.defaults.bool(forKey: "isWatchOnBoarding")
        }
        set{
            UserSettings.defaults.set(newValue , forKey: "isWatchOnBoarding")
        }
    }
    
    static var videoIsWorking : Bool{
        get{
            return UserSettings.defaults.bool(forKey: "videoIsWorking")
        }
        set{
            UserSettings.defaults.set(newValue , forKey: "videoIsWorking")
        }
    }
    
    static func didShowWarning(title:String) -> Bool {
        return UserSettings.defaults.bool(forKey: "\(title.trimmingPrefix("_"))_warn")
    }
    
    static func setShowWarning(title:String) {
        UserSettings.defaults.set(true, forKey: "\(title.trimmingPrefix("_"))_warn")
    }
    
    static var autoAddToHistory : Bool{
        get{
            return UserSettings.defaults.bool(forKey: "autoAddToHistory")
        }
        set{
            UserSettings.defaults.set(newValue , forKey: "autoAddToHistory")
        }
    }
}
