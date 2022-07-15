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
        DispatchQueue.global(qos: .userInteractive).async
        {[weak self] in
            self?.getUsersFromDB()
        }
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
                        
                        //observe avatar
                        self.observeAvatar(user.userID)
                    }
                }
            })
    }
    
    private func observeAvatar(_ friendID: String)
    {
        FireBaseDB.sharedInstance.observeAvatar(friendID)
        {
            [weak self] avatar in
            guard let self = self else{return}
            
            var usersArr = self.users.value
            
            if let indx = usersArr.firstIndex(where: {$0.userID == friendID })
            {
                usersArr[indx].avatar = avatar
                self.users.accept(usersArr)
            }
        }
    }
}
