//
//  ProfileVM.swift
//  Chatter
//
//  Created by nader said on 14/07/2022.
//

import Foundation
import RxRelay
import FirebaseAuth

class ProfileVM
{
    
    init()
    {
        DispatchQueue.global(qos: .userInteractive).async
        { [weak self] in
            self?.getUserData()
        }
        
    }
    
    //MARK: - Var(s)
    private(set) var user = BehaviorRelay<User>(value: User(userID: "", createdAt: Date(), updatedAt: Date(), email: "", fullName: "", avatar: ""))
    
    //MARK: - intent(s)
    func logout(completion : @escaping ()->())
    {
        DispatchQueue.global(qos: .userInteractive).async
        {
            do {
                FireBaseDB.sharedInstance.setOnlineStatus(isOnline: false)
                try Auth.auth().signOut()
                DispatchQueue.main.async
                {
                    completion()
                }
            }
            catch { print("already logged out") }
        }
    }
    
    //MARK: - Helper Funcs
    func getUserData()
    {
        FireBaseDB.sharedInstance.DBref.child(Constants.kALLUSERS).child(Helper.getCurrentUserID())
            .observe(.value, with: {[weak self] snapshot in
                if let dictionaryUser = snapshot.value as? NSDictionary
                {
                    let user = User(dictionaryUser)
                    self?.user.accept(user)
                }
                
            })
    }
    
    func changeAvatar(avatarStr : String)
    {
        //save to firebase db
        FireBaseDB.sharedInstance.DBref.child(Constants.kALLUSERS).child(Helper.getCurrentUserID()).child(Constants.kAVATAR).setValue(avatarStr)
    }
    
}
