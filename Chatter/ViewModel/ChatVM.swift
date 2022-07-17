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
        self.otherUser.accept(chatWith)
        
        self.chatRoomID = Helper.getChatRoomID(ID1: Helper.getCurrentUserID(), ID2: chatWith.userID)
        
        DispatchQueue.global(qos: .userInteractive).async
        {
            self.getMessagesFromDB()
            self.observeAvatar()
            self.observeOnlineStatus()
        }
    }
    
    //MARK: - Var(s)
    private(set) var messages = BehaviorRelay<[Message]>(value: [])
    private(set) var otherUser = BehaviorRelay<User>(value: User(userID: "", createdAt: Date(), updatedAt: Date(), email: "", fullName: "", avatar: ""))
    private(set) var isOnline = BehaviorRelay<Bool>(value: false)
    private(set) var chatRoomID : String
    private var unreadCount : Int = 0
    
    //MARK: - intent(s)
    func sendMessage(messageContent: String, type : MessageType)
    {
        let message = Message(content: messageContent, senderId: Helper.getCurrentUserID(), type: type, duration: 0)
        sendMessage(message)
    }
    
    func sendMessage(_ message: Message)
    {
        let chatRoomRefForFriend = FireBaseDB.sharedInstance.DBref.child(Constants.kMESSAGES).child(otherUser.value.userID).child(chatRoomID)
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
                    
                    //reset unread messages counter for current user
                    self.resetUnreadCounter()
                    
                    var msgArr = self.messages.value
                    let message = Message(dictionaryMessage)
                    msgArr.append(message)
                    self.messages.accept(msgArr)
                    
                    
                }
            })
    }
    
    func imgFileUrl(message: Message) -> URL?
    {
        let localFileURL = URL.chatImgFileURL(chatRoomID: chatRoomID, msgDate: message.date)
        if FileManager.default.fileExists(atPath: localFileURL.path)
        {
            return localFileURL
        }
        else
        {
            return nil
        }
    }
    
    func storeFileLocally(data: Data, forURL imgUrl: URL)
    {
        if !FileManager.default.fileExists(atPath: imgUrl.path)
        {
            do {
                let folderPathExists = FileManager.default.fileExists(atPath: imgUrl.deletingLastPathComponent().path)
                if !folderPathExists
                {
                    try FileManager.default.createDirectory(at: imgUrl.deletingLastPathComponent(), withIntermediateDirectories: true)
                }
                try data.write(to: imgUrl,options: .atomic)
            }
            catch
            {
                print(error.localizedDescription)
            }
        }
    }
    
    func downloadImg(message:Message, progress : @escaping (Float)->(),completion : @escaping (UIImage?)->())
    {
        let url = URL(string: message.message)
        let localFileURL = URL.chatImgFileURL(chatRoomID: chatRoomID, msgDate: message.date)
        
        ImageDownloader.default.downloadImage(with: url!, options: .none)
        {
            receivedSize, totalSize in
            progress(Float(receivedSize) / Float(totalSize))
        }
        completionHandler:
        {[weak self]
            result in
            guard let self = self else {return}
            switch result
            {
            case .success(let value):
                if let pngRepresentation = value.image.jpegData(compressionQuality: 0.1)
                {
                    self.storeFileLocally(data: pngRepresentation, forURL: localFileURL)
                    completion(UIImage(contentsOfFile: localFileURL.path)?.resizeImageTo(size: CGSize(width: 200, height: 200)))
                    self.messages.accept(self.messages.value)
                }
                
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
                FireBaseDB.sharedInstance.resetUnreadCounter(chatRoomID: self.chatRoomID)
            }
        }
        
    }
    
    func uploadImage(image: UIImage)
    {
        var imageMessage = Message(content: "0", senderId: Helper.getCurrentUserID(), type: .image, duration: 0)
        let date = imageMessage.date.chatterStringFromDate()
        let imgRef = FireBaseStore.sharedInstance.storageRef.child(Constants.kIMAGESTORE).child(Helper.getCurrentUserID()).child(chatRoomID).child("\(date).jpg")
        let task = imgRef.putData(image.jpegData(compressionQuality: 0.4)!)
        
        task.observe(.success) { [weak self] StorageTaskSnapshot in
            imgRef.downloadURL { url, err in
                guard let self = self else {return}
                if let url = url?.absoluteString
                {
                    let localFileURL = URL.chatImgFileURL(chatRoomID: self.chatRoomID, msgDate: imageMessage.date)
                    
                    if let pngRepresentation = image.jpegData(compressionQuality: 0.1)
                    {
                        self.storeFileLocally(data: pngRepresentation, forURL: localFileURL)
                        imageMessage.message = url
                        self.sendMessage(imageMessage)
                        
                        task.removeAllObservers()
                    }
                    
                    
                }
                
            }
        }
        
        
        task.observe(.failure) { StorageTaskSnapshot in
            print(StorageTaskSnapshot.error!.localizedDescription)
            task.removeAllObservers()
        }
        
        
    }
    
    func uploadVoiceNote(duration : TimeInterval)
    {
        do
        {
            var voiceNoteMessage = Message(content: "0", senderId: Helper.getCurrentUserID(), type: .audio, duration: duration)
            let date = voiceNoteMessage.date.chatterStringFromDate()
            let voiceNoteRef = FireBaseStore.sharedInstance.storageRef.child(Constants.kVOICENOTESTORE).child(Helper.getCurrentUserID()).child(chatRoomID).child("\(date).caf")
            let audioData = try Data(contentsOf: FileManager.tempVoiceNoteDir())
            let task = voiceNoteRef.putData(audioData)
            
            task.observe(.success) { [weak self] StorageTaskSnapshot in
                voiceNoteRef.downloadURL { url, err in
                    guard let self = self else {return}
                    if let url = url?.absoluteString
                    {
                        let localFileURL = URL.chatAudioFileUrl(chatRoomID: self.chatRoomID, msgDate: voiceNoteMessage.date)
                        
                        self.storeFileLocally(data: audioData, forURL: localFileURL)
                        voiceNoteMessage.message = url
                        self.sendMessage(voiceNoteMessage)
                        task.removeAllObservers()
                    }
                }
            }
            
            task.observe(.failure) { StorageTaskSnapshot in
                print(StorageTaskSnapshot.error!.localizedDescription)
                task.removeAllObservers()
            }
        }
        catch
        {
            print("Error uploading voice note!")
        }
        
    }
    
    func observeAvatar()
    {
        FireBaseDB.sharedInstance.observeAvatar(otherUser.value.userID)
        {
            [weak self] avatar in
            guard let self = self else{return}
            
            var friend = self.otherUser.value
            friend.avatar = avatar
            self.otherUser.accept(friend)
        }
    }
    
    func observeOnlineStatus()
    {
        FireBaseDB.sharedInstance.observeOnlineStatus(friendID: otherUser.value.userID)
        {
            [weak self] in
            guard let self = self else{return}
            self.isOnline.accept($0)
        }
    }
}
