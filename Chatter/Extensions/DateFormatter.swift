//
//  DateFormatter.swift
//  Chatter
//
//  Created by Nader Said on 12/07/2022.
//

import Foundation

extension DateFormatter
{
    static func chatterDateFormatter() -> DateFormatter
    {
        let dateFormat = "yyyyMMddHHmmss"
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.init(identifier: "en")
        dateFormatter.timeZone = TimeZone(secondsFromGMT: TimeZone.current.secondsFromGMT())
        dateFormatter.dateFormat = dateFormat
        return dateFormatter
    }
}
