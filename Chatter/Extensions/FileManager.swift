//
//  FileManager.swift
//  Chatter
//
//  Created by Nader Said on 12/07/2022.
//

import Foundation

extension FileManager
{
    static func documentDir() -> URL
    {
        try! FileManager().url(for:.documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    }
    
    static func tempVoiceNoteDir() -> URL
    {
        documentDir().appendingPathComponent("recordTemp.caf")
    }
}
