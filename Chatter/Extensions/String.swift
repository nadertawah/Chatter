//
//  String.swift
//  Chatter
//
//  Created by nader said on 19/07/2022.
//

import Foundation

extension String
{
    func toBase64EncoedData() -> Data?
    {
        
        Data(base64Encoded: Data(self.utf8).base64EncodedString())
    }
}
