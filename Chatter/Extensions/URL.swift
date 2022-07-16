//
//  URL.swift
//  Chatter
//
//  Created by Nader Said on 12/07/2022.
//

import Foundation

extension URL
{
    static private func chatFileUrl(_ chatRoomID: String,_ msgDate: Date,ext: String) -> URL
    {
        let fileName = "\(chatRoomID)/\(msgDate.chatterStringFromDate()).\(ext)"
        return FileManager.documentDir().appendingPathComponent(fileName)
    }
    
    static func chatImgFileURL(chatRoomID: String, msgDate: Date) -> URL
    {
        return chatFileUrl(chatRoomID, msgDate, ext: "png")
    }
    
    static func chatAudioFileUrl(chatRoomID: String, msgDate: Date) -> URL
    {
        return chatFileUrl(chatRoomID, msgDate, ext: "caf")
    }
}
