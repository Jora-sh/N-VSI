//
//  UserSettings.swift
//  Insect_EP
//
//  Created by Javad on 8/13/24.
//

import Foundation
import UIKit


class UserSettings : NSObject {
    
    private static let keychainKey = "com.ssss.VideoFaceSwap"
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
    
    static var imageIsWorking : Bool{
        get{
            return UserSettings.defaults.bool(forKey: "videoIsWorking")
        }
        set{
            UserSettings.defaults.set(newValue , forKey: "videoIsWorking")
        }
    }
    
    static var didShowTermsDialog : Bool{
        get{
            return UserSettings.defaults.bool(forKey: "didShowTermsDialog")
        }
        set{
            UserSettings.defaults.set(newValue , forKey: "didShowTermsDialog")
        }
    }
    
    static var didShowTemplateOnBoarding : Bool{
        get{
            return UserSettings.defaults.bool(forKey: "isShowTemplateOnBoarding")
        }
        set{
            UserSettings.defaults.set(newValue , forKey: "isShowTemplateOnBoarding")
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
    
    static var didRequestReview : Bool{
        get{
            return UserSettings.defaults.bool(forKey: "didRequestReview")
        }
        set{
            UserSettings.defaults.set(newValue , forKey: "didRequestReview")
        }
    }
    
    // Updated to return UUID type with IDFV + Keychain backup
    static func getAppAccountToken() -> UUID {
        // 1. Try to get from Keychain first
        if let savedToken = KeychainHelper.standard.read(service: keychainKey, account: "deviceID"),
           let uuid = UUID(uuidString: savedToken) {
            return uuid
        }
        
        // 2. Use IDFV if available
        if let idfv = UIDevice.current.identifierForVendor {
            KeychainHelper.standard.save(idfv.uuidString, service: keychainKey, account: "deviceID")
            return idfv
        }
        
        // 3. Generate UUID as last fallback (rare case)
        let newToken = UUID()
        KeychainHelper.standard.save(newToken.uuidString, service: keychainKey, account: "deviceID")
        return newToken
    }
}

class KeychainHelper {
    static let standard = KeychainHelper()
    
    private init() {}
    
    func save(_ value: String, service: String, account: String) {
        let data = Data(value.utf8)
        
        // Delete old item if it exists
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account
        ] as CFDictionary
        SecItemDelete(query)
        
        // Add new item with proper attributes
        let attributes = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account,
            kSecValueData: data,
            kSecAttrAccessible: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly,
            kSecAttrSynchronizable: false
        ] as CFDictionary
        
        let status = SecItemAdd(attributes, nil)
        if status != errSecSuccess {
            print("⚠️ Keychain save error: \(status)")
        }
    }
    
    func read(service: String, account: String) -> String? {
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account,
            kSecReturnData: true,
            kSecMatchLimit: kSecMatchLimitOne
        ] as CFDictionary
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query, &result)
        
        guard status == errSecSuccess,
              let data = result as? Data else {
            return nil
        }
        
        return String(data: data, encoding: .utf8)
    }
    
    func delete(service: String, account: String) {
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account
        ] as CFDictionary
        SecItemDelete(query)
    }
}


