//
//  Constants.swift
//  Chatter
//
//  Created by Nader Said on 12/07/2022.
//

import Foundation
import UIKit

struct Constants
{
    //Users
    static let kALLUSERS = "Users"
    static let kPUBLICKEY = "PublicKey"
    static let kAVATAR = "avatar"
    static let kCREATEDAT = "createdAt"
    static let kEMAIL = "email"
    static let kFULLNAME = "fullname"
    static let kONLINE = "isOnline"
    static let kUPDATEDAT = "updatedAt"
    static let kUSERID = "userId"
    //-------------------//

    
    //Messages
    static let kMESSAGES = "Messages"
    static let kCHATROOMID = "chatRoomID"
    static let kMESSAGE = "Message"
    static let kDATE = "date"
    static let kDURATION = "duration"
    static let kMESSAGEID = "messageId"
    static let kMESSAGETYPE = "messageType"
    static let kSENDERID = "senderId"
    static let kISOUTGOING = "isOutgoing"
    
    static let kLASTMESSAGE = "lastMessage"
    static let kUNREADCOUNTER = "unreadCounter"
    static let kCHATISREQUESTED = "isRequested"

    //-------------------//

    
    //FireStore
    static let kIMAGESTORE = "images"
    static let kVOICENOTESTORE = "VoiceNotes"
    //-------------------//
    
    //URLs
    static let fireBaseDBUrl = "https://chatter-4b1b3-default-rtdb.europe-west1.firebasedatabase.app/"
    static let fireBaseStoreUrl = "gs://chatter-4b1b3.appspot.com"
    //-------------------//

    static let screenWidth = UIScreen.main.bounds.width
    static let screenHeight = UIScreen.main.bounds.height
    
    static let keyChainService = "PrivateKey"
    
    static let kCOUNT = "count"
    
    static let kCHATREQUESTS = "ChatRequests"

}

