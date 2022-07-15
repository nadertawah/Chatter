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
    
    func resetUnreadCounter(chatRoomID:String)
    {
        FireBaseDB.sharedInstance.DBref.child(Constants.kMESSAGES).child(Helper.getCurrentUserID()).child(chatRoomID).child(Constants.kUNREADCOUNTER)
            .setValue(0)
    }
}
