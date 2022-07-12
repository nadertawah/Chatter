//
//  LoginRegisterVM.swift
//  Chatter
//
//  Created by Nader Said on 12/07/2022.
//

import Foundation
import FirebaseAuth

class LoginRegisterVM
{
   
    
    init(dataPersistant : DataPersistantProtocol)
    {
        self.dataPersistant = dataPersistant
    }
    
    //MARK: - Var(s)
    var dataPersistant : DataPersistantProtocol!
    
    //MARK: - intent(s)
    func login(_ email: String, _ password:String,completion : @escaping (AuthDataResult?, Error?) -> () )
    {
        Auth.auth().signIn(withEmail: email, password: password)
        {
            result, error in
            completion(result, error)
        }
        
    }
    func register(name: String ,email: String, password: String,avatar : UIImage,completion: @escaping (AuthDataResult?, Error?) -> () )
    {
        Auth.auth().createUser(withEmail: email, password: password)
        {
            result , error  in
            if result != nil
            {
                let UID = result!.user.uid
                let user = User(userID: UID, createdAt: Date(), updatedAt: Date(), email: email, fullName: name, avatar: avatar.imageToString())
                
                //save to firebase db
                FireBaseDB.sharedInstance.DBref.child(Constants.kALLUSERS).child(UID).setValue(user.userDictionary())
            }
            completion(result , error)
        }
    }
}
