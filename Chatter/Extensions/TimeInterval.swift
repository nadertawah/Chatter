//
//  TimeInterval.swift
//  Chatter
//
//  Created by nader said on 16/07/2022.
//

import Foundation

extension TimeInterval
{
    var timeString: String
    {
        let min = Int(self / 60)
        let sec = Int(self.truncatingRemainder(dividingBy: 60))
        return String(format: "%02d:%02d", min, sec)
    }
}
