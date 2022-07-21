//
//  RecentVM.swift
//  Chatter
//
//  Created by Nader Said on 12/07/2022.
//

import Foundation
import RxRelay
import CryptoKit

class RecentVM
{
    
    init()
    {
        DispatchQueue.global(qos: .userInteractive).async
        { [weak self] in
            self?.getFromDB()
        }
    }
    //MARK: - Var(s)
    private(set) var recentChats = BehaviorRelay<[(friend : User, lastMessage : Message, unreadCount: Int?)]>(value: [])
    var cryptoManager = CryptoManager()

    //MARK: - Helper Funcs
    private func handleLostPrivateKey()
    {
        KeyChainManager.deleteCurrentKeyChain()  //just for testing
        
        //get private key from keychain
        let privateKeyStr = KeyChainManager.getChatterPrivateKeyStr()
        if let privateKey =  CryptoManager.getPrivateKeyFromString(privateKeyStr: privateKeyStr)
        {
            self.cryptoManager = CryptoManager(privateKey: privateKey)
        }
        else //lost private key
        {
            //get old public key to make a chat request with it from the other user
            FireBaseDB.sharedInstance.DBref.child(Constants.kALLUSERS).child(Helper.getCurrentUserID()).child(Constants.kPUBLICKEY).observeSingleEvent(of: .value)
            {
                [weak self] DataSnapshot, _ in
                guard let self = self else{return}
                
                if let publicKey = DataSnapshot.value as? String
                {
                    //create new keys and save
                    self.createAndSaveCryptKeys()
                    
                    FireBaseDB.sharedInstance.DBref.child(Constants.kMESSAGES).child(Helper.getCurrentUserID()).getData
                    {
                         _ , snapshot in

                        guard let dictionaryChatroom = snapshot.value as? Dictionary<String, Any> else{return}
                        
                        //iterate through chats
                        for (chatRoomID, chatRoomValue) in dictionaryChatroom
                        {
                            let friendID = chatRoomID.replacingOccurrences(of: Helper.getCurrentUserID(), with: "")
                            
                            let chatDict = chatRoomValue as? NSDictionary
                            
                            if chatDict?[Constants.kCHATISREQUESTED] as? Bool == nil //if the chat is not already requested
                            {
                                if let messagesDict = chatDict?[Constants.kMESSAGES] as? NSDictionary , let unreadCount =  chatDict?[Constants.kUNREADCOUNTER] as? Int
                                {
                                    //add messages to requests with their key
                                    FireBaseDB.sharedInstance.DBref.child(Constants.kCHATREQUESTS).child(chatRoomID).child(Constants.kMESSAGES).child(publicKey)
                                        .setValue(messagesDict)
                                    
                                    //set unread count
                                    FireBaseDB.sharedInstance.DBref.child(Constants.kCHATREQUESTS).child(chatRoomID).child(Constants.kUNREADCOUNTER)
                                        .setValue(unreadCount)
                                    
                                    //request the new encrypted chat from the friend
                                    FireBaseDB.sharedInstance.DBref.child(Constants.kMESSAGES).child(friendID).child(chatRoomID).child(Constants.kCHATISREQUESTED)
                                        .setValue(true)
                                }
                            }
                            else
                            {
                                FireBaseDB.sharedInstance.DBref.child(Constants.kCHATREQUESTS).child(chatRoomID).removeValue()
                            }
                        }
                        
                        //delete messages from firebase for current user
                        FireBaseDB.sharedInstance.DBref.child(Constants.kMESSAGES).child(Helper.getCurrentUserID()).removeValue()
                    }
                }
            }
        }
    }
    
