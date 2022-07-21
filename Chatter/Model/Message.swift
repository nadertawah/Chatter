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
    var date: Date
    var messageId: String
    var type : MessageType
    var isOutgoing : Bool
    var duration : TimeInterval?
    
    init(content: String, type : MessageType,isOutgoing : Bool, duration : TimeInterval?)
    {
        self.message = content
        self.date = Date()
        self.messageId = UUID().uuidString
        self.type = type
        self.duration = duration
        self.isOutgoing = isOutgoing
    }
    
    init(_ dictionary: NSDictionary)
    {
        if let msg = dictionary[Constants.kMESSAGE] as? String
        { message = msg }
        else{message = ""}
        
        if let isOutgoing = dictionary[Constants.kISOUTGOING] as? Bool
        { self.isOutgoing = isOutgoing }
        else { isOutgoing = true }
        
        if let dateSent = dictionary[Constants.kDATE] as? String
        {date = Date.chatterDate(str: dateSent)}
        else{date = Date()}
        
        messageId = ""
        
        if let messageType = dictionary[Constants.kMESSAGETYPE] as? String
        {type = MessageType(rawValue: messageType)! }
        else{type = MessageType.text}
        
        self.duration = dictionary[Constants.kDURATION] as? TimeInterval
    }
    
    //MARK: - Helper Funcs
    func messageDictionary() -> Dictionary<String, Any >
    {
        let sentAt = date.chatterStringFromDate()
        var dict = [Constants.kMESSAGE: message, Constants.kISOUTGOING: isOutgoing ,Constants.kDATE :  sentAt,Constants.kMESSAGETYPE: type.rawValue] as [String : Any]
        if type == .audio
        {
            dict[Constants.kDURATION] = duration
        }
        return dict
    }
}

enum MessageType: String
{
    case text
    case image
    case location
    case audio
    case video
    case system
}

