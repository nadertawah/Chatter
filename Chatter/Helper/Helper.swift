//
//  Helper.swift
//  Chatter
//
//  Created by Nader Said on 12/07/2022.
//

import Foundation
import FirebaseAuth

struct Helper
{
    static func getChatRoomID(ID1: String, ID2: String) -> String
    {
        let compariosnResult = ID1.compare(ID2).rawValue
        if(compariosnResult == 1){return ID2 + ID1}
        else {return ID1 + ID2}
    }
    
    //Auth
    static func getCurrentUserID() -> String
    {
        Auth.auth().currentUser?.uid ?? ""
    }

}