    private func createAndSaveCryptKeys()
    {
        cryptoManager = CryptoManager()
        
        //save privateKey to keychain
        KeyChainManager.save(data: cryptoManager.privateKey.rawRepresentation, account: Helper.getCurrentUserID())
        
        //save publicKey to FireBase
        FireBaseDB.sharedInstance.setPublicKey(key: cryptoManager.publicKeyToString())
    }
    private func getFromDB()
    {
        //get private key from keychain
        handleLostPrivateKey()
        
        // get all chatrooms and last messages and updated friend info
        FireBaseDB.sharedInstance.DBref.child(Constants.kMESSAGES).child(Helper.getCurrentUserID()).queryOrdered(byChild: "\(Constants.kLASTMESSAGE)/\(Constants.kDATE)")
            .observe(.childAdded, with: {[weak self] chatroomSnapshot in
                guard let dictionaryChatroom = chatroomSnapshot.value as? NSDictionary , let self = self else {return}
                
                let chatroomID = chatroomSnapshot.key
                let friendID = chatroomID.replacingOccurrences(of: Helper.getCurrentUserID(), with: "")
                
                guard let lastMessageDict = dictionaryChatroom[Constants.kLASTMESSAGE] as? NSDictionary else {return}
                let lastMessage = Message(lastMessageDict)
                
                //observe friend value
                self.observeFriendValue(friendID, dictionaryChatroom, lastMessage)
                
                //observe last message value
                self.observeLastMessage(chatroomID, friendID)
                
                //observe unread count
                self.observeUnreadCount(chatroomID, friendID)
                
                //obsereve avatar changes
                self.observeAvatar(friendID)
                
                //observe chat requests
                self.observeChatRequests(chatroomID,friendID)
            }
            )
        
        FireBaseDB.sharedInstance.DBref.child(Constants.kMESSAGES).child(Helper.getCurrentUserID()).queryOrdered(byChild: "\(Constants.kLASTMESSAGE)/\(Constants.kDATE)")
            .observe(.childRemoved, with: {[weak self] chatroomSnapshot in
                guard let self = self else {return}
               
                let chatroomID = chatroomSnapshot.key
                let currentUserID = Helper.getCurrentUserID()
                let friendID = chatroomID.replacingOccurrences(of: currentUserID, with: "")
                
                var newChatsArray = [(friend : User, lastMessage : Message, unreadCount: Int?)]()
                for chat in self.recentChats.value
                {
                    if friendID != chat.friend.userID
                    {
                        newChatsArray.append(chat)
                    }
                }
                self.recentChats.accept(newChatsArray)
            })
    }
    
