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
    //User
    static let kUSERID = "userId"
    static let kCREATEDAT = "createdAt"
    static let kUPDATEDAT = "updatedAt"
    static let kEMAIL = "email"
    static let kPHONE = "phone"
    static let kPUSHID = "pushId"
    static let kFIRSTNAME = "firstname"
    static let kLASTNAME = "lastname"
    static let kFULLNAME = "fullname"
    static let kAVATAR = "avatar"
    static let kCURRENTUSER = "currentUser"
    static let kCITY = "city"
    static let kCOUNTRY = "country"

    static let kPRIVATE = "private"
    static let kGROUP = "group"

    //
    static let kALLUSERS = "Users"
    static let kMESSAGES = "Messages"
    static let kMESSAGE = "Message"
    static let kDATE = "date"
    static let kDURATION = "duration"

    //chats
    static let kCHATROOMID = "chatRoomID"
    static let kLASTMESSAGE = "lastMessage"
    static let kUNREADCOUNTER = "unreadCounter"
    static let kSENDERID = "senderId"
    static let kMESSAGETYPE = "messageType"
    static let kIMAGESTORE = "images"
    static let kVOICENOTESTORE = "VoiceNotes"


    static let kTYPE = "type"

    static let kGROUPID = "groupId"
    static let kRECENTID = "recentId"
    static let kMEMBERS = "members"
    static let kMEMBERSTOPUSH = "membersToPush"
    static let kDISCRIPTION = "discription"
    static let kWITHUSERUSERNAME = "withUserUserName"
    static let kWITHUSERUSERID = "withUserUserID"
    static let kOWNERID = "ownerID"
    static let kSTATUS = "status"
    static let kMESSAGEID = "messageId"
    static let kNAME = "name"
    static let kWITHUSERFULLNAME = "withUserFullName"
    static let kSENDERNAME = "senderName"

    static let kUSER = "user"


    static let fireBaseDBUrl = "https://chatter-4b1b3-default-rtdb.europe-west1.firebasedatabase.app/"
    static let fireBaseStoreUrl = "gs://chatter-4b1b3.appspot.com"
    
    static let chatterGreenColor = UIColor(red: 34/255, green: 132/255, blue: 60/255, alpha: 1)
    static let chatterGreyColor = UIColor(red: 44/255, green: 41/255, blue: 62/255, alpha: 1)
    
    static let screenWidth = UIScreen.main.bounds.width
}

