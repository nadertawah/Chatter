//
//  ChatVM.swift
//  Chatter
//
//  Created by Nader Said on 12/07/2022.
//

import Foundation
import RxCocoa
import Kingfisher

class ChatVM
{
    init(_ chatWith : User)
    {
        otherUser = chatWith
        chatRoomID = Helper.getChatRoomID(ID1: Helper.getCurrentUserID(), ID2: otherUser.userID)
        getMessagesFromDB()
        resetUnreadCounter()
    }
    
    //MARK: - Var(s)
    private(set) var messages = BehaviorRelay<[Message]>(value: [])
    private(set) var otherUser : User
    private(set) var chatRoomID : String
    
    //MARK: - intent(s)
    func sendMessage(messageContent: String, type : MessageType)
    {
        let message = Message(content: messageContent, senderId: Helper.getCurrentUserID(), type: type)
        sendMessage(message)
    }
    
    func sendMessage(_ message: Message)
    {
        let chatRoomRefForFriend = FireBaseDB.sharedInstance.DBref.child(Constants.kMESSAGES).child(otherUser.userID).child(chatRoomID)
        let chatRoomRefForCurrentUSer = FireBaseDB.sharedInstance.DBref.child(Constants.kMESSAGES).child(Helper.getCurrentUserID()).child(chatRoomID)
        
        //set last message for both users
        chatRoomRefForFriend.child(Constants.kLASTMESSAGE).setValue(message.messageDictionary())
        chatRoomRefForCurrentUSer.child(Constants.kLASTMESSAGE).setValue(message.messageDictionary())
        
        
        //save the message for current user
        chatRoomRefForCurrentUSer.child(Constants.kMESSAGES).child(message.messageId)
            .setValue(message.messageDictionary())
        
        //save message for the other user
        chatRoomRefForFriend.child(Constants.kMESSAGES).child(message.messageId)
            .setValue(message.messageDictionary())
        
        //increase unread messages counter for friend
        chatRoomRefForFriend.child(Constants.kUNREADCOUNTER)
            .getData {
                Err, unreadCountSnapshot in
                let count = unreadCountSnapshot.value as? Int
                chatRoomRefForFriend.child(Constants.kUNREADCOUNTER).setValue(count == nil ? 1 : count! + 1)
            }
        
        //reset unread messages counter for current user
        resetUnreadCounter()
    }
    
    
    //MARK: - Helper Funcs
    
    private func getMessagesFromDB()
    {
        FireBaseDB.sharedInstance.DBref.child(Constants.kMESSAGES).child(Helper.getCurrentUserID()).child(chatRoomID).child(Constants.kMESSAGES)
            .queryOrdered(byChild: Constants.kDATE)
            .observe(.childAdded, with: {[weak self] snapshot in
                if let dictionaryMessage = snapshot.value as? NSDictionary
                {
                    guard let self = self else {return}
                    var msgArr = self.messages.value
                    msgArr.append(Message(dictionaryMessage))
                    self.messages.accept(msgArr)
                }
            })
    }
    
    func imgFileUrl(index:Int) -> URL?
    {
        let localFileURL = URL.chatterImgFileURL(chatRoomID: chatRoomID, msgDate: messages.value[index].date)
        if FileManager.default.fileExists(atPath: localFileURL.path)
        {
            return localFileURL
        }
        else
        {
            return nil
        }
    }
    
    func storeImageLocally(image: UIImage, forURL imgUrl: URL)
    {
        if !FileManager.default.fileExists(atPath: imgUrl.path)
        {
            do {
                if let pngRepresentation = image.jpegData(compressionQuality: 0.1)
                {
                    let folderPathExists = FileManager.default.fileExists(atPath: imgUrl.deletingLastPathComponent().path)
                    if !folderPathExists
                    {
                        try FileManager.default.createDirectory(at: imgUrl.deletingLastPathComponent(), withIntermediateDirectories: true)
                    }
                    try pngRepresentation.write(to: imgUrl,options: .atomic)
                }
            }
            catch
            {
                print(error.localizedDescription)
            }
        }
    }
    
    func downloadImg(index:Int, progress : @escaping (Float)->(),completion : @escaping (UIImage?)->())
    {
        let message = messages.value[index]
        let url = URL(string: message.message)
        let localFileURL = URL.chatterImgFileURL(chatRoomID: chatRoomID, msgDate: messages.value[index].date)
        
        ImageDownloader.default.downloadImage(with: url!, options: .none)
        {
            receivedSize, totalSize in
            progress(Float(receivedSize) / Float(totalSize))
        }
        completionHandler:
        {
            result in
            switch result
            {
            case .success(let value):
                self.storeImageLocally(image: value.image, forURL: localFileURL)
                completion(UIImage(contentsOfFile: localFileURL.path)?.resizeImageTo(size: CGSize(width: 200, height: 200)))
            case .failure(let error):
                print(error)
        }
    }
    }
    
    func resetUnreadCounter()
    {
        //check if there is a chat
        FireBaseDB.sharedInstance.DBref.child(Constants.kMESSAGES).child(Helper.getCurrentUserID()).child(chatRoomID).child(Constants.kLASTMESSAGE)
            .observeSingleEvent(of: .value)
        { [weak self]
            snapshot in
            guard let self = self else{return}
            
            if snapshot.exists()
            {
                FireBaseDB.sharedInstance.DBref.child(Constants.kMESSAGES).child(Helper.getCurrentUserID()).child(self.chatRoomID).child(Constants.kUNREADCOUNTER)
                    .setValue(0)
            }
        }
        
    }
    
    func uploadImage(image: UIImage)
    {
        var imageMessage = Message(content: "0", senderId: Helper.getCurrentUserID(), type: .image)
        let date = imageMessage.date.chatterStringFromDate()
        let imgRef = FireBaseStore.sharedInstance.storageRef.child(Constants.kImageStore).child(Helper.getCurrentUserID()).child(chatRoomID).child("\(date).jpg")
        let task = imgRef.putData(image.jpegData(compressionQuality: 0.4)!)
        
        task.observe(.success) { [weak self] StorageTaskSnapshot in
            imgRef.downloadURL { url, err in
                guard let self = self else {return}
                if let url = url?.absoluteString
                {
                    let localFileURL = URL.chatterImgFileURL(chatRoomID: self.chatRoomID, msgDate: imageMessage.date)
                    self.storeImageLocally(image: image, forURL: localFileURL)
                    
                    imageMessage.message = url
                    self.sendMessage(imageMessage)
                    
                    task.removeAllObservers()
                }
                
            }
        }
        
        
        task.observe(.failure) { StorageTaskSnapshot in
            print(StorageTaskSnapshot.error!.localizedDescription)
            task.removeAllObservers()
        }
        
        
    }
    
}
