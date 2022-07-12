//
//  URL.swift
//  Chatter
//
//  Created by Nader Said on 12/07/2022.
//

import Foundation

extension URL
{
    static func chatterImgFileURL(chatRoomID: String, msgDate: Date) -> URL
    {
        let imgfileName = "\(chatRoomID)/\(msgDate.chatterStringFromDate()).png"
        return FileManager.documentDir().appendingPathComponent(imgfileName)
    }
}
