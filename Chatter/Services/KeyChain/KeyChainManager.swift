//
//  KeyChainManager.swift
//  Chatter
//
//  Created by nader said on 18/07/2022.
//

import Foundation


class KeyChainManager
{
    static func save(data: Data, service: String = Constants.keyChainService, account: String)
    {
        let query =
        [
            kSecValueData: data,
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account,
        ] as CFDictionary
        
        //Add data to keychain
        let status = SecItemAdd(query, nil)
        
        if status != errSecSuccess
        {
            print("Error saving to keychain: \(status)")
        }
    }
    
    static func deleteCurrentKeyChain(service: String = Constants.keyChainService, account: String = Helper.getCurrentUserID())
    {
        let query =
        [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account,
        ] as CFDictionary
        
        let status = SecItemDelete(query)
        if status != errSecSuccess
        {
            print("Error deleting from keychain: \(status)")
        }
    }
    
    static func get(service: String , account: String) -> Data?
    {
        let query =
        [
            kSecAttrService: service,
            kSecAttrAccount: account,
            kSecClass: kSecClassGenericPassword,
            kSecReturnData: true
        ] as CFDictionary
        
        var result: AnyObject?
        SecItemCopyMatching(query, &result)
        return (result as? Data)
    }
    
    static func getChatterPrivateKeyStr() -> String
    {
        let data = get(service: Constants.keyChainService, account: Helper.getCurrentUserID())
        let privateKeyStr = data?.base64EncodedString().addingPercentEncoding(withAllowedCharacters: .alphanumerics)
        return privateKeyStr ?? ""
    }
}
