//
//  UsersVM.swift
//  Chatter
//
//  Created by Nader Said on 12/07/2022.
//

import Foundation
import RxRelay

class UsersVM
{
    init()
    {
        getUsersFromDB()
    }
    
    //MARK: - Var(s)
    private(set) var users = BehaviorRelay<[User]>(value: [])
    
    
    //MARK: - Helper Funcs
    private func getUsersFromDB()
    {
        FireBaseDB.sharedInstance.DBref.child(Constants.kALLUSERS)
            .observe(.childAdded, with: {[weak self] snapshot in
                if let dictionaryUser = snapshot.value as? NSDictionary
                {
                    guard let self = self else {return}
                    
                    let user = User(dictionaryUser)
                    if user.userID != Helper.getCurrentUserID()
                    {
                        var usersArr = self.users.value
                        usersArr.append(user)
                        self.users.accept(usersArr)
                    }
                }
            })
    }
}
