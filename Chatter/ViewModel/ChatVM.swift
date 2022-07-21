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
        //set initial message
        let systemMessage = Message(content: "Messages are end-to-end encrypted.", type: .system, isOutgoing: true, duration: nil)
        messages = BehaviorRelay<[Message]>(value: [systemMessage])
        
        
        chatRoomID = Helper.getChatRoomID(ID1: Helper.getCurrentUserID(), ID2: chatWith.userID)

        getEncryptionKeys()

        otherUser.accept(chatWith)
        
        DispatchQueue.global(qos: .userInteractive).async
        { [weak self] in
            self?.getMessagesFromDB()
            self?.observeAvatar()
            self?.observeOnlineStatus()
        }
        

    }
    
    //MARK: - Var(s)
    private(set) var messages: BehaviorRelay<[Message]>
    private(set) var otherUser = BehaviorRelay<User>(value: User(userID: "", createdAt: Date(), updatedAt: Date(), email: "", fullName: "", avatar: "", publicKey: ""))
    private(set) var isOnline = BehaviorRelay<Bool>(value: false)
    private(set) var chatRoomID : String
    private var unreadCount : Int = 0
    private var cryptoManager : CryptoManager!
    
    //MARK: - intent(s)
    func sendMessage(messageContent: String, type : MessageType)
    {
        var message = Message(content: messageContent, type: type, isOutgoing: true, duration: 0)
        message.message = self.cryptoManager.encrypt(text: message.message, ExternalPublicKeyStr: self.otherUser.value.publicKey)
        sendMessage(message)
    }
    
    func sendMessage(_ message: Message)
    {
        let chatRoomRefForFriend = FireBaseDB.sharedInstance.DBref.child(Constants.kMESSAGES).child(otherUser.value.userID).child(chatRoomID)
        let chatRoomRefForCurrentUSer = FireBaseDB.sharedInstance.DBref.child(Constants.kMESSAGES).child(Helper.getCurrentUserID()).child(chatRoomID)
        
        var friendMessage = message
        friendMessage.isOutgoing = false
        
        //set last message for both users
        chatRoomRefForFriend.child(Constants.kLASTMESSAGE).setValue(friendMessage.messageDictionary())
        chatRoomRefForCurrentUSer.child(Constants.kLASTMESSAGE).setValue(message.messageDictionary())
        
        //save the message for current user
        chatRoomRefForCurrentUSer.child(Constants.kMESSAGES).child(message.messageId)
            .setValue(message.messageDictionary())
        
        //save message for the other user
        chatRoomRefForFriend.child(Constants.kMESSAGES).child(friendMessage.messageId)
            .setValue(friendMessage.messageDictionary())
        
        //increase unread messages counter for friend
        chatRoomRefForFriend.child(Constants.kUNREADCOUNTER)
            .getData {
                Err, unreadCountSnapshot in
                let count = unreadCountSnapshot.value as? Int
                chatRoomRefForFriend.child(Constants.kUNREADCOUNTER).setValue(count == nil ? 1 : count! + 1)
            }
    }
    
    //MARK: - Helper Funcs
    private func getEncryptionKeys()
    {
        let privateKeyStr = KeyChainManager.getChatterPrivateKeyStr()
        if let privateKey = CryptoManager.getPrivateKeyFromString(privateKeyStr: privateKeyStr)
        {
            cryptoManager = CryptoManager(privateKey: privateKey)
        }
    }
    
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
                    var message = Message(dictionaryMessage)
                    
                    //decrypt messages
                    message.message = self.cryptoManager.decrypt(text: message.message, ExternalPublicKeyStr: self.otherUser.value.publicKey)
                    
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
        var imageMessage = Message(content: "0", type: .image, isOutgoing: true, duration: 0)
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
                        imageMessage.message = self.cryptoManager.encrypt(text: url, ExternalPublicKeyStr: self.otherUser.value.publicKey)
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
            var voiceNoteMessage = Message(content: "0", type: .audio, isOutgoing: true, duration: duration)
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
                        voiceNoteMessage.message = self.cryptoManager.encrypt(text: url, ExternalPublicKeyStr: self.otherUser.value.publicKey)
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
