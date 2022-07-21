//
//  FireBaseDB.swift
//  Chatter
//
//  Created by Nader Said on 12/07/2022.
//

import Foundation
import FirebaseDatabase

class FireBaseDB
{
    private init()
    {
        let db = Database.database(url: Constants.fireBaseDBUrl)
        db.isPersistenceEnabled = true
        DBref = db.reference()
    }
    
    static let sharedInstance = FireBaseDB()
    var DBref  : DatabaseReference
}


extension FireBaseDB
{
    func observeAvatar(_ userID: String,changeHandler : @escaping (String)->())
    {
        FireBaseDB.sharedInstance.DBref.child(Constants.kALLUSERS).child(userID).child(Constants.kAVATAR)
            .observe(.value)
        { avatarSnapshot in
            if let avatar = avatarSnapshot.value as? String
            {
                changeHandler(avatar)
            }
        }
    }
    
    func observeOnlineStatus(friendID : String,changeHandler : @escaping (Bool)->())
    {
        FireBaseDB.sharedInstance.DBref.child(Constants.kALLUSERS).child(friendID).child(Constants.kONLINE)
            .observe(.value)
        { onlineSnapshot in
            if let isOnline = onlineSnapshot.value as? Int
            {
                changeHandler(isOnline == 1)
            }
        }
    }
    
    func setOnlineStatus(isOnline: Bool)
    {
        FireBaseDB.sharedInstance.DBref.child(Constants.kALLUSERS).child(Helper.getCurrentUserID()).child(Constants.kONLINE)
            .setValue(isOnline ? 1 : 0)
    }
    
    func resetUnreadCounter(chatRoomID:String)
    {
        FireBaseDB.sharedInstance.DBref.child(Constants.kMESSAGES).child(Helper.getCurrentUserID()).child(chatRoomID).child(Constants.kUNREADCOUNTER)
            .setValue(0)
    }
    
    func setPublicKey(key : String)
    {
        FireBaseDB.sharedInstance.DBref.child(Constants.kALLUSERS).child(Helper.getCurrentUserID()).child(Constants.kPUBLICKEY)
            .setValue(key)
    }
}
