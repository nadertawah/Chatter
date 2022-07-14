//
//  User.swift
//  Chatter
//
//  Created by Nader Said on 12/07/2022.
//

import Foundation

struct User
{
    let userID : String
        let createdAt : Date
        var updatedAt : Date
        var email : String
        var fullName : String
        var avatar : String
        
        
        init(userID : String, createdAt : Date, updatedAt : Date, email : String, fullName : String, avatar : String)
        {
            self.userID = userID
            self.createdAt = createdAt
            self.updatedAt = updatedAt
            self.email = email
            self.fullName = fullName
            self.avatar = avatar
        }
        
        init(_ dictionary: NSDictionary)
        {
            userID = dictionary[Constants.kUSERID] as! String
            createdAt = Date.chatterDate(str: dictionary[Constants.kCREATEDAT] as? String ?? "")
            updatedAt = Date.chatterDate(str: dictionary[Constants.kUPDATEDAT] as? String ?? "")
            email = dictionary[Constants.kEMAIL] as! String
            fullName = dictionary[Constants.kFULLNAME] as! String
            avatar = dictionary[Constants.kAVATAR] as! String
        }
        
        //MARK: - Helper Funcs
        func userDictionary() -> NSDictionary
    {
            
        let createdAt = createdAt.chatterStringFromDate()
        let updatedAt = updatedAt.chatterStringFromDate()
            
            return NSDictionary(objects: [userID,               createdAt,               updatedAt,               email,               fullName,               avatar],
                                forKeys: [Constants.kUSERID as NSCopying, Constants.kCREATEDAT as NSCopying, Constants.kUPDATEDAT as NSCopying, Constants.kEMAIL as NSCopying, Constants.kFULLNAME as NSCopying, Constants.kAVATAR as NSCopying])
            
        }
}
