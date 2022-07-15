//
//  Date.swift
//  Chatter
//
//  Created by Nader Said on 12/07/2022.
//

import Foundation

extension Date
{
    var midnight: Date
    {
        Calendar(identifier: .gregorian).startOfDay(for: self)
    }
    
    static func chatterDate(str : String) -> Date
    {
        DateFormatter.chatterDateFormatter().date(from: str) ?? Date()
    }
    
    func chatterStringFromDate() -> String
    {
        DateFormatter.chatterDateFormatter().string(from: self)
    }
    
    func chatterTimeElapsed() -> String
    {
        let seconds = NSDate().timeIntervalSince(self)
        
        var elapsed: String = ""
        
        
        if (seconds < 60)
        {
            elapsed = "Just now"
        }
        else if (seconds < 60 * 60)
        {
            let minutes = Int(seconds / 60)
            
            var minText = "min"
            if minutes > 1
            {
                minText = "mins"
            }
            elapsed = "\(minutes) \(minText)"
            
        }
        else if (seconds < 24 * 60 * 60)
        {
            let hours = Int(seconds / (60 * 60))
            var hourText = "hour"
            if hours > 1
            {
                hourText = "hours"
            }
            elapsed = "\(hours) \(hourText)"
        }
        else
        {
            let dateFormatter = DateFormatter()
            dateFormatter.timeZone = TimeZone(secondsFromGMT: TimeZone.current.secondsFromGMT())
            dateFormatter.dateFormat = "yyyy-MM-dd"
            
            elapsed = "\(dateFormatter.string(from: self))"
        }
        
        return elapsed
    }
    
    func chatterTimeStamp() -> String
    {
        let seconds = self.timeIntervalSince(self.midnight)
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(secondsFromGMT: TimeZone.current.secondsFromGMT())
        
        if (seconds < 24 * 60 * 60)
        {
            dateFormatter.dateFormat = "hh:mm a"
        }
        else if seconds < 24 * 60 * 60 * 365
        {
            dateFormatter.dateFormat = "MM-dd hh:mm"
        }
        else
        {
            dateFormatter.dateFormat = "yyyy-MM-dd hh:mm"
        }
        return dateFormatter.string(from: self)
    }
    
    
    func localString(dateStyle: DateFormatter.Style = .medium, timeStyle: DateFormatter.Style = .medium) -> String
        {
            return DateFormatter.localizedString(
              from: self,
              dateStyle: dateStyle,
              timeStyle: timeStyle)
        }
}
