//
//  User.swift
//  Chatter
//
//  Created by Nader Said on 12/07/2022.
//

import Foundation

struct User
{
    var userID : String
    let createdAt : Date
    var updatedAt : Date
    var email : String
    var fullName : String
    var avatar : String
    var publicKey : String
    
    init(userID : String, createdAt : Date, updatedAt : Date, email : String, fullName : String, avatar : String,publicKey : String)
    {
        self.userID = userID
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.email = email
        self.fullName = fullName
        self.avatar = avatar
        self.publicKey = publicKey
    }
    
    init(_ dictionary: NSDictionary)
    {
        userID = dictionary.allKeys.first as? String ?? ""
        let dictValue = dictionary[userID] as? NSDictionary
        
        createdAt = Date.chatterDate(str: dictValue?[Constants.kCREATEDAT] as? String ?? "")
        updatedAt = Date.chatterDate(str: dictValue?[Constants.kUPDATEDAT] as? String ?? "")
        email = dictValue?[Constants.kEMAIL] as? String ?? ""
        fullName = dictValue?[Constants.kFULLNAME] as? String ?? ""
        avatar = dictValue?[Constants.kAVATAR] as? String ?? ""
        publicKey = dictValue?[Constants.kPUBLICKEY] as? String ?? ""
    }
    
    //MARK: - Helper Funcs
    func userDictionary() -> NSDictionary
    {
        
        let createdAt = createdAt.chatterStringFromDate()
        let updatedAt = updatedAt.chatterStringFromDate()
        
        return NSDictionary(objects: [createdAt,    updatedAt,  email,    fullName,   avatar , publicKey],
                            forKeys: [Constants.kCREATEDAT as NSCopying, Constants.kUPDATEDAT as NSCopying, Constants.kEMAIL as NSCopying, Constants.kFULLNAME as NSCopying, Constants.kAVATAR as NSCopying, Constants.kPUBLICKEY as NSCopying])
    }
}
