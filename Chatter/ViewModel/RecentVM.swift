//
//  RecentVM.swift
//  Chatter
//
//  Created by Nader Said on 12/07/2022.
//

import Foundation
import RxRelay

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
    
    
    //MARK: - intent(s)
    
    //MARK: - Helper Funcs
    private func getFromDB()
    {
        
        // get all chatrooms and last messages and updated friend info
        FireBaseDB.sharedInstance.DBref.child(Constants.kMESSAGES).child(Helper.getCurrentUserID()).queryOrdered(byChild: "\(Constants.kLASTMESSAGE)/\(Constants.kDATE)")
            .observe(.childAdded, with: {[weak self] chatroomSnapshot in
                if let dictionaryChatroom = chatroomSnapshot.value as? NSDictionary
                {
                    //get friend object
                    let chatroomID = chatroomSnapshot.key
                    let friendID = chatroomID.replacingOccurrences(of: Helper.getCurrentUserID(), with: "")
                    
                    
                    let lastMessage = Message(dictionaryChatroom[Constants.kLASTMESSAGE] as! NSDictionary)
                    
                    //observe friend value
                    self?.observeFriendValue(friendID, dictionaryChatroom, lastMessage)
                    
                    //observe last message value
                    self?.observeLastMessage(chatroomID, friendID)
                    
                    //observe unread count
                    self?.observeUnreadCount(chatroomID, friendID)
                }
                
            }
            )
        
        
    }
    
    private func observeFriendValue(_ friendID: String, _ dictionaryChatroom: NSDictionary, _ lastMessage: Message)
    {
        //observe friend value
        FireBaseDB.sharedInstance.DBref.child(Constants.kALLUSERS).child(friendID)
            .observe(.value){[weak self] friendSnapshot in
                if let friendDictionary = friendSnapshot.value as? NSDictionary
                {
                    let friend = User(friendDictionary)
                    guard let self = self else{return}
                    
                    var tupleArr = self.recentChats.value
                    
                    let index = tupleArr.firstIndex(where: {$0.friend.userID == friend.userID })
                    if let index = index
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
                if self != nil
                {
                    if let messageDictionary = messageSnapshot.value as? NSDictionary
                    {
                        guard let self = self else{return}

                        var tupleArr = self.recentChats.value
                        let index = tupleArr.firstIndex(where: {$0.friend.userID == friendID })
                        
                        var lastMessage = Message(messageDictionary)
                        
                        if let index = index
                        {
                            if lastMessage.senderId != friendID
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
                    if tupleArr[indx].lastMessage.senderId == friendID
                    {
                        tupleArr[indx].unreadCount = count
                        self.recentChats.accept(tupleArr)
                    }
                }
            }
            
        }
    }
    
    
    
    func readMessages(index : Int)
    {
        let chat = self.recentChats.value[index]
        
        FireBaseDB.sharedInstance.DBref.child(Constants.kMESSAGES).child(Helper.getCurrentUserID()).child(Helper.getChatRoomID(ID1: Helper.getCurrentUserID(), ID2: chat.friend.userID)).child(Constants.kUNREADCOUNTER)
            .setValue(0)
    }
}