    private func observeChatRequests(_ chatroomID : String,_ friendID : String)
    {
        //observe chat requests
        FireBaseDB.sharedInstance.DBref.child(Constants.kMESSAGES).child(Helper.getCurrentUserID()).child(chatroomID).child(Constants.kCHATISREQUESTED)
            .observe(.value)
        {
            [weak self] isRequestedSnapshot in
            guard let self = self , let chatIsRequested = isRequestedSnapshot.value as? Bool , chatIsRequested == true
            else{return}
            
            //remove chat
            FireBaseDB.sharedInstance.DBref.child(Constants.kMESSAGES).child(Helper.getCurrentUserID()).child(chatroomID).child(Constants.kMESSAGES).removeValue()
            
            //get chat request
            FireBaseDB.sharedInstance.DBref.child(Constants.kCHATREQUESTS).child(chatroomID).observeSingleEvent(of: .value)
            {
                chatRequestSnapshot in
                guard let chatRequestDict = chatRequestSnapshot.value as? NSDictionary, let keysAndMessagesDict = chatRequestDict[Constants.kMESSAGES] as? NSDictionary ,let friendUnreadCount = chatRequestDict[Constants.kUNREADCOUNTER] as? Int else{return}
                
                //get friend's new public key
                FireBaseDB.sharedInstance.DBref.child(Constants.kALLUSERS).child(friendID).child(Constants.kPUBLICKEY).observeSingleEvent(of: .value)
                {
                    newPublicKeySnapshot in
                    guard let newPublicKeyStr = newPublicKeySnapshot.value as? String else{return}
                    
                    //get unread messages count for currrent user
                    FireBaseDB.sharedInstance.DBref.child(Constants.kMESSAGES).child(Helper.getCurrentUserID()).child(chatroomID).child(Constants.kUNREADCOUNTER).observeSingleEvent(of: .value)
                    {
                        unreadSnapshot in
                        guard let myUnreadCounter = unreadSnapshot.value as? Int else{return}
                        
                        //get chat dict for both users
                        var currentUserMsgDict = [String: Any]()
                        var friendMsgDict = [String: Any]()
                        
                        var friendLastMessage = Message(NSDictionary())
                        friendLastMessage.date = Date(timeIntervalSince1970: 0)
                        
                        //iterate through messages, reEncrypt and append to the new dict
                        for (oldPublicKey, oldMessagesDict) in keysAndMessagesDict
                        {
                            if let oldMessagesDict = oldMessagesDict as? NSDictionary , let oldPublicKeyStr = oldPublicKey as? String
                            {
                                let newMessages = self.reEncryptMessages(oldMessagesDict, oldPublicKey: oldPublicKeyStr, newPublicKey: newPublicKeyStr)
                                
                                currentUserMsgDict.merge(newMessages.0) { current, _ in current}
                                friendMsgDict.merge(newMessages.2) { current, _ in current}
                                
                                if friendLastMessage.date < newMessages.1.date {friendLastMessage = newMessages.1 }
                            }
                        }
                        
                        var myLastMessage = friendLastMessage
                        myLastMessage.isOutgoing = !friendLastMessage.isOutgoing
                        
                        //add system message to both chats
                        let systemMessageContent = self.cryptoManager.encrypt(text: "Chat encryption keys have been refreshed.", ExternalPublicKeyStr: newPublicKeyStr)
                        
                        let systemMessage = Message(content: systemMessageContent, type: .system, isOutgoing: true, duration: nil)
                        currentUserMsgDict[systemMessage.messageId] = systemMessage.messageDictionary()
                        friendMsgDict[systemMessage.messageId] = systemMessage.messageDictionary()
                        
                        //Chat dicts
                        let myChatDict =
                        [
                            Constants.kMESSAGES : currentUserMsgDict,
                            Constants.kLASTMESSAGE : myLastMessage.messageDictionary(),
                            Constants.kUNREADCOUNTER : myUnreadCounter
                        ] as [String : Any]
                        
                        let friendsChatDict =
                        [
                            Constants.kMESSAGES : friendMsgDict,
                            Constants.kLASTMESSAGE : friendLastMessage.messageDictionary(),
                            Constants.kUNREADCOUNTER : friendUnreadCount
                        ] as [String : Any]
                        
                        
                        //set chats
                        FireBaseDB.sharedInstance.DBref.child(Constants.kMESSAGES).child(Helper.getCurrentUserID()).child(chatroomID).setValue(myChatDict)
                        
                        FireBaseDB.sharedInstance.DBref.child(Constants.kMESSAGES).child(friendID).child(chatroomID).setValue(friendsChatDict)
                        
                        //remove request
                        FireBaseDB.sharedInstance.DBref.child(Constants.kCHATREQUESTS).child(chatroomID).removeValue()
                    }
                }
            }
        }
    }
    
    
    private func observeFriendValue(_ friendID: String, _ dictionaryChatroom: NSDictionary, _ lastMessage: Message)
    {
        //observe friend value
        FireBaseDB.sharedInstance.DBref.child(Constants.kALLUSERS).child(friendID)
            .observe(.value){[weak self] friendSnapshot in
                guard let self = self else{return}
                if let friendDictionary = friendSnapshot.value as? NSDictionary
                {
                    let friend = User([friendSnapshot.key: friendDictionary])
                    
                    var tupleArr = self.recentChats.value
                    
                    if let index = tupleArr.firstIndex(where: {$0.friend.userID == friend.userID })
                    {
                        tupleArr[index].friend = friend
                    }
                    else
                    {
                        let unreadCount = dictionaryChatroom[Constants.kUNREADCOUNTER] as? Int
                        tupleArr.insert((friend, lastMessage,  unreadCount), at: 0)
                    }
                    
                    self.recentChats.accept(tupleArr)
                }
            }
    }
    
