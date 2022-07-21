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
   
    //MARK: - intent(s)
    func login(_ email: String, _ password:String,completion : @escaping (AuthDataResult?, Error?) -> () )
    {
        DispatchQueue.global(qos: .userInteractive).async
        {
            Auth.auth().signIn(withEmail: email, password: password)
            {
                result, error in
                DispatchQueue.main.async
                {
                    completion(result, error)
                    if result != nil
                    {
                        FireBaseDB.sharedInstance.setOnlineStatus(isOnline: true)
                    }
                }
            }
        }
    }
    func register(name: String ,email: String, password: String,avatar : UIImage,completion: @escaping (AuthDataResult?, Error?) -> () )
    {
        DispatchQueue.global(qos: .userInteractive).async
        {
            Auth.auth().createUser(withEmail: email, password: password)
            {
                [weak self] result , error  in
                guard let self = self else {return}
                if result != nil
                {
                    let keys = self.createAndSaveCryptKeys()
                    
                    let UID = result!.user.uid
                    let user = User(userID: UID, createdAt: Date(), updatedAt: Date(), email: email, fullName: name, avatar: avatar.imageToString(), publicKey: keys.publicKeyToString())
                    
                    //save to firebase db
                    FireBaseDB.sharedInstance.DBref.child(Constants.kALLUSERS).child(UID).setValue(user.userDictionary())
                }
                DispatchQueue.main.async
                {
                    completion(result, error)
                }
            }
        }
    }
    
    private func createAndSaveCryptKeys() -> CryptoManager
    {
        let cryptoManager = CryptoManager()
        
        //save privateKey to keychain
        KeyChainManager.save(data: cryptoManager.privateKey.rawRepresentation, account: Helper.getCurrentUserID())
        
        //save publicKey to FireBase
        FireBaseDB.sharedInstance.setPublicKey(key: cryptoManager.publicKeyToString())
        
        return cryptoManager
    }
}
