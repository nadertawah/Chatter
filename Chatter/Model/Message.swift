//
//  Message.swift
//  Chatter
//
//  Created by nader said on 12/07/2022.
//

import Foundation

struct Message
{
    var message: String
    var senderId: String
    var date: Date
    var messageId: String
    var type : MessageType

    init(content: String, senderId: String, type : MessageType)
    {
        self.message = content
        self.senderId = senderId
        self.date = Date()
        self.messageId = UUID().uuidString
        self.type = type
    }
    
    init(_ dictionary: NSDictionary)
    {
        if let msg = dictionary[Constants.kMESSAGE] as? String
        { message = msg }
        else{message = ""}
        
        if let sender = dictionary[Constants.kSENDERID] as? String
        { senderId = sender }
        else { senderId = "" }
        
        if let dateSent = dictionary[Constants.kDATE] as? String
        {date = Date.chatterDate(str: dateSent)}
        else{date = Date()}
        
        if let mesgID = dictionary[Constants.kMESSAGEID] as? String
        {messageId = mesgID}
        else{messageId = ""}
        
        if let messageType = dictionary[Constants.kMESSAGETYPE] as? String
        {type = MessageType(rawValue: messageType)! }
        else{type = MessageType.text}
    }
    
    //MARK: - Helper Funcs
    func messageDictionary() -> NSDictionary {
        
        let sentAt = Date.chatterStringFromDate(date)
        
        return NSDictionary(objects: [message,               senderId,               sentAt,             messageId,               type.rawValue],
                            forKeys: [Constants.kMESSAGE as NSCopying, Constants.kSENDERID as NSCopying, Constants.kDATE as NSCopying, Constants.kMESSAGEID as NSCopying, Constants.kMESSAGETYPE as NSCopying])
        
    }
    
    
}

enum MessageType: String
{
    case text
    case image
    case location
    case audio
    case video
}

func messageType(_ type: MessageType) -> String{
    return type.rawValue
}