    private func observeLastMessage(_ chatroomID: String, _ friendID: String) {
        //observe last message value
        FireBaseDB.sharedInstance.DBref.child(Constants.kMESSAGES).child(Helper.getCurrentUserID()).child(chatroomID).child(Constants.kLASTMESSAGE)
            .observe(.value) {[weak self] messageSnapshot in
                if let messageDictionary = messageSnapshot.value as? NSDictionary
                {
                    guard let self = self else{return}
                    
                    var tupleArr = self.recentChats.value
                    
                    var lastMessage = Message(messageDictionary)
                    
                    if let index = tupleArr.firstIndex(where: {$0.friend.userID == friendID })
                    {
                        //decrypt last message
                        lastMessage.message = self.cryptoManager.decrypt(text: lastMessage.message, ExternalPublicKeyStr: tupleArr[index].friend.publicKey)

                        if lastMessage.isOutgoing
                        {
                            lastMessage.message = "You: " + lastMessage.message
                        }
                        
                        tupleArr[index].lastMessage = lastMessage
                        if index != 0
                        {
                            let toTop = tupleArr.remove(at: index)
                            tupleArr.insert(toTop, at: 0)
                        }
                        self.recentChats.accept(tupleArr)
                    }
                }
            }
    }
    
    private func observeUnreadCount(_ chatroomID: String, _ friendID: String)
    {
        //observe unread count
        FireBaseDB.sharedInstance.DBref.child(Constants.kMESSAGES).child(Helper.getCurrentUserID()).child(chatroomID).child(Constants.kUNREADCOUNTER)
            .observe(.value)
        { [weak self] countSnapshot in
            if let count = countSnapshot.value as? Int
            {
                guard let self = self else{return}
                
                var tupleArr = self.recentChats.value

                if let indx = tupleArr.firstIndex(where: {$0.friend.userID == friendID })
                {
                    if !tupleArr[indx].lastMessage.isOutgoing
                    {
                        tupleArr[indx].unreadCount = count
                        self.recentChats.accept(tupleArr)
                    }
                }
            }
        }
    }
    
    func observeAvatar(_ friendID: String)
    {
        FireBaseDB.sharedInstance.observeAvatar(friendID)
        {
            [weak self] avatar in
            guard let self = self else{return}
            
            var tupleArr = self.recentChats.value
            
            if let indx = tupleArr.firstIndex(where: {$0.friend.userID == friendID })
            {
                tupleArr[indx].friend.avatar = avatar
                self.recentChats.accept(tupleArr)
            }
        }
    }
    
    func readMessages(index : Int)
    {
        let chat = self.recentChats.value[index]
        FireBaseDB.sharedInstance.resetUnreadCounter(chatRoomID: Helper.getChatRoomID(ID1: Helper.getCurrentUserID(), ID2: chat.friend.userID))
    }
    
    func reEncryptMessages(_ messsages : NSDictionary,oldPublicKey : String, newPublicKey : String) -> ([String: Any],Message,[String: Any])
    {
        //decrypt and reEncrypt using new public key and return last message with them
        var myNewMessagesDict = [String: Any]()
        var friendNewMessagesDict = [String: Any]()
        var lastMessage = Message(NSDictionary())
        lastMessage.date = Date(timeIntervalSince1970: 0)
        
        for (msgID,msgValue) in messsages
        {
            if let msgID = msgID as? String ,let msgValue = msgValue as? NSDictionary
            {
                var tempMsg = Message(msgValue)
                tempMsg.messageId = msgID
                
                //reEncrypt
                tempMsg.message = cryptoManager.decrypt(text: tempMsg.message, ExternalPublicKeyStr: oldPublicKey)
                tempMsg.message = cryptoManager.encrypt(text: tempMsg.message, ExternalPublicKeyStr: newPublicKey)
                
                friendNewMessagesDict[tempMsg.messageId] = tempMsg.messageDictionary()
                
                //set last message for the friend
                if tempMsg.date > lastMessage.date { lastMessage = tempMsg }
                
                //reverse isOutgoing state for  current user
                tempMsg.isOutgoing = !tempMsg.isOutgoing
                myNewMessagesDict[tempMsg.messageId] = tempMsg.messageDictionary()
            }
        }
        return (myNewMessagesDict,lastMessage,friendNewMessagesDict)
    }
}
